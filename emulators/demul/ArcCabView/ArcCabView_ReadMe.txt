ArcCabView 2.6b Reshade's shader by Aubrel and Ducon2016
Launcher/Installer by Aubrel

ArcCabView is mainly a ReShade's shader you can use to display your games (nearly all your games) just as you want.
It's still mainly designed to display arcade oriented games in cabinets and that's why its now named like that.

This shader is the results of months of work. It's an evolution of CRTGeomMOD (written from the ReShade shader CRTGeom by cgwg, Themaister and DOLLS).
Nearly everything was rewritten in order to fix and avoid some old CRTGeomMOD issues and to get better performances and results.
As a comparaison, with all the options activated (even the new ones) it's now approx 2x faster than CRTGeomMOD v3.2 !!
Many new features were added, many changes also and it's now fully merged with the shader PinCabView.

It's not anymore mainly to use to get a CRT effect, it's now a complete tool to display all games as you want (it can be used also with emulators, dosbox and even some frontends!...).
The custom ReShade's dll included can resize most d3d9/d3d11 games to any resolution. For the remaining games you can also use dgVoodoo2 to resize the game and to load ReShade.
This pack includes :
- d3d8to9.dll available here https://github.com/crosire/d3d8to9/
- dgVoodoo2 available here http://dege.freeweb.hu/dgVoodoo2/dgVoodoo2/
- ReShade custom dlls (32 and 64 bits). Original ReShade home page : https://reshade.me/ 

Using this shader you will have full control of your game display. The functions will be explain bellow, but quickly you can :
- Rotate the game display in any Orientation (in most case without having to change your screen orientation).
- Manage completely the game ratio when ingame and when not ingame.
- Resize, move the display when ingame, when not ingame and also just the internal and external parts of a defined area.
- Crop some parts or a ratio defined area of the game and choose to display them or not.
- Curve the full display or just a defined part of the game
- Add a CRT effect with Bloom, different dot aspects, vertical or horizontal scanlines,...
- Add a Frame with Screen Reflection around the full display or just around the defined area.
- Add a Bezel over or under the full display and manage its size. It can follow the game settings or not.
- Add a Background image or display a game blur mirror and change the Background Color and Brightness.
- Add an Overlay image over the defined game area.
- Add conditions to test in order to get yours effects and arts only when you want and where you want in the game.
...
More than that, for Pinball games you can also :
- Add a Backglass image with or without Grill and catch a part of the game to show in it.
- Move and resize the DMD display where you want
- Resize and move the table and change its perspective.
- Manage the brightness ingame of these different parts
...


How to use (v2.1 needs a clean install):
- Extract the full archive in its own folder or in your game folder (remove the previous ArcCabView.ini file from the game root folder if there is already an old one)
- Run "ArcCabView_launcher.exe" and when asked set the "true game exe" (the real game process), the "launcher" (if there is one to run) and the command to send (if there are some parameters to send)
- If the application is unknown a list of the already set games will be proposed, if your game is not in the list you can put its name and it will be created.
- The launcher will now try to run the game to take some usefull informations. Just wait it should take a few seconds (max 40s) and don't touch anything during this period.
- If everything is ok the game will start again with the settings known and defined during the first launch will be already applied. (if not some instructions could be given to help)
- When used in it's own folder:
* ArcCabView will create shortcuts in "Games" directory to launch your games.
* You will find also shortcuts for the games presets in UserPresets and shortcuts to reset your game settings in "Reset" Folder
- Push "Home" key ingame to get the ReShade's UI in order to set shader's parameters.
- Sending the command -p to the launcher will force portrait mode
- Sending the command -r to the launcher will force reset mode


ArcCabView.ini Standard options :
- RotatedGame : set to 1 if the game display is already rotated by default (most TATE games for example)
- PortraitMode : it will set the game in portrait mode (it is set by default when your screen is already set in portrait mode)
- Rotate180 : set to 1 to rotate the game display by 180°
- LandscapeRatio : to force a special game ratio in landcape mode (example 16:9)
- PortraitRatio : to force a special game ratio in portrait mode. (/!\ this is the ratio before any rotation. Example: 4:3)
- FullStretch : it will stretch the game to your full screen ratio.
- DllCustomRes : set to 0 to disable the forced/full/doubled resolution of our custom ReShade dll (more settings in ArcCabView\ReShade.ini ArcCabView section).
- CustomResFix : set to 1 to fix the dll custom resolution when the game is not stretched correctly, 2 will force the original ratio (leave it at 0 if the game is correctly displayed)
- dgVoodoo : set to 1 to force the use of dgVoodoo2 to resize the game and to load ReShade (d3d8 and d3d9 games only)
- forceRotate : set to 1 if you want the launcher to rotate your screen to portrait before running the game (2 to force landscape screen setting).
- WindowMode : set to 1 to try to force the display in window mode (still not perfect)

ArcCabView.ini Advanced options (should be set by the launcher itself)
- ExeName : the name of the game exe file to launch (should be in the same directory, if not set it can be detected or asked)
- WinName : if you know the true game window name put it here (Case Sensitive. If not set it should be detected/corrected at first launch)
- 64Bits : set to 1 if the game is a 64 bit application.
- Command : if you want the launcher to send a command to the game exe put it here (example: -fullscreen)
- GameRes : if you know the original game resolution put it here (if not set the launcher will try to get it at first launch. Example: 1280x720)
- DllName : put here the name of the dll to use (try different names if ReShade doesn't work. Example: ddraw, d3d8, d3d9, d3d11, d3d12, opengl32, vulkan-1, ...)


General shader features :
- Game Video resolution : the original resolution of the game to catch from top left corner of the screen (0 will catch the full screen size)
- CenterLocked ratio : used to catch the game display area when it's always centered and locked to a specific ratio (0,0 will take the full video resolution).
- Crop Ratio : nearly the same as CenterLocked ratio but can be added to it to catch a sepcific game area inside. External graphics can be kept and it's only applied "ingame".
- GameScreen size : to display the game in a specific top left part of your display (mostly to use with PinCabView and multiscreens configurations)
- Rotation : to rotate the display 90° CCW. With "auto 90CCW" the game will be rotated 90°CCW if your main screen is set in landscape mode (GameScreen ratio > 1)
- Game zoom/translation : to resize and move the full display (will be always applied)
- Pixel Test : to apply some specifics settings only when the RGB color of a XY defined dot matches (the dot position should be defined with the game stretched in 1920x1080)
(if pixeltest is disabled the "ingame" settings will be always applied, if "inverted" the "ingame" settings will be disabled when pixel test matches)
- Game Brightness : to change the brightness, it will be applied ingame on the game display area.
- Background Brightness : to change the brightness outside of the game area (always applied).
- Curvature : will be applied ingame on the game display area and on the full game when pixel test fails. If available the overlay image will be displayed over the result.
- Frame : to show a screen frame on the game display area ingame and on the full game area when pixel test fails (frame is cropped to its defined size when curvature is disabled)
- Frame reflection : the reflection of the display shown on the frame (always applied)
- InGame ratio/scale/offset : to resize and move the full game display ingame.
- OffGame ratio/scale/offset : to resize and move the full game display when pixel test fails (when not ingame).
- Horizontal/Vertical Starts : used to crop some parts of the game display (applied only ingame).
- External Display : to show the cropped areas of the game (only ingame). If available the background image will be displayed over this external area.
- External scale/offset : to resize and move the cropped (external) areas of the game (only ingame).
- Internal scale/offset : to resize and move the display inside the game area (only ingame).
- CRT effect : to simulate a CRT display (applied only ingame on the game area)
- Vertical scanline : to rotate by 90° the scanline of the CRT effect.


In order to get better performances and to get only the wanted features the function can be disabled in the shader's code :
- FRAME_RFLX : to get or not the frame reflection code
- CRT_SHADER : to get or not the CRT effect code
- CRV_SHADER : to get or not the curvature code
- DBL_TESTS : to get or not the double pixel test code (2 points should match)
- PIN_SHADER : to get the pinball game designed code (will add and remove some features)
- PERF_MODE : to reduce the size of some textures and to bypass some parts of the code in order to get better performances

Supported art files (textures folder) :
- frame.png (to show a screen frame around the game display area)

ArcCabView arts :
- bezel.png/bezelv.png (displayed over or under the display ingame, can be fixed or set to follow the game's settings - 16:9 sized by default)
- bezel_off.png/bezelv_off.png (displayed over or under the display when pixel test fails - 16:9 sized by default)
- background.png (optional, will be displayed ingame over the cropped areas - will be displayed over the external graphics)


PinCabView specific features ("PIN_SHADER" defined) :
- POV settings are added to correct the game perspective ingame
- An apron image can be added and displayed ingame over the game area (or under the CRT effect)
- A backglass image can be displayed and a part of the game can be caught and displayed ingame under the 16:9 top part of the backglass (the game's window should be extended to cover a second screen).
- A DMD area can be caught and displayed ingame over the game area, over the 16:9 top part of the backglass or under the backglass bottom part (grill).
- Brightness levels can be set for the 16:9 top part of the backglass and also for the DMD display (applied only ingame).

PinCabView arts :
- backglass.png (5:4 format with grill - will be cropped to 16:9 with a 2nd screen ratio of more than 16:10)
- backglass_off.png (will be displayed behind the 16:9 top part of the backglass when pixel test fails and ingame if the "original" backglass area is not set)
- dmd_off.png (will be displayed over the 16:9 top part of the backglass when pixel test fails or if the "original" dmd area is not set)
- apron.png (will be displayed ingame over the game display area if the CRT effect is disabled)
- background.png (optional, will be displayed bellow the DMD and the backglass)


Changelog :
2.6b
- ArcCabView sharder updated to fix a grill display problem in PinCabView and to improve some bloom/blur/brightness default values
2.6a
- dgVoodoo2 version included reversed to 2.78.2 (problems found with 2.79 versions)
2.6
- "overlay texture" removed (the effect is now simulated with the new "curvature boost" option)
- "oversample boost" fixed and improved
- rotated game display is improved (internal gamecopy and bloomblur textures are now rotated)
- bloom aspect ratio improved and fixed
- default "frame texture" updated and frame display code improved
- frame color and frame brightness options added
- some shader improvements and fixes

2.5
- Some shader improvements, moire effect should be reduced

2.4a
- Default curvature settings updated (slightly less curved)
- Overlay opacity reduced
- dgVoodoo2 updated to last version 2.79
2.4
- Some dxgi over d3d11 dll detection should be fixed
- Souldiers (PC) native support added
- TMNT - Shredder's Revenge (PC) native support added
- Final Vendetta (PC) native support added

2.3b
- ArcCabView shader updated (mostly PinCabView part)
- Some shader's CRT-Effect codes reversed to the previous ones (it looks better and is less power consuming)
2.3
- Some GamePath/LauncherPath issues should be fixed
- Added CROP_OFF option to keep or not the Crop_ratio when Pixel-Test fails
- Added CRT_EFFECT_OFF option to keep or not the CRT effect when Pixel-Test fails
- Added USE_FRAME_OFF option to keep or not the Screen Frame when Pixel-Test fails
- Added CURVATURE_OFF option to keep or not the Curvature effect when Pixel-Test fails
- Added USE_BEZEL_OFF option to keep or not the Bezel overlay when Pixel-Test fails
- Added DMDColor option to change the DMD color (PinCabView)
- Added DMDFilter option to crop DMD colors below the filter value (PinCabView)
- Some shader improvements and fixes...
- Ganryu 2 (PC) native support added
- B.I.O.T.A. (PC) native support added
- Demons Of Asteborg (PC) native support added
- Flynn Son Of Crimson (PC) native support added

2.2
- UserTextures folder added (you can put here your own specific games textures/bezels)
- Default shader CRT settings updated with more "bloom"
- Crisis Wing (PC) preset updated with a small offset to better catch the original game texture.
- When used in its own directory, ArcCabView presets will be now stored in ArcCabview\UserPresets folder.
- A message can be displayed after first launch (and put in the ini) to inform about specific settings needed. 
- Cave Story + (PC) native support added
- Celeste (PC) native support added for FNA version
- Katana Zero (PC) native support added
- Broforce (PC) native support added
- Broforce - The Expendabros (PC) native support added
- Mercenary Kings (PC) native support added
- Super Cyborg (PC) native support added
- Jitsu Squad (PC) native support added
- Asterix & Obelix: Slap Them All! (PC) native support added
- Cup Head (PC) native support added
- Streets Of Rage 4 (PC) native support added
- Neon Abyss (PC) native support added

2.1b
- Andro Dunos II (PC) native support added
- Battle Crust (PC) native support added
- Crisis Wing (PC) native support added
- Final Fight LNS Ultimate (OpenBOR) native support added
- Marvel Infinity War (OpenBOR) native support added
- Streets Of Rage 2X (OpenBOR) native support added
- Some small improvements and changes in databases...
2.1a
- Darius Burst/Darius Burst EX (TTX) should be fixed
- Raiden IV and Raiden V (PC) should be fixed too
- Battle Squadron 2013 (PC) support added (demo and full game)
- Some small improvements and changes in databases...
2.1
- Many improvements in the concept and launcher's UI
- Many fixes
- Many native PC games support added

2.0
- Full native portrait mode added in the shader
- Textures bezelv.png and bezelv_off.png are added and will be used in portrait mode
- A Launcher is now included to set the games directly.
- Small cleanups...

1.1a
- Bezel display in portrait mode fixed
- Small cleanups...
1.1
- CRTGeom code updated with last cgwg's improvements
- Brightness and black dots render has been improved when using CRT effect
- Bloom effect improved to catch the screen dots and to look more realistic with CRT effect
- The alpha value of the overlay image is now exponential
- The frame image has been updated (the borders sizes are smaller than before)
- A few minor fixes/changes

1.0b
- ReShade's dll updated to fix mp4 videos in unity games.
- The screen overlay can now be disabled.
- A performance mode has been added in the shader.
- A few small fixes/improvements
1.0a
- A small bug with the frame reflection should be resolved.
- An issue appearing in some cases with the bezel rotation should be fixed.


Info / Support : http://www.emuline.org/topic/2598-arccabview-display-your-arcade-games-just-as-you-want/
PinCabView Info / Support :
https://vpuniverse.com/forums/topic/5494-pincabview-bigraceusa-fantasticjourney-timeshock-theweb-wormspinball-worldrallyfever-slamtilt-resurrection/
https://vpuniverse.com/forums/topic/5903-pincabviewwfs-all-wildfire-studios-pinball-pc-games-in-your-pincab/
https://vpuniverse.com/forums/topic/5744-pincabview2d-most-old-dos-pinball-games-in-your-pincab/



ReShade home page : https://reshade.me/
dgVoodoo2 home page : http://dege.freeweb.hu/dgVoodoo2/
D3D8to9 home page : https://github.com/crosire/d3d8to9/

