

//Main classes for bullets
#include "BulletCase.as";

const SColor trueWhite = SColor(255,255,255,255);


class BulletObj
{
    CBlob@ hoomanShooter;
    CBlob@ gunBlob;

    BulletFade@ Fade;

    Vec2f TrueVelocity;
    Vec2f CurrentPos;
    Vec2f liTopRight;
    Vec2f liBotRight;
    Vec2f liTopLeft;
    Vec2f liBotLeft;
    Vec2f BulletGrav;
    Vec2f RenderPos;
    Vec2f LastPos;
    Vec2f Gravity;
    Vec2f KB;

    f32 StartingAimPos;
    f32 lastDelta;
    f32 Damage;

    u8 TeamNum;
    u8 Speed;

    string FleshHitSound;
    string ObjectHitSound;

    s8 TimeLeft;

    bool FacingLeft;
    
	BulletObj(CBlob@ humanBlob, CBlob@ gun, f32 angle, Vec2f pos)
	{
        CurrentPos = pos;
        FacingLeft = humanBlob.isFacingLeft();
        BulletGrav = gun.get_Vec2f("grav");
        Damage   = gun.get_f32("damage");
        TeamNum  = gun.getTeamNum();
        TimeLeft = gun.get_u8("TTL");
        KB       = gun.get_Vec2f("KB");
        Speed    = gun.get_u8("speed");
        FleshHitSound  = gun.get_string("flesh_hit_sound");
        ObjectHitSound = gun.get_string("object_hit_sound");
        @hoomanShooter = humanBlob;
        StartingAimPos = angle;
        LastPos    = CurrentPos;
		RenderPos  = CurrentPos;

        @gunBlob   = gun;
        lastDelta = 0;
        @Fade = BulletGrouped.addFade(CurrentPos);
	}


    void SetStartAimPos(Vec2f aimPos, bool isFacingLeft)
    {
        Vec2f aimvector = aimPos - CurrentPos;
        StartingAimPos = isFacingLeft ? -aimvector.Angle()+180.0f : -aimvector.Angle();
    }

    void onFakeTick(CMap@ map)
    {
        //map.debugRaycasts = true;
        //Render stuff
        lastDelta = 0;
        LastPos = CurrentPos;
        TimeLeft--;
        Gravity -= BulletGrav;
        const f32 angle = StartingAimPos * (FacingLeft ? 1 : 1);
        Vec2f dir = Vec2f((FacingLeft ? -1 : 1), 0.0f).RotateBy(angle);
        Vec2f temp = CurrentPos + Vec2f(1 * (FacingLeft ? -1 : 1), 1);
        CurrentPos = ((dir * Speed) - (Gravity * Speed)) + CurrentPos;
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
                    if (blob.getTeamNum() != TeamNum)
                    {    
                        
                        if(blob.getName() == "stone_door" || blob.getName() == "wooden_door" || blob.getName() == "trap_block")  
                        {
                            if(blob.isCollidable())
                            {
                                CurrentPos = hitpos;
                                endBullet = true;
                                break;
                            }
                        }    
                        else if(blob.hasTag("flesh") && blob.isCollidable() || blob.hasTag("vehicle"))
                        {
                            CurrentPos = hitpos;
                            if(!blob.hasTag("invincible") && !blob.hasTag("seated"))
                            {
                                if(isServer())
                                {
                                    CPlayer@ p = hoomanShooter.getPlayer();
                                    int coins = 0;
                                    hoomanShooter.server_Hit(blob, CurrentPos, Vec2f(0, 0), Damage, GunHitters::bullet); 
                                    
                                    if(blob.hasTag("flesh"))
                                    {
                                        coins = gunBlob.get_u16("coins_flesh");
                                    }
                                    else
                                    {
                                        coins = gunBlob.get_u16("coins_object");
                                    }

                                    if(p !is null)
                                    {
                                        p.server_setCoins(p.getCoins() + coins);
                                    }
                                }
                                else
                                {
                                    Sound::Play(FleshHitSound,  CurrentPos, 1.5f); 
                                }

                            }
                            endBullet = true; 
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
                }
                else
                { 
                    if(isServer())
                    {
                        Tile tile = map.getTile(hitpos);
                        switch(tile.type)
                        {
                            case 196:
                            case 200:
                            case 201:
                            case 202:
                            case 203:
                            {
                                map.server_DestroyTile(hitpos, 1.0f);
                            }
                            break;
                        }
                    }
                    else
                    {
                        Sound::Play(ObjectHitSound, hitpos, 1.5f);
                    }

                    CurrentPos = hitpos;
                    endBullet = true;
                    //ParticleFromBullet("Bullet.png",CurrentPos,-TrueVelocity.Angle());
                    ParticleBullet(CurrentPos, TrueVelocity);
                }
            }
        }

        if(endBullet == true)
        {
            TimeLeft = 0;
        }

        //Fade
        //Fade.BotLeft = CurrentPos;
        //Fade.BotRight = CurrentPos; 
        //End
    }

    void JoinQueue()//every bullet gets forced to join the queue in onRenders, so we use this to calc to position
    {    
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

        /*if(FacingLeft)
        {
            Fade.JoinQueue(TopLeft,TopRight);
        }
        else
        {
            //Fade.JoinQueue(newPos,BotRight);
        }*/


        v_r_bullet.push_back(Vertex(TopLeft.x,  TopLeft.y,      0, 0, 0,   trueWhite)); //top left
		v_r_bullet.push_back(Vertex(TopRight.x, TopRight.y,     0, 1, 0,   trueWhite)); //top right
		v_r_bullet.push_back(Vertex(BotRight.x, BotRight.y,     0, 1, 1, trueWhite)); //bot right
		v_r_bullet.push_back(Vertex(BotLeft.x,  BotLeft.y,      0, 0, 1, trueWhite)); //bot left
        lastDelta += 30 * getRenderExactDeltaTime();
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
    }

    BulletFade addFade(Vec2f spawnPos)
    {
        BulletFade@ fadeToAdd = BulletFade(spawnPos);
        fade.push_back(fadeToAdd);
        return fadeToAdd; 
    }
    
    void FillArray()
    {
        for(int a = 0; a < bullets.length(); a++)
        {
            bullets[a].JoinQueue();
        }

        /*for(int a = 0; a < fade.length(); a++)
        {
            if(fade[a].TimeLeft < 1)
            {
                fade.removeAt(a);
                continue;
            }
            //fade[a].JoinQueue();
        }*/
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


const float lerp(float v0, float v1, float t)
{
	//return (1 - t) * v0 + t * v1; //Golden guys version of lerp, worked but led to 'big gaps'
    return v0 + t*(v1 - v0); //Vamists version
}

