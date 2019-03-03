#include "GunHitters.as";


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
    CBlob@ hoomanShooter;
    CBlob@ gunBlob;
    Vec2f CurrentPos;
    Vec2f LastPos;
	Vec2f RenderPos;
    Vec2f liTopRight;
    Vec2f liBotRight;
    f32 StartingAimPos;
    s8 TimeLeft;
    Vec2f FakeVelocity;
    Vec2f TrueVelocity;
    bool FacingLeft;
    u8 TeamNum;
    f32 lastDelta;
    Vec2f GunVelo;
    float Damage;
    Vec2f KB;
    
	BulletObj(CBlob@ humanBlob, CBlob@ gun, f32 angle )
	{
        CurrentPos = humanBlob.getPosition();
        FacingLeft = humanBlob.isFacingLeft();
        GunVelo  = gun.get_Vec2f("speed");
        Damage   = gun.get_f32("damage");
        TeamNum  = gun.getTeamNum();
        TimeLeft = gun.get_u8("TTL");
        KB       = gun.get_Vec2f("KB");
        @hoomanShooter = humanBlob;
        StartingAimPos = angle;
        LastPos    = CurrentPos;
		RenderPos  = CurrentPos;
        liTopRight = CurrentPos;
        liBotRight = CurrentPos;
        @gunBlob   = gun;
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
        FakeVelocity -= GunVelo;
        f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
        Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
        Vec2f temp = CurrentPos + Vec2f(1 * (FacingLeft ? -1 : 1), 1);
        CurrentPos = (((dir * 35) - (FakeVelocity * 35))) + CurrentPos;
        TrueVelocity = CurrentPos - LastPos;
        //End


        bool endBullet = false;
        HitInfo@[] list;
        if(map.getHitInfosFromRay(LastPos, -(CurrentPos - LastPos).Angle(), (LastPos - CurrentPos).Length(), hoomanShooter, @list))
        {
            for(int a = 0; a < list.length(); a++)
            {
                HitInfo@ hit = list[a];
                Vec2f hitpos = hit.hitpos;
                if (hit.blob !is null) // blob
                {   
                    CBlob@ blob = @hit.blob;
                    if(blob.getName() == "stone_door" || blob.getName() == "wooden_door" || blob.getName() == "trap_block")  
                    {
                        if(blob.isCollidable())
                        {
                            CurrentPos = hitpos;
                            endBullet = true;
                            break;
                        }
                    }    
                    else if(blob.getName() == "wooden_platform")
                    {
                        /*f32 platform_angle = blob.getAngleDegrees();	
                        print(platform_angle + " a "+  (((LastPos - CurrentPos).Angle() + 90) % 360 ));
                        Vec2f direction = Vec2f(0.0f, -1.0f);
                        direction.RotateBy(platform_angle);
                        float velocity_angle = direction.AngleWith(Velocity);

                        if(!(velocity_angle > -90.0f && velocity_angle < 90.0f))
                        {
                            TimeLeft = 0;
                        }*/
                    }          
                    else if (blob.getTeamNum() != TeamNum)
                    {    
                        if(blob.hasTag("vehicle") || blob.hasTag("flesh") && blob.isCollidable())
                        {
                            CurrentPos = hitpos;
                            if(!blob.hasTag("invincible") && !blob.hasTag("seated"))
                            {
                                if(isServer())
                                {
                                    hoomanShooter.server_Hit(blob, CurrentPos, Vec2f(0, 0), Damage, GunHitters::bullet); 
                                }
                                else
                                {
                                    Sound::Play("ArrowHitFlesh.ogg",  CurrentPos, 1.5f); 
                                }
                            }
                            endBullet = true; 
                        }
                    
                    }
                }
                else
                { 
                    if(isClient())
                    {
                        Sound::Play("BulletImpact.ogg", hitpos, 1.5f);
                    }
                    CurrentPos = hitpos;
                    endBullet = true;
                    CParticle@ p = ParticlePixel(CurrentPos, getRandomVelocity(-TrueVelocity.Angle(), 3.0f, 40.0f), SColor(255,244, 220, 66),true);
                    if(p !is null)
                    {
                        p.fastcollision = true;
                        p.bounce = 0.4f;
                    }
                }
            }
        }

        if(endBullet == true)
        {
            TimeLeft = 0;
        }
    }

    void JoinQueue()//every bullet gets forced to join the queue in onRenders, so we use this to calc to position
    {     
        lastDelta += 30 * getRenderDeltaTime();

		Vec2f newPos = Vec2f(lerp(LastPos.x, CurrentPos.x, lastDelta), lerp(LastPos.y, CurrentPos.y, lastDelta));

		f32 angle = Vec2f(CurrentPos.x-newPos.x, CurrentPos.y-newPos.y).getAngleDegrees();


        Vec2f TopLeft  = Vec2f(newPos.x -0.7, newPos.y-3);
        Vec2f TopRight = Vec2f(newPos.x -0.7, newPos.y+3);
        Vec2f BotLeft  = Vec2f(newPos.x +0.7, newPos.y-3);
        Vec2f BotRight = Vec2f(newPos.x +0.7, newPos.y+3);

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

	BulletHolder(){}

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
Vertex[] v_r_reloadBox;
SColor white = SColor(255,255,255,255);
SColor eatUrGreens = SColor(255,0,255,0);

void onRestart(CRules@ this)
{
	Reset(this);
}

void onInit(CRules@ this)
{
	Reset(this);
    this.addCommandID("fireGun");
}

void Reset(CRules@ this)
{
	BulletGrouped.Clean();
	Render::addScript(Render::layer_objects, "BulletMain", "SeeMeFlyyyy", 0.0f);
    Render::addScript(Render::layer_prehud, "BulletMain", "GUIStuff", 0.0f);
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

    v_r_bullet.clear();
    //v_r_fade.clear();
    Render::SetAlphaBlend(true);
    BulletGrouped.FillArray();
    if(v_r_bullet.length() > 0)
    {
        Render::RawQuads("Bullet.png", v_r_bullet);
    }

}

void GUIStuff(int id)//Second new render
{
    renderScreenpls();
}


void renderScreenpls()
{
    ///Bullet Ammo
    CBlob@ holder = getLocalPlayerBlob();           
    if(holder !is null) 
    {
        CBlob@ b = holder.getAttachments().getAttachmentPointByName("PICKUP").getOccupied(); 
        CPlayer@ p = holder.getPlayer(); 

        if(b !is null && p !is null) 
        {
            if(b.exists("clip"))
            {
                if(p.isMyPlayer() && b.isAttached())
                {
                    uint8 clip = b.get_u8("clip");
                    uint8 total = b.get_u8("total");
                    CControls@ controls = getControls();
                    Vec2f pos = Vec2f(0,getScreenHeight()-80);
                    bool render = false;

                    if(controls !is null)
                    {
                        int length = (pos - controls.getMouseScreenPos() - Vec2f(-30,-35)).Length();

                        if(length < 256 && length > 0)
                        {
                            white.setAlpha(length);
                            eatUrGreens.setAlpha(length);
                            render = true;
                        }
                        else
                        {
                            length=-length;
                            if(length < 256 && length > 0)
                            {
                                white.setAlpha(length);
                                eatUrGreens.setAlpha(length);
                                render = true;
                            }
                        }
                    }
                        
                    if(v_r_reloadBox.length() < 1 || render)
                    {
                        if(render)
                        {
                            v_r_reloadBox.clear();
                        }
                        v_r_reloadBox.push_back(Vertex(pos.x+112, pos.y,     1, 1, 0, white)); //top right
                        v_r_reloadBox.push_back(Vertex(pos.x, pos.y,     1, 0, 0, white)); //top left
                        v_r_reloadBox.push_back(Vertex(pos.x, pos.y+80,     1, 0, 1, white)); //bot left
                        v_r_reloadBox.push_back(Vertex(pos.x+112, pos.y+80,     1, 1, 1, white)); //bot right
                    }
                    Render::SetTransformScreenspace();
                    Render::SetAlphaBlend(true);
                    Render::RawQuads("ammoBorder.png", v_r_reloadBox);

                    pos = Vec2f(15,getScreenHeight() - 68);
                    GUI::DrawText(clip+"/"+total, pos, eatUrGreens);

                    pos = Vec2f(15,getScreenHeight() - 58);

                    if(b.get_bool("doReload")) 
                    {
                        GUI::DrawText("Reloading...", pos, eatUrGreens);
                    } 
                    else if(clip == 0 && total > 0 && !b.get_bool("beginReload")) 
                    {
                        GUI::DrawText("Press R to \nreload!", pos, eatUrGreens);
                    } 
                    else if(clip == 0 && total == 0) 
                    {
                        GUI::DrawText("No more \nammo, find \nanother \nweapon!", pos, eatUrGreens);
                    }

                }
            }
            else
            {
                if(v_r_reloadBox.length() > 0)
                {
                    v_r_reloadBox.clear();
                }
            }
        }   
           
    }
}



void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if(cmd == this.getCommandID("fireGun"))
    {
        CBlob@ hoomanBlob = getBlobByNetworkID(params.read_netid());
        CBlob@ gunBlob    = getBlobByNetworkID(params.read_netid());

        if(hoomanBlob !is null && gunBlob !is null)
        {  
            f32 angle = params.read_f32();
            BulletGrouped.AddNewObj(BulletObj(hoomanBlob,gunBlob,angle));
        }
    }
}

float lerp(float v0, float v1, float t)
{
	return (1 - t) * v0 + t * v1;
}

