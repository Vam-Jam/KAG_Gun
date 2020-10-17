//////////////////////////////////////////////////////
//
//  GunStandard.as - Vamist
//
//  Handles shooting bullets, when to reload, ammo
//  count and despawning
//

void shootGun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);

	rules.SendCommand(rules.getCommandID("fireGun"), params);
}

void shootShotgun(const u16 gunID, const f32 aimangle, const u16 hoomanID, const Vec2f pos) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(hoomanID);
	params.write_netid(gunID);
	params.write_f32(aimangle);
	params.write_Vec2f(pos);

	rules.SendCommand(rules.getCommandID("fireShotgun"), params);
}


void reload(CBlob@ this, CBlob@ holder) 
{
	CBitStream params;

	params.write_Vec2f(this.getPosition());
	params.write_netid(holder.getNetworkID());

	this.SendCommand(this.getCommandID("reload"), params);

	this.set_u8("clickReload",0);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	if (cmd == this.getCommandID("reload")) 
	{
		int currentTotalAmount = this.get_u8("total");
		int currentClipAmount = this.get_u8("clip");
		int neededClipAmount = CLIP - currentClipAmount;

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			sprite.PlaySound(RELOAD_SOUND);
		}
		
		if (currentTotalAmount >= neededClipAmount) 
		{
			this.set_u8("clip", CLIP);
			currentTotalAmount -= neededClipAmount;
		} 
		else 
		{
			this.set_u8("clip", currentTotalAmount);
			currentTotalAmount = 0;
		}

		this.set_u8("total", currentTotalAmount);
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	// Start ticking again
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer(attached.getPlayer());
	
	if (isClient()) 
	{
		CSprite@ sprite = this.getSprite();
		sprite.PlaySound("PickupGun.ogg");
	}

	// Stop time to die to -1 so we should no longer respawn 
	// (NOTE: SOME GUNS DESPAWN, WILL WORK AROUND ONE DAY)
	this.server_SetTimeToDie(-1);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) 
{
	if (isServer())
	{
		CSprite@ sprite = this.getSprite();
		sprite.ResetTransform();
		sprite.animation.frame = 0;
	}
	
	// Set angle when dropped instead of being left or right
	Vec2f aimvector = detached.getAimPos() - this.getPosition();
 	f32 angle = 0 - aimvector.Angle() + (this.isFacingLeft() == true ? 180.0f : 0);
	this.setAngleDegrees(angle);

	// Reset reload and interval
	this.set_bool("beginReload", false);
	this.set_bool("doReload", false);

	// Despawn after a set amount of time
	u8 total = this.get_u8("total");

	if(total == 0)
	{
		this.server_Die();
	}
	else if(total <= TOTAL / 1.2)
	{
		this.server_SetTimeToDie(T_TO_DIE);
	}
}
