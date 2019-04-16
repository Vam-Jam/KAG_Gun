
#include "StandardFire.as";
const uint8 FIRE_INTERVAL = 1;
const uint8 CLIP        = 47; //Used
const uint8 TOTAL       = 188; //Used
const uint8 RELOAD_TIME = 25; //Used, reload timer (in ticks)
const uint8 BUL_PER_SHOT= 1; //Shots per bullet | CHANGE B_SPREAD, otherwise both bullets will come out together

//Contact vam for default values
//or keep a fresh copy

//NEW BULLET PROPS
const int8  B_SPREAD = 10; //the higher the value, the more 'uncontrolable' bullets get
const Vec2f B_GRAV   = Vec2f(0,0.025); //Bullet gravity drop \|/
const int8  B_SPEED  = 17; //Bullet speed, STRONGLY AFFECTED/EFFECTS B_GRAV
const int8  B_TTL    = 100; //TTL = Time To Live, bullets will live for 120 ticks before getting destory IF nothing has been hit
const float B_DAMAGE = 0.5; //1 heart
const Vec2f B_KB     = Vec2f(0,0); //KnockBack velocity on hit
const int   B_F_COINS= 0; //Coins on hitting flesh (player or other blobs with 'flesh')
const int   B_O_COINS= 0; //Coins on hitting objects (like tanks, boulders etc)
const int   T_TO_DIE = 150; //how many seconds before gun disspears if it hasnt been picked up
const string C_TAG   = "autoRifle"; //Custom TAG, can be used later on ingame for certain ammos etc
const bool  S_LAST_B = true; //Should we spread from the last bullet shot(true) or from the mouse pos(false), only matters for shotguns
const int   G_RECOIL= -10; //0 is default, adds recoil aiming up
const bool  G_RANDOMX= true;//Should we randomly move x
const bool  G_RANDOMY= false;//Should we randomly move y, it ignores g_recoil
const int   G_RECOILT= 5; //How long should recoil last, 10 is default, 30 = 1 second (like ticks)
const int   G_BACK_T = 2; //Should we recoil the arm back time? (aim goes up, then back down with this, if > 0, how long should it last)


const string S_FLESH_HIT = "ArrowHitFlesh.ogg"; //Sound we make when hitting a fleshy object
const string S_OBJECT_HIT= "BulletImpact.ogg"; //Sound we make when hitting a wall

const string AMMO_TYPE   = "bullet"; //Used i think?
const string AMMO_SPRITE = "Bullet.png"; //Unused
const bool SNIPER        = false; //Unused
const uint8 SNIPER_TIME  = 0; //Unused

const string FIRE_SOUND    = "smg2.ogg"; //Used
const string RELOAD_SOUND  = "Reload.ogg"; //Used

const float BULLET_OFFSET_X = 20; // ^
const float BULLET_OFFSET_Y = 0; // ^