//TODO recoil over time


class Recoil
{
    CBlob@ Blob;
    CControls@ BlobControls;
    Vec2f Velocity;
    u16 TimeToNormal;
    float xTick;
    float yTick;
    Vec2f StartPos;
    Vec2f CurrentPos;

    Recoil(CBlob@ blob,Vec2f velocity, u16 TimeToEnd, Vec2f startPos)
    {
        if(blob is null || blob.getControls() is null)
        {
            return;
        }
        @Blob = blob;
        @BlobControls = Blob.getControls();
        //@BlobControls = blob.getControls();
        StartPos = startPos;
        Velocity = velocity;
        TimeToNormal = TimeToEnd;

        xTick = 0;
        yTick = velocity.y < 0 ? Maths::Clamp(velocity.y / TimeToEnd, -25, -1) : Maths::Clamp(velocity.y / TimeToEnd, 1, 25);
    }


    void onFakeTick()
    {
        if(TimeToNormal < 1)
        {
            return;
        }
        if(Blob is null)
        {
            TimeToNormal == 0;
            return;
        }
        TimeToNormal--;
        BlobControls.setMousePosition(BlobControls.getMouseScreenPos() + Vec2f(xTick,yTick));
        if(Blob is getLocalPlayerBlob())
        {
            ShakeScreen(Vec2f(xTick,yTick),150,Blob.getInterpolatedPosition());
        }

    }
    /*

        c.setMousePosition(c.getMouseScreenPos() + Vec2f(0,-G_RECOIL));
		ShakeScreen(Vec2f(0,-G_RECOIL), 150, sprite.getWorldTranslation());

    */
}


