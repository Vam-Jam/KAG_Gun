#include "Hitters.as";


class Vec4f//not in use
{
    Vec2f TopLeft;
    Vec2f BotRight;
}

class BulletFade//todo trail effect
{
    BulletFade()
    {

    }
}

class BulletObj
{
    int arrayNum;
    Vec2f CurrentPos;
    Vec2f LastPos;
    f32 StartingAimPos;
    s8 timeLeft = 120;
    Vec2f Velocity;
    bool facingLeft;
    float time = 0;
    u8 teamNum;
    Vec4f pos;
    

	BulletObj(Vec2f startPos, Vec2f AimPos, bool isFacingLeft)
	{
        CurrentPos = startPos;
        SetStartAimPos(AimPos,isFacingLeft);
        facingLeft = isFacingLeft;
        Velocity = Vec2f(0,2);
        LastPos = startPos;
	}

	BulletObj(Vec2f startPos, f32 AimPos,bool isFacingLeft,u8 TeamNum)
	{
        CurrentPos = startPos;
        StartingAimPos = AimPos;
        facingLeft = isFacingLeft;
        LastPos = startPos;
        teamNum = TeamNum;
	}


    void SetStartAimPos(Vec2f aimPos, bool isFacingLeft)
    {
        Vec2f aimvector = aimPos - CurrentPos;
        StartingAimPos = isFacingLeft ? -aimvector.Angle()+180.0f : -aimvector.Angle();
    }

    void onFakeTick(CMap@ map)
    {
        map.debugRaycasts = true;
        //Render stuff
        LastPos = CurrentPos;
        timeLeft--;
        Velocity -= Vec2f(0,0.025);
        f32 angle = StartingAimPos * (facingLeft ? 1 : 1);
        Vec2f dir = Vec2f((facingLeft ? -1 : 1), 0.0f).RotateBy(angle);
        Vec2f temp = CurrentPos + Vec2f(1 * (facingLeft ? -1 : 1), 1);
        CurrentPos = (((dir * 20) - (Velocity * 15))) + CurrentPos;
        //End


        HitInfo@[] list;
        if(map.getHitInfosFromRay(CurrentPos, -(LastPos - CurrentPos).Angle(), (LastPos - CurrentPos).Length(), null, @list))
        {
            for(int a = 0; a < list.length(); a++)
            {
                HitInfo@ hit = list[a];
                Vec2f hitpos = hit.hitpos;
                if (hit.blob !is null) // blob
                {                    
                    print(a + "blob");
                    if (hit.blob.getTeamNum() != teamNum && hit.blob.hasTag("flesh"))
                    {    
                        if(!map.rayCastSolid(LastPos, CurrentPos))
                        {
                            if(isServer())
                            {
                                hit.blob.server_Hit(hit.blob, hitpos, Vec2f(0, 0), 1.0f, Hitters::arrow); 
                            }
                            else
                            {
                                Sound::Play("ArrowHitFlesh.ogg", hitpos, 1.5f); 
                            } 
                        }
                        CurrentPos = hitpos;
                        timeLeft = 0;
                    }
                }
                else
                {
                    if(isClient())
                    {
                        Sound::Play("BulletImpact.ogg", hitpos, 1.5f);
                    }
                    CurrentPos = hitpos;
                    timeLeft = 0;
                    break;
                }
            }
        }
    
    }

    void JoinQueue()//every bullet gets forced to join the queue in onRenders, so we use this to calc to position
    {
        float timeToProcess = getRenderDeltaTime() * 30;
        if(time + timeToProcess > 1)
        {
            time = 0;
        }//todo reset to 0 better so no gaps are left
        
        time += timeToProcess;
        Vec2f tempPos = Vec2f(lerp(CurrentPos.x,LastPos.x,time),
            lerp(CurrentPos.y,LastPos.y,time));
        //print(time + " a");

        //Vec2f newX = centerX + (point2x-centerX)*Math.cos(x) - (point2y-centerY)*Math.sin(x);

        //newY = centerY + (point2x-centerX)*Math.sin(x) + (point2y-centerY)*Math.cos(x);

        //float x = (LastPos-CurrentPos).Angle();
        //tempPos.x = tempPos.x + ((((tempPos.x - 3) - tempPos.x))*Maths::Cos(x)) - (((tempPos.y - 3) - tempPos.y)*Maths::Sin(x));
    
        //tempPos.y = tempPos.y + ((((tempPos.y - 3) - tempPos.y))*Maths::Sin(x)) - (((tempPos.x - 3) - tempPos.x)*Maths::Cos(x));
        float x = tempPos.x;
        float y = tempPos.y;
        if(!facingLeft)
        {
            v_r_bullet.push_back(Vertex(x-3, y-3,        1, 0, 0, SColor(255,255,255,255))); //top left
		    v_r_bullet.push_back(Vertex(x + 3, y-3,                1, 1, 0, SColor(255,255,255,255))); //top right
		    v_r_bullet.push_back(Vertex(x + 3, y+3,                               1, 1, 1, SColor(255,255,255,255))); //bot right
		    v_r_bullet.push_back(Vertex(x-3, y+3,                       1, 0, 1, SColor(255,255,255,255))); //bot left
        }
        else
        {   //old, will update once ^ is working
            v_r_bullet.push_back(Vertex(tempPos.x + 3, tempPos.y + 3, 1, 0, 0, SColor(255,255,255,255)));
            v_r_bullet.push_back(Vertex(x - 3, tempPos.y + 3, 1, 1, 0, SColor(255,255,255,255)));
            v_r_bullet.push_back(Vertex(x - 3, y - 3, 1, 1, 1, SColor(255,255,255,255)));
            v_r_bullet.push_back(Vertex(tempPos.x + 3, y - 3, 1, 0, 1, SColor(255,255,255,255)));
        }
    }

    

    
}


class BulletHolder
{
    BulletObj[] bullets;

	BulletHolder()
	{
	}

    void FakeOnTick(CRules@ this)
    {
        CMap@ map = getMap();
        for(int a = 0; a < bullets.length(); a++)
        {
            if(bullets[a].timeLeft < 1)
            {
                bullets.removeAt(a);
                continue;
            }
            else
            {
                bullets[a].onFakeTick(map);
            }
        }
    }

    void FillArray()
    {
        for(int a = 0; a < bullets.length(); a++)
        {
            bullets[a].JoinQueue();
        }
    }

    void AddNewObj(BulletObj@ this)
    {
        //print("pew");
        bullets.push_back(this);
    }
    
	void Clean()
	{
		bullets.clear();
	}

    int ArrayCount()
	{
		return bullets.length();
	}
}


BulletHolder@ BulletGrouped = BulletHolder();
Vertex[] v_r_bullet;
Vertex[] v_r_fade;


void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
    this.addCommandID("addTest");
}

void Reset(CRules@ this)
{
	BulletGrouped.Clean();
	Render::addScript(Render::layer_objects, "BulletMain", "SeeMeFlyyyy", 0.0f);
}

void onTick(CRules@ this)
{
	BulletGrouped.FakeOnTick(this);
}

void SeeMeFlyyyy(int id)//New onRender
{
	CMap@ map = getMap();
    CRules@ rules = getRules();
	ok(map,rules);
}

void ok(CMap@ map,CRules@ rules)
{

    
    
    


    //print((getRenderDeltaTime()*100)+"a");
    //v_r_bullet.clear();
    Render::SetAlphaBlend(true);
    BulletGrouped.FillArray();
    if(v_r_bullet.length() > 0)
    {
        Render::RawQuads("Bullet.png", v_r_bullet);  
    }

}


void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if(cmd == this.getCommandID("addTest")) {
        Vec2f pos = params.read_Vec2f();
        f32 angle = params.read_f32();
        bool isFacingLeft = params.read_bool();
        u8 teamNum = params.read_u8();
        BulletObj@ tempObj = BulletObj(pos, angle, isFacingLeft,teamNum);
        //print(angle+" Aa " + pos.Angle());
        BulletGrouped.AddNewObj(tempObj);
        //print(BulletGrouped.bullets.length() + " aa");
    }
}


float lerp(float A, float B, float t ){
    return A*t + B*(1.f-t);
}



