#include "GunHitters.as";
#include "BulletTrails.as";
#include "BulletClass.as";

BulletHolder@ BulletGrouped = BulletHolder();
Vertex[] v_r_bullet;
Vertex[] v_r_fade;
Vertex[] v_r_reloadBox;
SColor white = SColor(255,255,255,255);
SColor eatUrGreens = SColor(255,0,255,0);

void onInit(CRules@ this)
{
	Reset(this);
    this.addCommandID("fireGun");
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
	BulletGrouped.Clean();
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
    Render::SetAlphaBlend(true);
    BulletGrouped.FillArray();
    if(v_r_bullet.length() > 0)
    {
        Render::RawQuads("Bullet.png", v_r_bullet);
        v_r_bullet.clear();
    }

    if(v_r_fade.length() > 0)
    {
        Render::RawQuads("fade.png", v_r_fade);
        v_r_fade.clear();
    }

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

void onCommand(CRules@ this, u8 cmd, CBitStream @params) {
	if(cmd == this.getCommandID("fireGun"))
    {
        CBlob@ hoomanBlob = getBlobByNetworkID(params.read_netid());
        CBlob@ gunBlob    = getBlobByNetworkID(params.read_netid());

        if(hoomanBlob !is null && gunBlob !is null)
        {  
            f32 angle = params.read_f32();
            Vec2f pos = params.read_Vec2f();
            BulletGrouped.AddNewObj(BulletObj(hoomanBlob,gunBlob,angle,pos));
        }
    }
}
