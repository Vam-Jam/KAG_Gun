#include "GunStandard.as";

const uint8 NO_AMMO_INTERVAL = 35;

void onInit(CBlob@ this) 
{
    AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
    if (ap !is null) 
    {
        ap.SetKeysToTake(key_action1);
    }

    this.addCommandID("shoot");
    this.addCommandID("reload");

    this.set_u8("clip", CLIP);
    this.set_u8("total", TOTAL);
	
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
			
 			//f32 aimangle = 0 - aimvector.Angle() + (this.isFacingLeft() == true ? 180.0f : 0);
			//const f32 aimangle = getAimAngle(this,holder);
			f32 aimangle = getAimAngle(this,holder);

	        // rotate towards mouse cursor
	        sprite.ResetTransform();
	        sprite.RotateBy( aimangle, holder.isFacingLeft() ? Vec2f(-3,3) : Vec2f(3,3) );
	        sprite.animation.frame = 0;

	        // fire + reload
	        if(holder.isMyPlayer())	
	        {
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
					sprite.PlaySound(RELOAD_SOUND);
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
						sprite.PlaySound(FIRE_SOUND);
						shoot(this, aimangle, holder);
						actionInterval = FIRE_INTERVAL;
						this.sub_u8("clip",1);
					}
					else if(!this.get_bool("beginReload")) 
					{
						sprite.PlaySound("EmptyClip.ogg");
						actionInterval = NO_AMMO_INTERVAL;
					}
				}

				this.set_u8("actionInterval", actionInterval);	
			}
		}
    } 
    else 
    {
		this.getCurrentScript().runFlags |= Script::tick_not_sleeping; 
    }			
}

f32 getAimAngle( CBlob@ this, CBlob@ holder )
{
 	Vec2f aimvector = holder.getAimPos() - this.getPosition();
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
			print("hi");
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