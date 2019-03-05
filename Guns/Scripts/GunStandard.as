void shoot(CBlob@ this, const f32 aimangle, CBlob@ holder) 
{
	CRules@ rules = getRules();
	CBitStream params;

	params.write_netid(holder.getNetworkID());
	params.write_netid(this.getNetworkID());
	params.write_f32(aimangle);
	rules.SendCommand(rules.getCommandID("fireGun"), params);
}

void reload(CBlob@ this, CBlob@ holder) 
{
	CBitStream params;
	params.write_Vec2f(this.getPosition());
	params.write_netid(holder.getNetworkID());
	this.SendCommand(this.getCommandID("reload"), params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) 
{
	CSprite@ sprite = this.getSprite();
	if(cmd == this.getCommandID("reload")) 
	{
		int currentTotalAmount = this.get_u8("total");
		int currentClipAmount = this.get_u8("clip");
		int neededClipAmount = CLIP - currentClipAmount;
		
		if(currentTotalAmount >= neededClipAmount) 
		{
			this.set_u8("clip", CLIP);
			currentTotalAmount -= neededClipAmount;
			this.set_u8("total", currentTotalAmount);
		} 
		else 
		{
			this.set_u8("clip", currentTotalAmount);
			currentTotalAmount = 0;
			this.set_u8("total", currentTotalAmount);
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) 
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer(attached.getPlayer());

	CSprite@ sprite = this.getSprite();
	sprite.PlaySound("PickupGun.ogg");
	this.server_SetTimeToDie(-1);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) 
{
    CSprite@ sprite = this.getSprite();
    sprite.ResetTransform();
    sprite.animation.frame = 0;
	u8 clip = this.get_u8("clip");
	u8 total = this.get_u8("total");

    Vec2f aimvector = detached.getAimPos() - this.getPosition();
 	f32 angle = 0 - aimvector.Angle() + (this.isFacingLeft() == true ? 180.0f : 0);
    this.setAngleDegrees(angle);

    //Reset reload and interval
    this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	//this.set_u8("actionInterval", 0);

	if(clip < CLIP && total <= TOTAL / 1.2)
	{
		this.server_SetTimeToDie(T_TO_DIE);
	}
}
