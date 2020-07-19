<h2 align = 'center'><img src="https://i.imgur.com/lQEufyo.png"><br>KAG Gun Rework</h2>
<p align = 'center'> Currently being developed. Check the gun folder to view current guns</p>

# Why?
Previously in kag, to make a bullet, the only 2 ways you could do it was to use a blob, or raycast.<br />
Raycast is the 'cheap' way to make a bullet, its cheaper then a blob in terms of resources, faster, but with more limitations, like not being effected by gravity, speed and so on.

Blob is the 'normal' way of making a bullet, but was much more resource heavy, lead to server crashes and high fps drops, low tick rate on the server and so on. <br />
This is because of the overhead required to make a blob, having to sync a lot more data types and a lot more that is engine side that we dont know about.

A while ago, KAG released an update which gave us the Render:: stuff, this allowed us to make raw shapes, and do what we want with it. <br />
Jenny (The creator of the Wild Wasteland (https://www.youtube.com/watch?v=VWRoJbgzh6k&feature=youtu.be)) wanted a gun rework, since the amount of server crashes made the game not so fun. So i started work on this.

# How does it work?

I use the Render:: stuff to draw the bullets, so we can actually see it, along with that, each bullet is grouped into one Vertex array after we lerp is last tick position and current tick position.<br />
The physics is bare bones, so we don't waste resources on stuff we don't need. I use the start position (When the gun was fired), and the angle. That's it. The speed, gravity, drop, speed and what not can all be changed, check Ak47.as as an Example.<br />

The physics/position is updated every tick, so the server can render it too. (We use lerp to render it for clients based on the last and current position)<br />
The only bits of data sent to the server (and back to the client) is damage done to a player, or tile, and when the bullet was fired, which includes the position shot, angle, gun blob ID, and the shooters blob ID. 

So far, the server for wild wasteland has not crashed, fps can drop about 20 frames in intensive gun fights (Pre particle, and gun air animation)

# Can i use it?

Sure, It wasnt just made with Wild wasteland in mind, feel free to redo lazer wars with it, or a new type of mode.
Please give credit if used. If you find any thing questionable, any problems, or want a new feature, do so in the issues tab.

# Mods that have used this
- WW2 rework is using it
- Rob's warzone is using it
- TC gun rework used it as a template
- Epsilon 3D mod used this as a template



