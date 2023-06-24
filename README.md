<h2 align = 'center'><img src="https://i.imgur.com/lQEufyo.png"><br>KAG Gun Rework</h2>
<p align = 'center'>This project has been sunsetted. This should still work in future versions of KAG.</p>

## What problem does this solve?

Previously in KAG, to make a 'bullet', you had one option:<br />

### A Blob
Blobs are the default game object in KAG. They are mainly geared towards objects that have a long (ish) lifetime. It has a lot of overhead when being made and synced (creating too many objects at once can cause whats known as 'Bad Deltas', where you exceed the engine network io limit). Another issue is most of the blobs source code is engine side, you are on your own if you have crashes, performance issues or weird physics issues.


### The 'new' alternative: 
This mod takes advantage of the raw Irrlicht binds that were exposed quite a while ago. We use the new binds to pass in vertices & textures to render, and create features we need from scratch using Angelscript.

High level overview of how it works:
- Every bullet that is made is synced on creation with an initial timestamp, angle & owner. 
- When a client receives a bullet creation packet, they will automatically 'tick' bullets forward so they match what the person shooting & server sees. (This has a max limit as to prevent abuse) 
- Server will have full authority over who gets hit (which is hardly an issue because bullets should be synced up)

Bullets use ray tracing instead of Box2d, so we have to emulate gravity & other things you'd expect out of bullets. The upside to this is we get full control over everything our bullet can do, and prevent issues like 'bullets going through walls' (which was common with blobs). The downside is we have to make it from scratch.


# Can i use it?

Sure! Just give credit.

# How can i use it?

You can add it to any gamemode, all you need to do is add ``BulletMain.as`` to your `gamemode.cfg`. 
Once done, copy the example guns from the Example folder, play around with it, give it a different sprite and your done!

# Mods that have used this
- WW2 rework is using it
- Rob's warzone is using it
- Territory Control used it as a template
- Epsilon 3D mod used this as a template
- Laws65 CSGO mod is using this

