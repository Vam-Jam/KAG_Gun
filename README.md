<h2 align = 'center'><img src="https://i.imgur.com/lQEufyo.png"><br>KAG Gun Rework</h2>
<p align = 'center'>Development is done and ready for use, new features may appear in the future if requested</p>

# Why does this exist?

Previously in kag, to make a bullet, the only 2 ways you could do it was to use a blob, or raycast.<br />
Raycast is the 'cheap' way to make a bullet, its cheaper then a blob in terms of resources, faster, but with more limitations, like not being effected by gravity, speed and so on.

Blob is the 'old' way of making a bullet, but was much more resource heavy, lead to server crashes and high fps drops when making a new blob (because kag does a lot of stuff it shouldn’t do) and many other issues such as memory leaks. Another issue with blobs is they tend to 'hug tiles' a bit too hard, and go through them. There are way to prevent this, but a lot of the times it would still occur. 
<br />
Jenny (The creator of the Wild Wasteland (https://www.youtube.com/watch?v=VWRoJbgzh6k&feature=youtu.be)) wanted a gun rework, since the amount of server crashes made the game not so fun. So i started work on this.

# How does it work?

It uses the new Render:: binds that was added a while ago. It allows us to draw raw vertices, apply simple textures to it and have it render in game. 
This is great for this use case, as bullets don't really need to do much except be seen by clients.<br />

To do the physics and hit reg, we use ray casting, but in small chunks. You can see how its done by enabling raycast debug on CMap. There isnt much to say about this. Each tick we do a raycast, move it forward and wait for the next tick. 

When a bullet spawns, everybody will play 'catch up' until all bullets are in sync. This does have a downside of people with high ping might have stutters, so this might end up not being ideal.

# Can i use it?

Sure! This was designed so new modders or people with no modding experience could make a sprite, change some settings and boom, a new gun.
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
- Laws64 CSGO mod is using this


