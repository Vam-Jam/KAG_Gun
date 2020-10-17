#include "GunHitters.as";
#include "BulletTrails.as";
#include "BulletClass.as";
#include "BulletCase.as";

//todo
//u
//v
//vertex textures for bullets
//learn it 
//
//
//
//on join sync bullet count to the new person for each gun, or existing?

Random@ r = Random(12345);//amazing
//used to sync numbers between clients *assuming* they have run it the same amount of times 
//as everybody else
//(which they should UNLESS kag breaks with bad deltas or other weird net issues)


BulletHolder@ BulletGrouped = BulletHolder();
Vertex[] v_r_bullet;
Vertex[] v_r_fade;
Vertex[] v_r_reloadBox;
SColor white = SColor(255,255,255,255);
SColor eatUrGreens = SColor(255,0,255,0);
int FireGunID;
int FireShotgunID;

void onInit(CRules@ this)
{
	Reset(this);
	Render::addScript(Render::layer_postworld, "BulletMain", "SeeMeFlyyyy", 0.0f);
	Render::addScript(Render::layer_prehud, "BulletMain", "GUIStuff", 0.0f);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onTick(CRules@ this)
{
	BulletGrouped.FakeOnTick(this);
}

void Reset(CRules@ this)
{
	r.Reset(12345);
	FireGunID     = this.addCommandID("fireGun");
	FireShotgunID = this.addCommandID("fireShotgun");
	v_r_bullet.clear();
	v_r_fade.clear();
}

void SeeMeFlyyyy(int id)//New onRender
{
	CMap@ map = getMap();
	CRules@ rules = getRules();
	ok(map,rules);
}


void GUIStuff(int id)//Second new render
{
	renderScreenpls();
}


void ok(CMap@ map,CRules@ rules)//Bullets
{

	//v_r_fade.clear();
	//Render::SetAlphaBlend(true);
	BulletGrouped.FillArray();//fill up the vortex with what we need
	if(v_r_bullet.length() > 0)//if we didnt do that no reason
	{
		Render::RawQuads("Bullet.png", v_r_bullet);//r e n d e r my child
		v_r_bullet.clear();//and we clean all
	}

	/*if(v_r_fade.length() > 0)//same as above but not in use
	{
		Render::RawQuads("fade.png", v_r_fade);
		v_r_fade.clear();
	}*/

}

void renderScreenpls()//GUI
{
	///Bullet Ammo
	CBlob@ holder = getLocalPlayerBlob();           
	if(holder !is null) 
	{
		CBlob@ b = holder.getAttachments().getAttachmentPointByName("PICKUP").getOccupied(); 
		CPlayer@ p = holder.getPlayer(); //get player holding this

		if(b !is null && p !is null) 
		{
			if(b.exists("clip"))//make sure its a valid gun
			{
				if(p.isMyPlayer() && b.isAttached())
				{
					uint8 clip = b.get_u8("clip");
					uint8 total = b.get_u8("total");//get clip and ammo total for easy access later
					CControls@ controls = getControls();
					Vec2f pos = Vec2f(0,getScreenHeight()-80);//controls for screen position
					bool render = false;//used to save render time (more fps basically)

					if(controls !is null)
					{
						int length = (pos - controls.getMouseScreenPos() - Vec2f(-30,-35)).Length();
						//get length for 'fancy' invisiblty when mouse goes near it

						if(length < 256 && length > 0)//are we near it?
						{
							white.setAlpha(length);
							eatUrGreens.setAlpha(length);
							render = true;
						}
						else//check the reverse
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
						
					if(v_r_reloadBox.length() < 1 || render)//is it time to render?
					{
						if(render)//lets clear only IF we need to
						{
							v_r_reloadBox.clear();
						}
						v_r_reloadBox.push_back(Vertex(pos.x+112, pos.y,    0, 1, 0, white)); //top right
						v_r_reloadBox.push_back(Vertex(pos.x, pos.y,        0, 0, 0, white)); //top left
						v_r_reloadBox.push_back(Vertex(pos.x, pos.y+80,     0, 0, 1, white)); //bot left
						v_r_reloadBox.push_back(Vertex(pos.x+112, pos.y+80, 0, 1, 1, white)); //bot right
					}
					Render::SetTransformScreenspace();//set position for render
					Render::SetAlphaBlend(true);//since we are going to be doing the invisiblity thing
					Render::RawQuads("ammoBorder.png", v_r_reloadBox);//render!

					pos = Vec2f(15,getScreenHeight() - 68);//positions for the GUI
					GUI::DrawText(clip+"/"+total, pos, eatUrGreens);

					pos = Vec2f(15,getScreenHeight() - 58);

					if(b.get_bool("doReload")) 
					{
						GUI::DrawText("Reloading...", pos, eatUrGreens);
					} 
					else if(clip == 0 && total > 0 && !b.get_bool("beginReload")) 
					{
						GUI::DrawText("Press R to \nreload or \nshoot again!", pos, eatUrGreens);
					} 
					else if(clip == 0 && total == 0) 
					{
						GUI::DrawText("No more \nammo, find \nanother \nweapon!", pos, eatUrGreens);
					}

				}
			}
			else
			{
				if(v_r_reloadBox.length() > 0)//doesnt run anyway, cant remember why this is here
				{
					v_r_reloadBox.clear();//so its best not to remove it
				}
			}
		}   
		   
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if(cmd == FireGunID)
	{
		CBlob@ hoomanBlob = getBlobByNetworkID(params.read_netid());
		CBlob@ gunBlob    = getBlobByNetworkID(params.read_netid());

		if(hoomanBlob !is null && gunBlob !is null)
		{  
			f32 angle = params.read_f32();
			const Vec2f pos = params.read_Vec2f();
			BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,angle,pos);
			BulletGrouped.AddNewObj(bullet);

			gunBlob.sub_u8("clip",1);
			gunBlob.getSprite().PlaySound(gunBlob.get_string("sound"));

			if(hoomanBlob.isFacingLeft())
			{
				f32 oAngle = (angle % 360) + 180;
				ParticleCase2("Case.png",pos,oAngle);
			}
			else
			{
				ParticleCase2("Case.png",pos,angle);
			}

			if(isClient())
			{
				CBlob@ localBlob = getLocalPlayerBlob();
				if(localBlob != null && localBlob is hoomanBlob)//if we are this blob
				{//RECOIL TIME
					//(CBlob@ blob,Vec2f velocity, u16 TimeToEnd, Vec2f startPos)
					//	this.set_u16("recoil"      ,G_RECOIL);
					const int recoil = gunBlob.get_s16("recoil");
					const bool rx = gunBlob.get_bool("recoil_random_x");
					const bool ry = gunBlob.get_bool("recoil_random_y");
					const int recoilTime = gunBlob.get_u16("recoilTime");
					const int recoilBackTime = gunBlob.get_u16("recoilBackTime");
					Recoil@ coil = Recoil(localBlob,recoil,recoilTime,recoilBackTime,rx,ry);
					BulletGrouped.NewRecoil(@coil);
				}
				//BulletGrouped.addNewParticle(ParticlePixelUnlimited(newPos,Vec2f(0,0),
					//SColor(255,255,100,100),false),0);
			}
		}
	}
	else if(cmd == FireShotgunID)
	{
		CBlob@ hoomanBlob = getBlobByNetworkID(params.read_netid());  
		CBlob@ gunBlob    = getBlobByNetworkID(params.read_netid());

		if(hoomanBlob !is null && gunBlob !is null)
		{  
			const f32 angle  = params.read_f32();
			const Vec2f pos  = params.read_Vec2f();
			const u8 spread  = gunBlob.get_u8("spread");
			const u8 b_count = gunBlob.get_u8("b_count");
			const bool sFLB  = gunBlob.get_bool("sFLB");
			
			gunBlob.sub_u8("clip",b_count);
			gunBlob.getSprite().PlaySound(gunBlob.get_string("sound"));
			
			if(sFLB)
			{
				f32 tempAngle = angle;

				for(u8 a = 0; a < b_count; a++)
				{
					tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(spread) : r.NextRanged(spread);
					//print(tempAngle + "");
					BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,tempAngle,pos);
					BulletGrouped.AddNewObj(bullet);
				}
			}
			else
			{
				for(u8 a = 0; a < b_count; a++)
				{
					f32 tempAngle = angle;
					tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(spread) : r.NextRanged(spread);
					BulletObj@ bullet = BulletObj(hoomanBlob,gunBlob,tempAngle,pos);
					BulletGrouped.AddNewObj(bullet);
				}
			}

			if(hoomanBlob.isFacingLeft())
			{
				f32 oAngle = (angle % 360) + 180;
				ParticleCase2("Case.png",pos,oAngle);
			}
			else
			{
				ParticleCase2("Case.png",pos,angle);
			}

			if(isClient())
			{
				CBlob@ localBlob = getLocalPlayerBlob();
				if(localBlob != null && localBlob is hoomanBlob)//if we are this blob
				{//RECOIL TIME
					//(CBlob@ blob,Vec2f velocity, u16 TimeToEnd, Vec2f startPos)
					//	this.set_u16("recoil"      ,G_RECOIL);
					const int recoil = gunBlob.get_s16("recoil");
					const bool rx = gunBlob.get_bool("recoil_random_x");
					const bool ry = gunBlob.get_bool("recoil_random_y");
					const int recoilTime = gunBlob.get_u16("recoilTime");
					const int recoilBackTime = gunBlob.get_u16("recoilBackTime");
					Recoil@ coil = Recoil(localBlob,recoil,recoilTime,recoilBackTime,rx,ry);
					BulletGrouped.NewRecoil(@coil);
				}
			}
			
		}

		/*f32 tempAngle = aimangle;
		for(uint8 a = 0; a < BUL_PER_SHOT; a++)
		{
			aimangle += XORRandom(2) == 0 ? -XORRandom(B_SPREAD) : XORRandom(B_SPREAD);
			shoot(this, aimangle, holder);
		}*/
	}
}