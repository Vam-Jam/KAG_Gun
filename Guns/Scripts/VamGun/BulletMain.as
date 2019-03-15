#include "GunHitters.as";
#include "BulletTrails.as";
#include "BulletClass.as";

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
    FireGunID     = this.addCommandID("fireGun");
    FireShotgunID = this.addCommandID("fireShotgun");
    Render::addScript(Render::layer_objects, "BulletMain", "SeeMeFlyyyy", 0.0f);
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
        CPlayer@ p = holder.getPlayer(); 

        if(b !is null && p !is null) 
        {
            if(b.exists("clip"))
            {
                if(p.isMyPlayer() && b.isAttached())
                {
                    uint8 clip = b.get_u8("clip");
                    uint8 total = b.get_u8("total");
                    CControls@ controls = getControls();
                    Vec2f pos = Vec2f(0,getScreenHeight()-80);
                    bool render = false;

                    if(controls !is null)
                    {
                        int length = (pos - controls.getMouseScreenPos() - Vec2f(-30,-35)).Length();

                        if(length < 256 && length > 0)
                        {
                            white.setAlpha(length);
                            eatUrGreens.setAlpha(length);
                            render = true;
                        }
                        else
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
                        
                    if(v_r_reloadBox.length() < 1 || render)
                    {
                        if(render)
                        {
                            v_r_reloadBox.clear();
                        }
                        v_r_reloadBox.push_back(Vertex(pos.x+112, pos.y,     1, 1, 0, white)); //top right
                        v_r_reloadBox.push_back(Vertex(pos.x, pos.y,     1, 0, 0, white)); //top left
                        v_r_reloadBox.push_back(Vertex(pos.x, pos.y+80,     1, 0, 1, white)); //bot left
                        v_r_reloadBox.push_back(Vertex(pos.x+112, pos.y+80,     1, 1, 1, white)); //bot right
                    }
                    Render::SetTransformScreenspace();
                    Render::SetAlphaBlend(true);
                    Render::RawQuads("ammoBorder.png", v_r_reloadBox);

                    pos = Vec2f(15,getScreenHeight() - 68);
                    GUI::DrawText(clip+"/"+total, pos, eatUrGreens);

                    pos = Vec2f(15,getScreenHeight() - 58);

                    if(b.get_bool("doReload")) 
                    {
                        GUI::DrawText("Reloading...", pos, eatUrGreens);
                    } 
                    else if(clip == 0 && total > 0 && !b.get_bool("beginReload")) 
                    {
                        GUI::DrawText("Press R to \nreload!", pos, eatUrGreens);
                    } 
                    else if(clip == 0 && total == 0) 
                    {
                        GUI::DrawText("No more \nammo, find \nanother \nweapon!", pos, eatUrGreens);
                    }

                }
            }
            else
            {
                if(v_r_reloadBox.length() > 0)
                {
                    v_r_reloadBox.clear();
                }
            }
        }   
           
    }
}

Random@ r = Random();

void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if(cmd == FireGunID)
    {
        CBlob@ hoomanBlob = getBlobByNetworkID(params.read_netid());
        CBlob@ gunBlob    = getBlobByNetworkID(params.read_netid());

        if(hoomanBlob !is null && gunBlob !is null)
        {  
            const f32 angle = params.read_f32();
            const Vec2f pos = params.read_Vec2f();
            BulletGrouped.AddNewObj(BulletObj(hoomanBlob,gunBlob,angle,pos));
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
            if(sFLB)
            {
                f32 tempAngle = angle;

                for(u8 a = 0; a < b_count; a++)
                {
                    tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(spread) : r.NextRanged(spread);
                    //print(tempAngle + "");
                    BulletGrouped.AddNewObj(BulletObj(hoomanBlob,gunBlob,tempAngle,pos));
                }
            }
            else
            {
                for(u8 a = 0; a < b_count; a++)
                {
                    f32 tempAngle = angle;
                    tempAngle += r.NextRanged(2) != 0 ? -r.NextRanged(spread) : r.NextRanged(spread);
                    BulletGrouped.AddNewObj(BulletObj(hoomanBlob,gunBlob,tempAngle,pos));
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
