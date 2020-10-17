//////////////////////////////////////////////////////
//
// Example gun - Vamist
//
// Designed to be new-modder friendly, they only need
// to edit this these settings if they want to make
// new guns
//
// Do not remove StandardFire.as unless you want
// to break everything 
//

#include "StandardFire.as";

// Note to new modders -> 30 ticks a second

const bool  S_LAST_B = false; // Should we spread from the last bullet shot(true) or from the mouse pos(false), only matters for shotguns
const bool  G_RANDOMX= true;  // Should we randomly move mouse x (recoil)
const bool  G_RANDOMY= false; // Should we randomly move mouse y

const u8 FIRE_INTERVAL = 10; // How long do we wait before firing again in ticks
const u8 CLIP        = 255;  // Clip size
const u8 TOTAL       = 255;  // Total ammo count
const u8 RELOAD_TIME = 30;   // How long do we wait in ticks to reload
const u8 BUL_PER_SHOT= 1;    // Bullets per shot | CHANGE B_SPREAD, otherwise both bullets will come out together
const u8 B_SPREAD	 = 0;     // The higher the value, the more 'uncontrolable' bullets get | USEFUL FOR BUL_PER_SHOT INCREASE 
const u8 B_SPEED	 = 35;    // Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV FOR NOW
const u8 B_TTL		 = 120;   // Time To Live, bullets will live for 120 ticks before getting destory IF nothing has been hit

const u16 B_F_COINS= 2;   // Coins on hitting flesh (player or other blobs with 'flesh')
const u16 B_O_COINS= 1;   // Coins on hitting objects (like tanks, boulders etc)
const u16 T_TO_DIE = 150; // how many seconds before gun disspears if it hasnt been picked up in seconds
const u16 G_RECOILT= 10;  // How long should recoil last in ticks
const u16 G_BACK_T = 5;   // Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)

const s16 G_RECOIL = 0; // 0 is off, add's recoil based on number given (try -10 for example)

const float B_DAMAGE = 1.0f; // 1.0f = 1 heart

const Vec2f B_GRAV   = Vec2f(0,0.025); // Bullet gravity drop
const Vec2f B_KB     = Vec2f(0,0);     // KnockBack velocity on hit

const string C_TAG         = "autoRifle";         // Custom TAG, so you can mark different weapons if needed.
const string S_FLESH_HIT   = "ArrowHitFlesh.ogg"; // Sound we make when hitting a fleshy object
const string S_OBJECT_HIT  = "BulletImpact.ogg";  // Sound we make when hitting a wall
const string FIRE_SOUND    = "AssaultFire.ogg";   // Sound we make when pulling the trigger
const string RELOAD_SOUND  = "Reload.ogg";        // Sound we make when we reload

