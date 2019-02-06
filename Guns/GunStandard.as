#include "BulletMain.as";


void shoot(CBlob@ this, const f32 aimangle, CBlob@ holder) {
	CRules@ rules = getRules();
	CBitStream params;
	params.write_Vec2f(this.getPosition());
	params.write_f32(aimangle);
	params.write_bool(this.isFacingLeft());
	params.write_u8(this.getTeamNum());
	params.write_netid(holder.getNetworkID());
	rules.SendCommand(rules.getCommandID("addTest"), params);
}

void reload(CBlob@ this, CBlob@ holder) {
	CBitStream params;
	params.write_Vec2f(this.getPosition());
	params.write_netid(holder.getNetworkID());
	this.SendCommand(this.getCommandID("reload"), params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params) {
	CSprite@ sprite = this.getSprite();

	if(cmd == this.getCommandID("shoot")) {
		/*uint8 currentClipAmount = this.get_u8("clip");
		currentClipAmount--;
		this.set_u8("clip", currentClipAmount);

		Vec2f pos = params.read_Vec2f();
		f32 angle = params.read_f32();
		CBlob@ holder = getBlobByNetworkID(params.read_netid());
		if(holder !is null) {
			Vec2f velocity(1,0);
			if(getNet().isServer())
			{
				CBlob@ ammo = server_CreateBlob(AMMO_TYPE);
				if(ammo !is null) {
					Vec2f offset(BULLET_OFFSET_X, BULLET_OFFSET_Y);
					
					if(this.isFacingLeft()) {
						offset.RotateBy(angle, Vec2f(-8,-2));
						ammo.setPosition(pos - offset);				
						angle += 180.0f;
					} else {
						offset.RotateBy(angle, Vec2f(-8,-2));
						ammo.setPosition(pos + offset);		
					}

					velocity.RotateBy(angle);
					ammo.setVelocity( holder.getVelocity() + velocity * PROJECTILE_SPEED );

					ammo.set_f32("dmg", BULLET_DAMAGE);
					ammo.IgnoreCollisionWhileOverlapped(holder);
					ammo.SetDamageOwnerPlayer(holder.getPlayer());
					ammo.server_setTeamNum(holder.getTeamNum());
					ammo.server_SetTimeToDie(TIME_TILL_DIE);

					//For a shorter fuse on bombs
					ammo.set_s32("bomb_timer", getGameTime()+20);
				}
			
			}
			
			sprite.PlaySound(FIRE_SOUND);

			// animate muzzle fire
			sprite.animation.frame = 1 + XORRandom(3);
			// pull back
			sprite.TranslateBy(RECOIL);
			// shell
			Vec2f velr = getRandomVelocity( 30, 4.3f, 40.0f) *0.1f;
			ParticlePixel( this.getPosition(), Vec2f( velocity.y, velocity.x
				*(this.isFacingLeft() ? 5.0f : -5.0f) ) + velr, SColor(255,255,197,47), true );*/

			/*Vec2f pos = params.read_Vec2f();
			f32 angle = params.read_f32();
			BulletObj@ tempObj = BulletObj(pos, angle);
			BulletGrouped.AddNewObj(tempObj);
			print(BulletGrouped.bullets.length() + " aa");*/
	} else if(cmd == this.getCommandID("reload")) {
		int currentTotalAmount = this.get_u8("total");
		int currentClipAmount = this.get_u8("clip");
		int neededClipAmount = CLIP - currentClipAmount;
		
		if(currentTotalAmount >= neededClipAmount) {
			this.set_u8("clip", CLIP);
			currentTotalAmount -= neededClipAmount;
			this.set_u8("total", currentTotalAmount);
		} else {
			this.set_u8("clip", currentTotalAmount);
			currentTotalAmount = 0;
			this.set_u8("total", currentTotalAmount);
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint) {
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
	this.SetDamageOwnerPlayer(attached.getPlayer());

	CSprite@ sprite = this.getSprite();
	sprite.PlaySound("PickupGun.ogg");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @detachedPoint) {
    CSprite@ sprite = this.getSprite();
    sprite.ResetTransform();
    sprite.animation.frame = 0;

     Vec2f aimvector = detached.getAimPos() - this.getPosition();
 	f32 angle = 0 - aimvector.Angle() + (this.isFacingLeft() == true ? 180.0f : 0);
    this.setAngleDegrees(angle);

    //Reset reload and interval
    this.set_bool("beginReload", false);
	this.set_bool("doReload", false);
	this.set_u8("actionInterval", 0);

	if(this.get_u8("clip") == 0 && this.get_u8("total") == 0) {
		this.server_SetTimeToDie(5);
	}
}

void onRender(CSprite@ this) {
	const SColor RED = SColor(255, 150, 0, 0);
	
	CBlob@ b = this.getBlob();
	CBlob@ holder = b.getAttachments().getAttachmentPointByName("PICKUP").getOccupied();	   		
    if(holder !is null) {
		CPlayer@ p = holder.getPlayer(); 

		if(b !is null && p !is null) {
			if(p.isMyPlayer() && b.isAttached()) {
				uint8 clip = b.get_u8("clip");
				uint8 total = b.get_u8("total");
					
				Vec2f pos = Vec2f(getScreenWidth()/30,getScreenHeight()/5);
				GUI::DrawText(clip + "/" + total, pos,
					Vec2f(pos.x + 40, pos.y), color_black, true, true, true);

				f32 posY = getScreenHeight()/3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f;
				if(b.get_bool("doReload")) {
					pos = Vec2f(getScreenWidth() / 2 - 60, posY);
					GUI::DrawText("Reloading...", pos, RED);
				} else if(clip == 0 && total > 0 && !b.get_bool("beginReload")) {
					pos = Vec2f(getScreenWidth() / 2 - 60, posY);
					GUI::DrawText("Press R to reload!", pos, RED);
				} else if(clip == 0 && total == 0) {
					pos = Vec2f(getScreenWidth() / 2 - 110, posY);
					GUI::DrawText("No more ammo, find another weapon!", pos, RED);
				}
			}
		}
	}
}