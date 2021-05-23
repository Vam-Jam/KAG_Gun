<h2 align = 'center'><img src="https://i.imgur.com/lQEufyo.png"><br>KAG Gun Rework</h2>
<p align = 'center'>Development is done and ready for use, new features may appear in the future if requested</p>

# Why does this exist?

Previously in kag, to make a bullet, the only 2 ways you could do it was to use a blob, or raycast.<br />
Raycast is the 'cheap' way to make a bullet, its cheaper then a blob in terms of resources, faster, but with more limitations, like not being effected by gravity (unless you split it up over multiple ticks) and a lack of visual fidelity.

Using a Blob is the other way of making a bullet. Easy to do, but blob's have a lot of overhead when being made, and making them too quickly causes a lot of issues. (Random crashes (due to blobs being complex) and weird physics (box2d & kag glue) to name a few). In return you could do some complex stuff visually and easily, or have bullets travel in silly ways effortlessly.
<br >
Jenny (The creator of the Wild Wasteland (https://www.youtube.com/watch?v=VWRoJbgzh6k&feature=youtu.be)) created a WW2 mod in kag, using the blob style bullets. The biggest issue was random crashes & the bullets going through tiles. I spent a while trying to fix bullets going through walls, but turned out to be an issue with box2d & entities going too fast.

So with the recent release of the new Render:: binds, I decided to create a new type of bullet from scratch.

# How does it work?

To start with, we need visuals. So the new Render:: binds allow us to send raw vertices to irrlicht, give it a texture and have it appear in game. This is good for our use case of just rendering a small sprite.

For logic, I just made a simple bullet class that keeps track of some important vars, such as position, last position (for interpalation & raycasting), current gravity & velocity and so on.
The class relies on 2 hooks, onTick and onRender.
- onTick handles physics, raycasting and killing the bullet if it's lived too long.
- onRender handles drawing the bullet

Todo: Write up about how we handle shoot & high ping 

# Can i use it?

Sure! This was designed so new modders or people with no modding experience could make a sprite, change some settings and boom, a new gun.
If you are an experienced modder, feel free to tinker with it or use it as a template! Always cool to see what people do with it.

Please just give credit, and don't claim any of the core code as your own >:(

# How can i use it?

You can add it to any gamemode, all you need to do is add ``BulletMain.as`` to your gamemode.cfg. 
Once done, copy the example guns from the Example folder, play around with it, give it a different sprite and your done!

# I've got an issue, can you fix?

Sure, make an issue or message me on kag discord

# Can you add this feature please?

Possibly, reach out to me and we can talk about it.

# Mods that have used this
- WW2 rework is using it
- Rob's warzone is using it
- TC gun rework used it as a template
- Epsilon 3D mod used this as a template
- Laws65 CSGO mod is using this


