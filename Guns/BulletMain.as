#include "Hitters.as";


class BulletFade//todo trail effect
{
    Vec2f Pos;
    Vec2f LastPos;
    SColor Col;
    u8 TimeLeft;
    bool FacingLeft;
    u8 Alpha;
    Vec2f TopLeft;
    Vec2f BotLeft;
    Vec2f liTopRight;
    Vec2f liBotRight;
    u8 fadeDir;
    BulletFade(Vec2f topLeft, Vec2f botLeft, Vec2f LiTopRight, Vec2f LiBotRight, u8 bulletRnum)
    {
        //print("hello world");
        //Pos = CurrentPos;
        //LastPos = lastPos;
        TimeLeft = 20 / (60 * getRenderDeltaTime());
        //print(TimeLeft + " a");
        Alpha = 150;
        Col = SColor(255, 255, 174, 61);
        TopLeft = topLeft;
        BotLeft = botLeft;
        liTopRight = LiTopRight;
        liBotRight = LiBotRight;
        fadeDir = bulletRnum;
    }

    void JoinQueue()
    {
        TimeLeft -=1;
        if(Alpha < 5)
        {
            TimeLeft = 0;
            Alpha = 0;
        }
        Alpha -= 5 * (60 * getRenderDeltaTime());
        //print(Alpha + " a");
        Col.setBlue(Col.getBlue() + 1);
        Col.setGreen(Col.getGreen() - 1);
        Col.setAlpha(Alpha);
        float toAdd = 0.20 * ((60 * getRenderDeltaTime()));
        //print(toAdd + "a");
        /*switch(fadeDir)
        {
            case 3:
            case 0:
            {
                liBotRight.x -= toAdd;
                liTopRight.x -= toAdd;
                TopLeft.x -= toAdd;
                BotLeft.x -= toAdd;
                liBotRight.y += toAdd;
                liTopRight.y += toAdd;
                TopLeft.y += toAdd;
                BotLeft.y += toAdd;
                break;
            }

            case 1:
            {
                liBotRight.x -= toAdd;
                liTopRight.x -= toAdd;
                TopLeft.x -= toAdd;
                BotLeft.x -= toAdd;
                liBotRight.y -= toAdd;
                liTopRight.y -= toAdd;
                TopLeft.y -= toAdd;
                BotLeft.y -= toAdd;
                break;
            }

            case 2:
            {
                break;
            }

        }*/

        /*if(FacingLeft)
        {
            v_r_fade.push_back(Vertex(Pos.x+1, Pos.y-1,        1, 0, 0, Col)); //top left // x = Cur; y = Cur
	        v_r_fade.push_back(Vertex(Pos.x-1, Pos.y+1,               1, 1, 0, Col)); //top right  //  x = Cur; y = CurrentPos;
		    v_r_fade.push_back(Vertex(LastPos.x-1,LastPos.y+1,               1, 1, 1, Col)); //bot right // x = cur ; y = cur
		    v_r_fade.push_back(Vertex(LastPos.x+1, LastPos.y-1,        1, 0, 1, Col)); //bot left //x =last ; y = last
        }*/
       /* v_r_fade.push_back(Vertex(Pos.x-1, Pos.y+1,        1, 0, 0, Col)); //top left // x = Cur; y = Cur
	    v_r_fade.push_back(Vertex(Pos.x+1, Pos.y-1,               1, 1, 0, Col)); //top right  //  x = Cur; y = CurrentPos;
		v_r_fade.push_back(Vertex(LastPos.x+1,LastPos.y-1,               1, 1, 1, Col)); //bot right // x = cur ; y = cur
		v_r_fade.push_back(Vertex(LastPos.x-1, LastPos.y+1,        1, 0, 1, Col)); //bot left //x =last ; y = last*/
        v_r_fade.push_back(Vertex(liTopRight.x, liTopRight.y,     1, 1, 0, Col)); //top right
        v_r_fade.push_back(Vertex(TopLeft.x, TopLeft.y,        1, 0, 0, Col)); //top left
		v_r_fade.push_back(Vertex(BotLeft.x, BotLeft.y,       1, 0, 1, Col)); //bot left
        v_r_fade.push_back(Vertex(liBotRight.x, liBotRight.y,      1, 1, 1, Col)); //bot right
        //print(Alpha + " a");
    }
}

class BulletObj
{
    Vec2f CurrentPos;
    Vec2f LastPos;
	Vec2f RenderPos;
    Vec2f liTopRight;
    Vec2f liBotRight;
    f32 StartingAimPos;
    s8 TimeLeft = 120;
    Vec2f Velocity;
    bool FacingLeft;
    u8 TeamNum;
    u8 bulletRnum;
    f32 lastDelta;
    

	BulletObj(Vec2f startPos, Vec2f AimPos, bool isFacingLeft)
	{
        CurrentPos = startPos;
        SetStartAimPos(AimPos,isFacingLeft);
        FacingLeft = isFacingLeft;
        Velocity = Vec2f(0,5);
        LastPos = startPos;
		RenderPos = startPos;
	}

	BulletObj(Vec2f startPos, f32 AimPos,bool isFacingLeft,u8 teamNum)
	{
        CurrentPos = startPos;
        StartingAimPos = AimPos;
        FacingLeft = isFacingLeft;
        LastPos = startPos;
        TeamNum = teamNum;
		RenderPos = startPos;
        //LastInterpPos = CurrentPos;
        liTopRight = CurrentPos;
        liBotRight = CurrentPos;
        bulletRnum = XORRandom(4);
        lastDelta = 0;
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
        lastDelta = 0;
        LastPos = CurrentPos;
        TimeLeft--;
        Velocity -= Vec2f(0,0.025);
        f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
        Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
        Vec2f temp = CurrentPos + Vec2f(1 * (FacingLeft ? -1 : 1), 1);
        CurrentPos = (((dir * 35) - (Velocity * 35))) + CurrentPos;
    
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
                    if (hit.blob.getTeamNum() != TeamNum && hit.blob.hasTag("flesh"))
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
                        TimeLeft = 0;
                    }
                }
                else
                { 
                    if(isClient())
                    {
                        Sound::Play("BulletImpact.ogg", hitpos, 1.5f);
                    }
                    CurrentPos = hitpos;
                    TimeLeft = 0;
                    //break;
                }
            }
        }
    
    }

    void JoinQueue()//every bullet gets forced to join the queue in onRenders, so we use this to calc to position
    {
                
        lastDelta += 30 * getRenderDeltaTime();

		Vec2f newPos = Vec2f(lerp(LastPos.x, CurrentPos.x, lastDelta), lerp(LastPos.y, CurrentPos.y, lastDelta));

		f32 angle = Vec2f(CurrentPos.x-newPos.x, CurrentPos.y-newPos.y).getAngleDegrees();


        Vec2f TopLeft  = Vec2f(newPos.x -1, newPos.y-2);
        Vec2f TopRight = Vec2f(newPos.x -1, newPos.y+2);
        Vec2f BotLeft  = Vec2f(newPos.x +1, newPos.y-2);
        Vec2f BotRight = Vec2f(newPos.x +1, newPos.y+2);

        angle = (angle % 360) + 90;

        BotLeft.RotateBy( -angle,newPos);
        BotRight.RotateBy(-angle,newPos);
        TopLeft.RotateBy( -angle,newPos);
        TopRight.RotateBy(-angle,newPos);

        //BulletGrouped.addFade(TopLeft, BotLeft, liTopRight, liBotRight,bulletRnum);
        //print(liTopRight + " | " + liBotRight + " a");
        //liTopRight = TopRight;
        //liBotRight = BotRight;
        //print(liTopRight + " | " + liBotRight + " b");

        v_r_bullet.push_back(Vertex(TopLeft.x,  TopLeft.y,      1, 0, 0, SColor(255,255,255,255))); //top left
		v_r_bullet.push_back(Vertex(TopRight.x, TopRight.y,     1, 1, 0, SColor(255,255,255,255))); //top right
		v_r_bullet.push_back(Vertex(BotRight.x, BotRight.y,     1, 1, 1, SColor(255,255,255,255))); //bot right
		v_r_bullet.push_back(Vertex(BotLeft.x,  BotLeft.y,      1, 0, 1, SColor(255,255,255,255))); //bot left
    }

    
}


class BulletHolder
{
    BulletObj[] bullets;
    BulletFade[] fade;

	BulletHolder()
	{
	}

    void FakeOnTick(CRules@ this)
    {
        CMap@ map = getMap();
        for(int a = 0; a < bullets.length(); a++)
        {
            if(bullets[a].TimeLeft < 1)
            {
                bullets.removeAt(a);
                continue;
            }
            else
            {
                bullets[a].onFakeTick(map);
            }
        }

        /*or(int a = 0; a < fade.length(); a++)
        {
            if(fade[a].TimeLeft < 1)
            {
                fade.removeAt(a);
                continue;
            }
            fade[a].TimeLeft -= 1;
        }*/
    }
    void addFade(Vec2f topLeft, Vec2f botLeft, Vec2f LiTopRight, Vec2f LiBotRight, u8 bulletRnum)
    {
        BulletFade@ fadeToAdd = BulletFade(topLeft,botLeft,LiTopRight,LiBotRight, bulletRnum);
        fade.push_back(fadeToAdd);
        fadeToAdd.JoinQueue();
    }
    

    void FillArray()
    {
        for(int a = 0; a < bullets.length(); a++)
        {
            bullets[a].JoinQueue();
        }

        for(int a = 0; a < fade.length(); a++)
        {
            if(fade[a].TimeLeft < 1)
            {
                fade.removeAt(a);
                continue;
            }
            fade[a].JoinQueue();
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
	//Render::SetTransformWorldspace();
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
    v_r_bullet.clear();
    //v_r_fade.clear();
    Render::SetAlphaBlend(true);
    BulletGrouped.FillArray();
    if(v_r_bullet.length() > 0)
    {
        Render::RawQuads("Bullet.png", v_r_bullet);
    }
    
    /*if(v_r_fade.length() > 0)
    {
        Render::RawQuads("Fade.png",v_r_fade);
    }*/
    
}


void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if(cmd == this.getCommandID("addTest")) {
        Vec2f pos = params.read_Vec2f();
        f32 angle = params.read_f32();
        bool isFacingLeft = params.read_bool();
        u8 teamNum = params.read_u8();
        BulletObj@ tempObj = BulletObj(pos, angle, isFacingLeft, teamNum);
        //print(angle+" Aa " + pos.Angle());
        BulletGrouped.AddNewObj(tempObj);
        //print(BulletGrouped.bullets.length() + " aa");
    }
}

float lerp(float v0, float v1, float t)
{
	return (1 - t) * v0 + t * v1;
}


