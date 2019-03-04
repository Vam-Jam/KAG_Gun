#include "Hitters.as";
#include "StandardFire.as";

const uint8 FIRE_INTERVAL    = 10; //Used maybe?
const float BULLET_DAMAGE    = 1;   //Unused
const uint8 PROJECTILE_SPEED = 20;  //Unused
const float TIME_TILL_DIE    = 0.3; //Unused

const uint8 CLIP        = 255; //Used
const uint8 TOTAL       = 255; //Used
const uint8 RELOAD_TIME = 30; //Used, reload timer (in ticks)


//NEW BULLET PROPS
const int8  B_SPREAD = 0; //the higher the value, the more 'uncontrolable' bullets get
const Vec2f B_SPEED  = Vec2f(0,0.025); //DEFAULT, bullet stuff is very 'weird' currently, use and expirement
const int8  B_TTL    = 120; //TTL = Time To Live, bullets will live for 120 ticks before getting destory IF nothing has been hit
const float B_DAMAGE = 1; //1 heart
const Vec2f B_KB     = Vec2f(0,0); //KnockBack velocity on hit
const int   B_F_COINS= 2; //Coins on hitting flesh (player or other blobs with 'flesh')
const int   B_O_COINS= 1; //Coins on hitting objects (like tanks, boulders etc)


const string AMMO_TYPE   = "bullet"; //Used i think?
const string AMMO_SPRITE = "Bullet.png"; //Unused
const bool SNIPER        = false; //Unused
const uint8 SNIPER_TIME  = 0; //Unused

const string FIRE_SOUND    = "AssaultFire.ogg"; //Used
const string RELOAD_SOUND  = "Reload.ogg"; //Used

const Vec2f RECOIL = Vec2f(1.0f,0.0); //Unused probably
const float BULLET_OFFSET_X = 6; // ^
const float BULLET_OFFSET_Y = 0; // ^

