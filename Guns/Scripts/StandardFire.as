#include "GunStandard.as";
#include "Recoil.as";

const uint8 NO_AMMO_INTERVAL = 35;
u8 reloadCMD;
 

void onInit(CBlob@ this) 
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null) 
	{
		ap.SetKeysToTake(key_action1);
	}

	reloadCMD = this.addCommandID("reload");

	this.set_u8("clip", CLIP);
	this.set_u8("total", TOTAL);

	//Vams new stuff
	this.set_u8("spread"       ,B_SPREAD);
	this.set_u8("TTL"          ,B_TTL);
	this.set_Vec2f("KB"        ,B_KB);
	this.set_Vec2f("grav"      ,B_GRAV);
	this.set_u8("spread"       ,B_SPREAD);
	this.set_bool("sFLB"       ,S_LAST_B);
	this.set_u8("b_count"      ,BUL_PER_SHOT);
	this.set_u8("speed"        ,B_SPEED);
	this.set_f32("damage"      ,B_DAMAGE);
	this.set_u16("coins_flesh" ,B_F_COINS);
	this.set_u16("coins_object",B_O_COINS);
	this.set_string("sound"    ,FIRE_SOUND);
	this.set_s16("recoil"      ,G_RECOIL);
	this.set_bool("recoil_random_x",G_RANDOMX);
	this.set_bool("recoil_random_y",G_RANDOMY);
	this.set_u16("recoilTime"  ,G_RECOILT);
	this.set_u16("recoilBackTime",G_BACK_T);
	this.Tag(C_TAG);

	this.set_string("flesh_hit_sound" ,S_FLESH_HIT);
	this.set_string("object_hit_sound",S_OBJECT_HIT);
	//

	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	this.set_u8("actionInterval", 0);
	this.Tag("gun");
}

void onTick(CBlob@ this) 
{	
	if (this.isAttached()) 
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping); 					   		
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");	   		
		CBlob@ holder = point.getOccupied();												   
		if (holder !is null) 
		{ 
			CSprite@ sprite = this.getSprite();
			
			Vec2f aimvector = holder.getAimPos() - this.getPosition();
			f32 aimangle = getAimAngle(this,holder);

			// fire + reload
			if(holder.isMyPlayer())	
			{
				//print(aimvector + " | " + aimangle);
				//check for clip amount error
				if(this.get_u8("clip") > CLIP) 
				{
					this.set_u8("clip", 0);
				}
				
				CControls@ controls = holder.getControls();

				if(controls !is null) 
				{
					if(controls.isKeyJustPressed(KEY_KEY_R) &&
						!this.get_bool("beginReload") &&
						this.get_u8("clip") < CLIP) 
					{
						this.set_bool("beginReload", true);				
					}
				}
				uint8 actionInterval = this.get_u8("actionInterval");

				if (actionInterval > 0) 
				{
					actionInterval--;			
				} 
				else if(this.get_bool("beginReload") && 
					this.get_u8("total") > 0) 
				{
						actionInterval = RELOAD_TIME;
						this.set_bool("beginReload", false);
						this.set_bool("doReload", true);
				} 
				else if(this.get_bool("doReload")) 
				{
					reload(this, holder);
					this.set_bool("doReload", false);
				} 
				else if (point.isKeyPressed(key_action1))
				{
					if(this.isInWater()) 
					{
						sprite.PlaySound("EmptyClip.ogg");
						actionInterval = NO_AMMO_INTERVAL;
					}				
					else if(this.get_u8("clip") > 0) 
					{
						actionInterval = FIRE_INTERVAL;
						Vec2f fromBarrel = Vec2f((holder.isFacingLeft() ? -1 : 1),0);
						fromBarrel = fromBarrel.RotateBy(aimangle);
						fromBarrel *= 7;
						//print(fromBarrel + " ");
						/*if(G_RECOIL > 0)
						{
							CControls@ c = holder.getControls();
							if(c !is null)
							{
								c.setMousePosition(c.getMouseScreenPos() + Vec2f(0,-G_RECOIL));
								ShakeScreen(Vec2f(0,-G_RECOIL), 150, sprite.getWorldTranslation());
							}
						}*/
						if(BUL_PER_SHOT > 1)
						{
							shootShotgun(this.getNetworkID(), aimangle, holder.getNetworkID(),sprite.getWorldTranslation() + fromBarrel);
						}
						else
						{
							if(B_SPREAD != 0)
							{
								aimangle += XORRandom(2) != 0 ? -XORRandom(B_SPREAD) : XORRandom(B_SPREAD);
							}
							shootGun(this.getNetworkID(), aimangle, holder.getNetworkID(),sprite.getWorldTranslation() + fromBarrel);
						}
					}
					else if(this.get_u8("clip") == 0 && this.get_u8("clickReload") == 1)
					{
						actionInterval = RELOAD_TIME;
						this.set_bool("beginReload", false);
						this.set_bool("doReload", true);
					}
					else if(!this.get_bool("beginReload")) 
					{
						sprite.PlaySound("EmptyClip.ogg");
						actionInterval = NO_AMMO_INTERVAL;
						this.set_u8("clickReload",1);
					}
				}

				this.set_u8("actionInterval", actionInterval);	
			}
			sprite.ResetTransform();
			sprite.RotateBy( aimangle, holder.isFacingLeft() ? Vec2f(-3,3) : Vec2f(3,3) );

		}
	} 
	else 
	{
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping; 
	}	
}

f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
 	Vec2f aimvector = holder.getAimPos() - this.getPosition();//TODO this is a duplicate
	return holder.isFacingLeft() ? -aimvector.Angle()+180.0f : -aimvector.Angle();
}

f32 getAimAngle2(CBlob@ this, CBlob@ player)
{
	bool facing_left = this.isFacingLeft();
	
	Vec2f dir = player.getAimPos() - this.getPosition();
	f32 angle = dir.Angle();
	dir.Normalize();
	
	bool failed = true;

	if (player !is null)
	{
		Vec2f aim_vec = player.getPosition() - player.getAimPos();

		if (this.isAttached())
		{
			//print("hi");
			if (facing_left) { 
				aim_vec.x = -aim_vec.x; 
				angle = (-(aim_vec).getAngle() + 180.0f);
			}
			else
			{
				angle = (-(aim_vec).getAngle() + 180.0f);
			}
		}
		else
		{
			if ((!facing_left && aim_vec.x < 0) ||
					(facing_left && aim_vec.x > 0))
			{
				if (aim_vec.x > 0) { aim_vec.x = -aim_vec.x; }

				angle = (-(aim_vec).getAngle() + 180.0f);
				//angle = Maths::Max(-90.0f, Maths::Min(angle, 50.0f));
			}
			else
			{
				this.SetFacingLeft(!facing_left);
			}
		}
	}

	return angle;
}