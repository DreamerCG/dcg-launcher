//**************************************************************************//
//                                                                          //
// Reshade's shader ArcCabView 2.6b (2023-02-11) by Aubrel and Ducon2016    //
//                                                                          //
//**************************************************************************//

// http://www.emuline.org/topic/2598-arccabview-display-your-arcade-games-just-as-you-want/

//**************************************************************************//
// Pinball shader is mainly designed to work with PinCabView launchers      //
// because it needs a multi-screens configuration not provided by ReShade   //
// but it can be used also without the launcher and with any games          //
// even if the main goal remains to get a correct pinball cabinet view      //
// with additionnal backglass display and DMD export features.              //
//                                                                          //
// PinCabView supported Pinball games :                                     //
// Pro Pinball: The Web - Timeshock! - Fantastic Journey - Big Race USA     //
// Addiction Pinball: Worms Pinball - World Rally Fever                     //
// SlamTilt Resurrection : Demon - Pirate                                   //
// Austin Power Pinball / Balls of Steel / Devil's Island Pinball           //
// Dirt Track Racing Pinball / Kiss Pinball / Ultimate Gold Pinball         //
// Pinball Dreams / Pinball Dreams II / Pinball Fantasies / Pinball Mania   //
// Pinball Illusions / Pinball 2000 / Pinball 4000 / Absolute Pinball       //
// SlamTilt / Electronic Pinball / Silverball / Silverball 2 / Epic Pinball //
// Psycho Pinball / Ultimate Pinball / Thomas The Tank Engine's Pinball     //
// Pinball Wizard 2000 / Pinball Builder / ...                              //
//**************************************************************************//

/*
	ArcCabView is born from the fusion of PinCabView and CRTGeomMOD shader's features
	
	PinCabView v4 (2021-11-15) Pinball designed shader by Aubrel
	https://vpuniverse.com/forums/topic/5494-pincabview-bigraceusa-fantasticjourney-timeshock-theweb-wormspinball-worldrallyfever-slamtilt-resurrection/
	https://vpuniverse.com/forums/topic/5744-pincabview2d-most-old-dos-pinball-games-in-your-pincab/
	https://vpuniverse.com/forums/topic/5903-pincabviewwfs-all-wildfire-studios-pinball-pc-games-in-your-pincab/
	
	&&
	
	CRTGeomMOD v3 (2021-11-15) Shader customized and enhanced by Ducon2016 and Aubrel
	http://www.emuline.org/topic/1420-shader-crt-multifonction-kick-ass-looking-games/
*/



/*
	CRT-interlaced
	
	Copyright (C) 2010-2012 cgwg, Themaister and DOLLS
	
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or (at your option)
	any later version.
	
	cgwg gave their consent to have the original version of this shader
	distributed under the GPL in this message:
	
	http://board.byuu.org/viewtopic.php?p=26075#p26075
	
	"Feel free to distribute my shaders under the GPL. After all, the
	barrel distortion code was taken from the Curvature shader, which is
	under the GPL."
	This shader variant is pre-configured with screen curvature
*/



/**************************/
/** Shader Configuration **/
/**************************/
#define CRT_SHADER
#define CRV_SHADER
//#define PIN_SHADER
#define DBLE_TESTS
//#define PERF_MODE
/**************************/
#ifdef CRV_SHADER
#define FRAME_RFLX
#endif
#ifdef PIN_SHADER
//#define DMD_BGND
#else
//#define BGND_TEX
#endif
/**************************/


#include "ReShade.fxh"


// User Visual Settings
uniform float GameBrightness <
	ui_type = "slider";
	ui_min = -1.00f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "Game Brightness";
	ui_tooltip = "Can be activated with Pixel-Test";
	ui_category = "User Visual Settings";
> = 0.00f;

#ifdef PIN_SHADER
uniform float BackGlassBrightness <
	ui_type = "slider";
	ui_min = -1.00f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "BackGlass Brightness";
	ui_tooltip = "Can be activated with Pixel-Test";
	ui_category = "User Visual Settings";
	ui_spacing = 1;
> = 0.30f;

uniform float DMDBrightness <
	ui_type = "slider";
	ui_min = -1.00f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "DMD Brightness";
	ui_tooltip = "Can be activated with Pixel-Test";
	ui_category = "User Visual Settings";
	ui_spacing = 1;
> = 0.30f;

uniform float DMDFilter <
	ui_type = "slider";
	ui_label = "DMD Filter";
	ui_min = 0.0f;
	ui_max = 1.0f;
	ui_step = 0.01f;
	ui_tooltip = "To crop DMD colors below the filter value";
	ui_category = "User Visual Settings";
> = 0.0f;

uniform float3 DMDColor <
	ui_type = "color";
	ui_label = "DMD Color";
	ui_tooltip = "To change the DMD color";
	ui_category = "User Visual Settings";
> = float3(0.0, 0.0, 0.0);
#endif

#ifdef CRV_SHADER
uniform float FrameBrightness <
	ui_type = "slider";
	ui_min = -1.00f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "Frame Brightness";
	ui_category = "User Visual Settings";
	ui_spacing = 1;
> = 0.00f;

uniform float3 FrameColor <
	ui_type = "color";
	ui_label = "Frame Color";
	ui_tooltip = "To change the screen frame color";
	ui_category = "User Visual Settings";
> = float3(0.0, 0.0, 0.0);

#ifdef FRAME_RFLX
uniform float ReflectionIntensity <
	ui_type = "slider";
	ui_min = 0.00f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "Frame Reflection Intensity";
	ui_tooltip = "Simulate frame reflection strength";
	ui_category = "User Visual Settings";
> = 0.25f;
#endif
#endif

uniform float BackgroundBrightness <
	ui_type = "slider";
	ui_min = -1.00f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "Background Brightness";
	ui_category = "User Visual Settings";
	ui_spacing = 1;
> = 0.00f;

uniform float3 bg_col <
	ui_type = "color";
	ui_label = "Background Color";
	ui_tooltip = "The color the background outside of the display (full screen size)";
	ui_category = "User Visual Settings";
> = float3(0.0, 0.0, 0.0);

#if defined FRAME_RFLX || defined CRT_SHADER
uniform bool BLUR_BACKGROUND <
	ui_label = "BLUR BACKGROUND";
	ui_tooltip = "To get game blur as Background (Always applied)";
	ui_category = "User Visual Settings";
> = false;
#endif

uniform bool FULL_STRETCH <
	ui_label = "FULL STRETCH";
	ui_tooltip = "To stretch the display to the full screen size (Always applied)";
	ui_category = "User Aspect Settings";
> = false;

uniform float2 GameScreen_zoom <
	ui_type = "drag";
	ui_min = 1.00f;
	ui_max = 300.00f;
	ui_step = 0.10f;
	ui_label = "Manual Main Screen Zoom X/Y (% - Always applied)";
	ui_category = "User Aspect Settings";
> = float2(100.00, 100.00);

uniform float2 GameScreen_trans <
	ui_type = "drag";
	ui_min = -100.00f;
	ui_max = 100.00f;
	ui_step = 0.10f;
	ui_label = "Manual Main Screen Translation X/Y (% - Always applied)";
	ui_category = "User Aspect Settings";
> = float2(0.00, 0.00);

#ifdef PIN_SHADER
uniform float InGamePOV_factor <
	ui_type = "slider";
	ui_min = -1.00f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "Manual Table POV Factor Setting (0.0 = Original)";
	ui_tooltip = "Can be activated with Pixel-Test (To use only with POV)";
	ui_category = "User Aspect Settings";
> = 0.33f;
#endif

// Global Display Process
uniform bool ROTATED_180 <
	ui_label = "ROTATE GAME 180";
	ui_tooltip = "To rotate the game display by 180°";
	ui_category = "Global Display Process";
> = false;


// Display Method Settings
uniform int NO_ROTATE <
	ui_type = "combo";
#ifdef PIN_SHADER
	ui_items = " Auto-Rotation 90CCW \0 Rotation 90CCW Disabled \0 Rotation 90CCW Forced \0";
#else
	ui_items = " Rotation 90CCW Forced \0 Rotation 90CCW Disabled \0 Auto-Portrait Rotate 90CCW \0 Auto-Portrait Rotate 90CW \0";
	ui_tooltip = "Auto-Portrait modes are to be used only with vertical screens";
#endif
	ui_label = "ROTATION 90";
	ui_category = "Global Display Process";
> = 1;

uniform int2 GameVideo_resolution <
	ui_type = "input";
	ui_label = "Input Image Resolution X/Y (pixels)";
	ui_tooltip = "This is the resolution of the image in the screen frame buffer (0 = full buffer size)";
	ui_category = "Global Display Process";
> = int2(0, 0);

#ifdef PIN_SHADER
uniform int2 GameScreen_resolution <
	ui_type = "input";
	ui_label = "Game Screen Resolution X/Y (pixels)";
	ui_tooltip = "This is area in which you want to display the main game screen (0 = full buffer size)";
	ui_category = "Global Display Process";
> = int2(0, 0);
#endif

uniform float2 CenterLocked_ratio <
	ui_type = "input";
	ui_min = 0.200f;
	ui_max = 5.000f;
	ui_step = 0.001f;
	ui_label = "Center Locked Ratio Setting";
	ui_tooltip = "The ratio to catch - Example 4:3 ratio can be set (4.0, 3.0) or (640.0, 480.0) or (1.333, 1.0) or (1.333, 0.0)";
	ui_category = "Global Display Process";
> = float2(0.000, 0.000);

uniform float2 InGame_ratio <
	ui_type = "input";
	ui_min = 0.200f;
	ui_max = 5.000f;
	ui_step = 0.001f;
	ui_label = "Manual Forced Ratio Setting";
	ui_tooltip = "To force the game ratio - Example 16:9 ratio can be set (16.0, 9.0) or (1920.0, 1080.0) or (1.778, 1.0) or (1.778, 0.0)";
	ui_category = "Global Display Process";
> = float2(0.000, 0.000);

#ifndef PIN_SHADER
uniform float2 Crop_ratio <
	ui_type = "input";
	ui_min = 0.200f;
	ui_max = 5.000f;
	ui_step = 0.001f;
	ui_label = "Crop Ratio Setting";
	ui_tooltip = "The ratio to keep - Example 3:4 ratio can be set (3.0, 4.0) or (600.0, 800.0) or (0.75, 1.0) or (0.75, 0.0)";
	ui_category = "InGame Display Settings";
> = float2(0.000, 0.000);

uniform bool EXT_DISPLAY <
	ui_label = "EXTERNAL GRAPHICS DISPLAY";
	ui_tooltip = "To display External Graphics (Cropped)";
	ui_category = "InGame Display Settings";
> = false;

uniform bool EXPAND_CROP <
	ui_label = "EXPAND CROPPED DISPLAY";
	ui_tooltip = "To Expand the display according to the Crop Ratio";
	ui_category = "InGame Display Settings";
> = false;
#endif

#ifndef PIN_SHADER
uniform float2 InGame_scale <
#else
uniform float2 Intern_scale <
#endif
	ui_type = "drag";
	ui_min = 0.001f;
	ui_max = 3.000f;
	ui_step = 0.001f;
	ui_label = "InGame Scale Setting X/Y";
	ui_category = "InGame Advanced Settings";
	ui_category_closed = true;
> = float2(1.000, 1.000);

#ifndef PIN_SHADER
uniform float2 InGame_offset <
#else
uniform float2 Intern_offset <
#endif
	ui_type = "drag";
	ui_min = -1.000f;
	ui_max = 1.000f;
	ui_step = 0.001f;
	ui_label = "InGame Offset Setting X/Y";
	ui_category = "InGame Advanced Settings";
> = float2(0.000, 0.000);

#ifdef PIN_SHADER
uniform float2 InGame_POV <
	ui_type = "drag";
	ui_min = -1.000f;
	ui_max = 1.000f;
	ui_step = 0.001f;
	ui_label = "InGame POV Setting X/Y";
	ui_tooltip = "0.0 = Original POV";
	ui_category = "InGame Advanced Settings";
> = float2(0.000, 0.000);

#else

// InGame Advanced Settings
uniform float2 h_starts <
	ui_type = "drag";
	ui_min = -10.00f;
	ui_max = 110.00f;
	ui_step = 0.01f;
	ui_label = "Horizontal Internal display START/END (%)";
	ui_category = "InGame Advanced Settings";
	ui_spacing = 1;
> = float2(0.00, 100.00);

uniform float2 v_starts <
	ui_type = "drag";
	ui_min = -10.00f;
	ui_max = 110.00f;
	ui_step = 0.01f;
	ui_label = "Vertical Internal display START/END (%)";
	ui_category = "InGame Advanced Settings";
> = float2(0.00, 100.00);

uniform float2 Intern_scale <
	ui_type = "drag";
	ui_min = 0.001f;
	ui_max = 3.000f;
	ui_step = 0.001f;
	ui_label = "Internal display Scale X/Y";
	ui_category = "InGame Advanced Settings";
	ui_spacing = 1;
> = float2(1.000, 1.000);

uniform float2 Intern_offset <
	ui_type = "drag";
	ui_min = -1.000f;
	ui_max = 1.000f;
	ui_step = 0.001f;
	ui_label = "Internal display Offset X/Y";
	ui_category = "InGame Advanced Settings";
> = float2(0.000, 0.000);

uniform float2 Extern_scale <
	ui_type = "drag";
	ui_min = 0.001f;
	ui_max = 3.000f;
	ui_step = 0.001f;
	ui_label = "External display Scale X/Y";
	ui_category = "InGame Advanced Settings";
	ui_spacing = 1;
> = float2(1.000, 1.000);

uniform float2 Extern_offset <
	ui_type = "drag";
	ui_min = -1.000f;
	ui_max = 1.000f;
	ui_step = 0.001f;
	ui_label = "External display Offset X/Y";
	ui_category = "InGame Advanced Settings";
> = float2(0.000, 0.000);
#endif


uniform int PIXEL_TEST <
	ui_type = "combo";
	ui_items = " Disabled \0 Enabled \0 Inverted \0";
	ui_label = "PIXEL TEST";
	ui_tooltip = "To apply OffGame settings when the pixel color test fails - positions should be defined with the game stretched in 1920x1080";
	ui_spacing = 1;
> = 0;

// Pixel Test Advanced settings
uniform float test_epsilon <
	ui_type = "slider";
	ui_min = 0.000f;
	ui_max = 1.000f;
	ui_step = 0.001f;
	ui_label = "Epsilon (sensitivity)";
	ui_category = "Pixel Test Advanced Settings";
	ui_category_closed = true;
> = 0.010f;

uniform int2 test_pixel <
	ui_type = "input";
	ui_label = "1st Pixel Coordinates X/Y";
	ui_category = "Pixel Test Advanced Settings";
> = int2(0, 0);

uniform float3 test_color <
	ui_type = "color";
	ui_label = "1st Pixel Color (RGB)";
	ui_category = "Pixel Test Advanced Settings";
> = float3(0.0, 0.0, 0.0);

#ifdef DBLE_TESTS
uniform int2 test_pixel2 <
	ui_type = "input";
	ui_label = "2nd Pixel Coordinates X/Y";
	ui_category = "Pixel Test Advanced Settings";
	ui_spacing = 1;
> = int2(0, 0);

uniform float3 test_color2 <
	ui_type = "color";
	ui_label = "2nd Pixel Color (RGB)";
	ui_category = "Pixel Test Advanced Settings";
> = float3(0.0, 0.0, 0.0);
#endif

#ifdef CRT_SHADER
uniform bool CRT_EFFECT_OFF <
	ui_label = "KEEP CRT EFFECT";
	ui_tooltip = "To keep the CRT effect when Pixel-Test fails";
	ui_category = "Pixel Test Advanced Settings";
> = false;
#endif

#ifdef CRV_SHADER
uniform bool CURVATURE_OFF <
	ui_label = "KEEP CURVATURE";
	ui_tooltip = "To keep the Curvature effect when Pixel-Test fails";
	ui_category = "Pixel Test Advanced Settings";
> = true;
#endif

uniform bool USE_FRAME_OFF <
	ui_label = "KEEP FRAME";
	ui_tooltip = "To keep the Screen Frame Overlay when Pixel-Test fails";
	ui_category = "Pixel Test Advanced Settings";
> = true;

#ifndef PIN_SHADER
uniform bool USE_BEZEL_OFF <
	ui_label = "KEEP BEZEL";
	ui_tooltip = "To keep the same Bezel Overlay when Pixel-Test fails";
	ui_category = "Pixel Test Advanced Settings";
> = false;

uniform bool CROP_OFF <
	ui_label = "KEEP CROP SETTINGS";
	ui_tooltip = "To keep the Crop settings when Pixel-Test fails";
	ui_category = "Pixel Test Advanced Settings";
> = false;
#endif

uniform float2 OffGame_ratio <
	ui_type = "input";
	ui_min = 0.200f;
	ui_max = 5.000f;
	ui_step = 0.001f;
	ui_label = "Manual OffGame Ratio Setting";
	ui_tooltip = "To force the game ratio when Pixel-Test fails - Example : 4:3 ratio can be set (4.0, 3.0) or (640.0, 480.0) or (1.333, 1.0) or (1.333, 0.0)";
	ui_category = "Pixel Test Advanced Settings";
	ui_spacing = 1;
> = float2(0.000, 0.000);

uniform float2 OffGame_scale <
	ui_type = "drag";
	ui_min = 0.001f;
	ui_max = 2.000f;
	ui_step = 0.001f;
	ui_label = "OffGame Scale Setting X/Y";
	ui_tooltip = "Only applied when Pixel-Test fails";
	ui_category = "Pixel Test Advanced Settings";
> = float2(1.000, 1.000);

uniform float2 OffGame_offset <
	ui_type = "drag";
	ui_min = -1.000f;
	ui_max = 1.000f;
	ui_step = 0.001f;
	ui_label = "OffGame Offset Setting X/Y";
	ui_tooltip = "Only applied when Pixel-Test fails";
	ui_category = "Pixel Test Advanced Settings";
> = float2(0.000, 0.000);


#ifdef CRT_SHADER
// CRT Effect Settings
uniform bool CRT_EFFECT <
	ui_label = "CRT EFFECT";
	ui_tooltip = "To enable the CRT effect";
> = false;

uniform int aperture_type <
	ui_type = "combo";
	ui_items = " Simulated Aperture (Green/Magenta) \0 Dot-Mask Texture 1x1 \0 Dot-Mask Texture 2x2 \0";
	ui_label = "CRT-Effect Aperture Type";
	ui_category = "CRT Effect Settings";
> = 0;

uniform float2 texture_size <
	ui_type = "inp";
	ui_label = "Set The Simulated CRT Texture Resolution X/Y (pixels)";
	ui_tooltip = "This is the native low resolution of the game used to build the scanline effect (0.0 = Not Defined / Auto)";
	ui_category = "CRT Effect Settings";
> = float2(0.0, 0.0);

uniform bool VERTICAL_SCANLINES <
	ui_label = "VERTICAL SCANLINES";
	ui_tooltip = "To get a vertical scanlines without rotating the display";
	ui_category = "CRT Effect Settings";
> = false;

// CRT Advanced Settings
uniform float2 buffer_offset <
	ui_type = "drag";
	ui_min = -5.0f;
	ui_max = 5.0f;
	ui_step = 0.1f;
	ui_label = "Offset Against The Buffer X/Y (pixels)";
	ui_tooltip = "Allows to set a small offset on the effect. Needed sometime to perfectly match the game texture";
	ui_category = "CRT Advanced Settings";
	ui_category_closed = true;
> = float2(0.0, 0.0);

uniform int TEXTURE_ROUND <
	ui_type = "combo";
	ui_items = " Disabled \0 Round Down \0 Round Up \0";
	ui_label = "ROUND CALCULATED SIZE";
	ui_tooltip = "To round the calculated Texture Size (when a dimension is set to 0)";
	ui_category = "CRT Advanced Settings";
> = 0;

#ifndef PIN_SHADER
uniform bool TEXTURE_CROP <
	ui_label = "CROP SIZED TEXTURE";
	ui_tooltip = "Texture Resolution defined according to the Crop Ratio";
	ui_category = "CRT Advanced Settings";
> = false;
#endif

uniform bool BLOOM <
	ui_label = "BLOOM";
	ui_tooltip = "To enable the CRT Bloom effect";
	ui_category = "CRT Advanced Settings";
> = true;

uniform float BloomStrength <
	ui_type = "slider";
	ui_min = 0.0f;
	ui_max = 1.0f;
	ui_step = 0.01f;
	ui_label = "Bloom Strength";
	ui_tooltip = "Adjusts the strength of the Bloom effect.";
	ui_category = "CRT Advanced Settings";
> = 0.22f;

uniform bool OVERSAMPLE <
	ui_label = "OVERSAMPLE";
	ui_tooltip = "Enable 3x oversampling of the beam profile (to reduce the moire effect caused by scanlines + curvature)";
	ui_category = "CRT Advanced Settings";
> = true;

uniform float ovs_boost <
	ui_type = "slider";
	ui_min = 1.0f;
	ui_max = 3.0f;
	ui_step = 0.01f;
	ui_label = "Oversample Booster";
	ui_tooltip = "Attempts to reduce even more the moire effect (but it kills the pixel aspect)";
	ui_category = "CRT Advanced Settings";
> = 1.0f;

uniform float dotmask <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 0.9f;
	ui_step = 0.01f;
	ui_label = "Dot-Mask Strength";
	ui_category = "CRT Advanced Settings";
> = 0.22f;

uniform float dotbright <
	ui_type = "slider";
	ui_min = 0.0f;
	ui_max = 1.0f;
	ui_step = 0.01f;
	ui_label = "Dot-Mask Bright Boost";
	ui_category = "CRT Advanced Settings";
> = 0.33f;

uniform float lum <
	ui_type = "slider";
	ui_min = 0.4f;
	ui_max = 1.0f;
	ui_step = 0.01f;
	ui_label = "Luminance Boost";
	ui_category = "CRT Advanced Settings";
> = 0.88f;

uniform float CRTgamma <
	ui_type = "slider";
	ui_min  = 0.1f;
	ui_max = 5.0f;
	ui_step = 0.01f;
	ui_label = "Target Gamma";
	ui_category = "CRT Advanced Settings";
> = 2.4f;

uniform float monitorgamma <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 5.0f;
	ui_step = 0.01f;
	ui_label = "Monitor Gamma";
	ui_category = "CRT Advanced Settings";
> = 2.2f;
#endif


#ifdef CRV_SHADER
uniform bool CURVATURE <
	ui_label = "CURVATURE";
	ui_tooltip = "To enable the screen curvature effect";
> = false;

// Curvature Advanced Settings
uniform float curv_boost <
	ui_type = "slider";
	ui_min = 0.00f;
	ui_max = 2.00f;
	ui_step = 0.01f;
	ui_label = "Curvature Boost";
	ui_tooltip = "Enforce the curvature effect";
	ui_category = "Curvature Advanced Settings";
	ui_category_closed = true;
> = 1.25f;

uniform float cornersize <
	ui_type = "slider";
	ui_min = 0.000f;
	ui_max = 0.100f;
	ui_step = 0.001f;
	ui_label = "Corner Size";
	ui_category = "Curvature Advanced Settings";
> = 0.015f;

uniform float cornersmooth <
	ui_type = "slider";
	ui_min = 10.0f;
	ui_max = 300.0f;
	ui_step = 1.0f;
	ui_label = "Corner Smoothness";
	ui_category = "Curvature Advanced Settings";
> = 175.0f;

uniform float2 aspect <
	ui_type = "drag";
	ui_min = 0.10f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "Aspect X/Y";
	ui_category = "Curvature Advanced Settings";
> = float2(1.00, 1.00);

uniform float R <
	ui_type = "slider";
	ui_min = 0.0f;
	ui_max = 10.0f;
	ui_step = 0.1f;
	ui_label = "Curvature Radius";
	ui_category = "Curvature Advanced Settings";
> = 2.4f;

uniform float d <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 3.0f;
	ui_step = 0.1f;
	ui_label =  "Distance";
	ui_category = "Curvature Advanced Settings";
> = 2.4f;

uniform float2 tilt <
	ui_type = "drag";
	ui_min = -0.50f;
	ui_max = 0.50f;
	ui_step = 0.01f;
	ui_label = "Tilt X/Y";
	ui_category = "Curvature Advanced Settings";
> = float2(0.00, 0.00);
#endif


#if defined CRT_SHADER || defined FRAME_RFLX
// Bloom/Blur Settings
uniform float BloomBlurContrast <
	ui_type = "slider";
	ui_min = 0.00;
	ui_max = 1.00;
	ui_step = 0.01f;
	ui_label = "Bloom/Blur Contrast";
	ui_tooltip = "Adjusts the contrast of the bloom/blur effect.";
	ui_category = "Bloom/Blur Settings";
> = 0.85f;

uniform float BloomBlurOffset <
	ui_type = "slider";
	ui_min = 1.00f;
	ui_max = 4.00f;
	ui_step = 0.01f;
	ui_label = "Bloom/Blur Offset";
	ui_tooltip = "Additional adjustment for the bloom/blur radius. Values less than 1.00 will reduce the radius.";
	ui_category = "Bloom/Blur Settings";
	ui_category_closed = true;
> = 2.0f;
#endif


#ifdef CRV_SHADER
uniform bool USE_FRAME <
	ui_label = "SCREEN FRAME";
	ui_tooltip = "To add a screen frame overlay over the display area";
#ifdef CRT_SHADER
> = true;
#else
> = false;
#endif

// Frame Advanced Settings
uniform float2 Frame_size <
	ui_type = "drag";
	ui_min = 0.000f;
	ui_max = 1.000f;
	ui_step = 0.001f;
	ui_label = "Frame border size X/Y";
	ui_tooltip = "To adjust the screen size in the frame";
	ui_category = "Frame Advanced Settings";
	ui_category_closed = true;
> = float2(0.033, 0.033);

#ifdef FRAME_RFLX
uniform float ReflectionFallOff <
	ui_type = "slider";
	ui_min = 0.00f;
	ui_max = 1.00f;
	ui_step = 0.01f;
	ui_label = "Frame Reflection Fall Off";
	ui_tooltip = "Simulate reflection fall off";
	ui_category = "Frame Advanced Settings";
> = 0.4f;

uniform float ReflectionStretch <
	ui_type = "slider";
	ui_min = 0.1f;
	ui_max = 3.0f;
	ui_step = 0.1f;
	ui_label = "Frame Reflection Stretch";
	ui_tooltip = "Simulate reflection angle";
	ui_category = "Frame Advanced Settings";
> = 1.0f;
#endif
#endif


#ifndef PIN_SHADER
// Bezel Overlay Settings
uniform int USE_BEZEL <
	ui_type = "combo";
	ui_items = " Disabled \0 Enabled \0 Linked \0";
	ui_label = "BEZEL OVERLAY";
	ui_tooltip = "To add a bezel overlay over the display area - Linked will follow the game rotation and proportions";
	ui_spacing = 1;
> = 0;

uniform bool BEZEL_BACK <
	ui_label = "BEZEL IN BACKGROUND";
	ui_tooltip = "To put the bezel image in background (behind the game area)";
	ui_category = "Bezel Overlay Advanced Settings";
	ui_category_closed = true;
> = true;

uniform float2 Bezel_ratio <
	ui_type = "input";
	ui_min = 0.200f;
	ui_max = 5.000f;
	ui_step = 0.001f;
	ui_label = "Bezel Ratio Setting";
	ui_tooltip = "The ratio of the bezel image - Example : 16:9 ratio can be set (16.0, 9.0) or (1280.0, 720.0) or (1.778, 1.0) or (1.778, 0.0)";
	ui_category = "Bezel Overlay Advanced Settings";
> = float2(16.000, 9.000);

uniform float2 Bezel_zoom <
	ui_type = "drag";
	ui_min = 1.0f;
	ui_max = 300.0f;
	ui_step = 0.1f;
	ui_label = "Manual Bezel Zoom X/Y (%)";
	ui_category = "Bezel Overlay Advanced Settings";
> = float2(100.0, 100.0);

uniform float2 Bezel_trans <
	ui_type = "drag";
	ui_min = -100.00f;
	ui_max = 100.00f;
	ui_step = 0.10f;
	ui_label = "Manual Bezel Translation X/Y (%)";
	ui_category = "Bezel Overlay Advanced Settings";
> = float2(0.00, 0.00);

#else

uniform bool USE_APRON <
	ui_label = "APRON IMAGE";
> = false;

// BackGlass Settings
uniform bool USE_BACKGLASS <
	ui_label = "BACKGLASS IMAGE";
	ui_category = "BackGlass Settings";
	ui_category_closed = true;
> = false;

uniform bool NO_GRILL <
	ui_label = "NO GRILL";
	ui_tooltip = "To hide the grill even with a backglass ratio lower than 16:10";
	ui_category = "BackGlass Settings";
> = false;

uniform int2 BackGlassScreen_resolution <
	ui_type = "input";
	ui_label = "BackGlass Resolution X/Y (pixels)";
	ui_category = "BackGlass Settings";
> = int2(0, 0);

uniform int2 BackGlassScreen_position <
	ui_type = "input";
	ui_label = "BackGlass Position X/Y (TopLeft corner)";
	ui_category = "BackGlass Settings";
> = int2(0, 0);

uniform int2 BackGlassOriginal_resolution <
	ui_type = "input";
	ui_label = "Original BackGlass Resolution X/Y (pixels)";
	ui_tooltip = "Should be defined in backbuffer with a resolution of 1920x1080";
	ui_category = "BackGlass Settings";
	ui_spacing = 1;
> = int2(0, 0);

uniform int2 BackGlassOriginal_position <
	ui_type = "input";
	ui_label = "Original BackGlass Position X/Y (TopLeft corner)";
	ui_tooltip = "Should be defined in backbuffer with a resolution of 1920x1080";
	ui_category = "BackGlass Settings";
> = int2(0, 0);


// DMD Settings
uniform bool USE_DMD <
	ui_label = "DMD DISPLAY";
	ui_category = "DMD Settings";
	ui_category_closed = true;
> = false;

uniform int2 DMDScreen_resolution <
	ui_type = "input";
	ui_label = "DMD Resolution X/Y (pixels)";
	ui_category = "DMD Settings";
> = int2(0, 0);

uniform int2 DMDScreen_position <
	ui_type = "input";
	ui_label = "DMD Position X/Y (TopLeft corner)";
	ui_category = "DMD Settings";
> = int2(0, 0);

uniform int2 DMDOriginal_resolution <
	ui_type = "input";
	ui_label = "Original DMD Resolution X/Y (pixels)";
	ui_tooltip = "Should be defined in backbuffer with a resolution of 1920x1080";
	ui_category = "DMD Settings";
	ui_spacing = 1;
> = int2(0, 0);

uniform int2 DMDOriginal_position <
	ui_type = "input";
	ui_label = "Original DMD Position X/Y (TopLeft corner)";
	ui_tooltip = "Should be defined in backbuffer with a resolution of 1920x1080";
	ui_category = "DMD Settings";
> = int2(0, 0);

#ifdef DMD_BGND
uniform int2 BackImage_resolution <
	ui_type = "input";
	ui_label = "BackGround Image Resolution X/Y (pixels)";
	ui_category = "DMD Settings";
	ui_spacing = 1;
> = int2(0, 0);

uniform int2 BackImage_position <
	ui_type = "input";
	ui_label = "BackGround Image Position X/Y (TopLeft corner)";
	ui_category = "DMD Settings";
> = int2(0, 0);
#endif
#endif



texture BackBufferTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler BackBufferSampler { Texture = BackBufferTex; };

texture GameCopyTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler GameCopySampler { Texture = GameCopyTex; };

#ifdef CRV_SHADER
texture frame_texture <source="frame.png";> { Width = 720; Height = 720; Format = RGBA8; };
sampler frame_sampler { Texture = frame_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
#endif

#if defined CRT_SHADER || defined FRAME_RFLX
texture BloomBlurTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler BloomBlurSampler { Texture = BloomBlurTex; };

#ifndef PERF_MODE
texture BloomBlurTex1 { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };
sampler BloomBlurSampler1 { Texture = BloomBlurTex1; };

texture BloomBlurTex2 { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };
sampler BloomBlurSampler2 { Texture = BloomBlurTex2; };
#else
texture BloomBlurTex1 { Width = BUFFER_WIDTH / 4; Height = BUFFER_HEIGHT / 4; Format = RGBA8; };
sampler BloomBlurSampler1 { Texture = BloomBlurTex1; };

texture BloomBlurTex2 { Width = BUFFER_WIDTH / 4; Height = BUFFER_HEIGHT / 4; Format = RGBA8; };
sampler BloomBlurSampler2 { Texture = BloomBlurTex2; };
#endif
#endif

#ifdef CRT_SHADER
texture mask_texture <source="mask.png";> { Width = 48; Height = 32; Format = RGBA8; };
sampler mask_sampler { Texture = mask_texture; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP; };

texture mask2x2_texture <source="mask2x2.png";> { Width = 96; Height = 80; Format = RGBA8; };
sampler mask2x2_sampler { Texture = mask2x2_texture; AddressU = WRAP; AddressV = WRAP; AddressW = WRAP; };
#endif

#ifndef PIN_SHADER
texture bezel_texture <source="bezel.png";> { Width = 1920; Height = 1080; Format = RGBA8; };
sampler bezel_sampler { Texture = bezel_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture bezel_off_texture <source="bezel_off.png";> { Width = 1920; Height = 1080; Format = RGBA8; };
sampler bezel_off_sampler { Texture = bezel_off_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture bezelv_texture <source="bezelv.png";> { Width = 1920; Height = 1080; Format = RGBA8; };
sampler bezelv_sampler { Texture = bezelv_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture bezelv_off_texture <source="bezelv_off.png";> { Width = 1920; Height = 1080; Format = RGBA8; };
sampler bezelv_off_sampler { Texture = bezelv_off_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

#ifdef BGND_TEX
texture background_texture <source="background.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler background_sampler { Texture = background_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
#endif
#else
texture apron_texture <source="apron.png";> { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler apron_sampler { Texture = apron_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture backglass_texture <source="backglass.png";> { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler backglass_sampler { Texture = backglass_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture backglass_off_texture <source="backglass_off.png";> { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT; Format = RGBA8; };
sampler backglass_off_sampler { Texture = backglass_off_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

texture dmd_off_texture <source="dmd_off.png";> { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };
sampler dmd_off_sampler { Texture = dmd_off_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };

#ifdef DMD_BGND
texture background_texture <source="background.png";> { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA8; };
sampler background_sampler { Texture = background_texture; AddressU = BORDER; AddressV = BORDER; AddressW = BORDER; };
#endif
#endif


#if defined CRT_SHADER || defined CRV_SHADER
#define FIX(c) max(abs(c), 1e-5)
#endif
#define GameScreen_scale float2(GameScreen_zoom.x / 100.0f, GameScreen_zoom.y / 100.0f)
#define GameScreen_offset float2(GameScreen_trans.x / 100.0f, GameScreen_trans.y / 100.0f)
#ifndef PIN_SHADER
#define Bezel_scale float2(Bezel_zoom.x / 100.0f, Bezel_zoom.y / 100.0f)
#define Bezel_offset float2(Bezel_trans.x / 100.0f, Bezel_trans.y / 100.0f)
#else
#define BG_DISPLAY (USE_BACKGLASS && (BackGlassScreen_resolution.x > 0) && (BackGlassScreen_resolution.y > 0))
#define BG_CATCH ((BackGlassOriginal_resolution.x > 0) && (BackGlassOriginal_resolution.y > 0))
#define DMD_DISPLAY (USE_DMD && (DMDScreen_resolution.x > 0) && (DMDScreen_resolution.y > 0))
#define DMD_CATCH ((DMDOriginal_resolution.x > 0) && (DMDOriginal_resolution.y > 0))
#endif
static const float2 FullScreen_size = float2(ReShade::ScreenSize.x, ReShade::ScreenSize.y);
static const float Standard_ratio = 16.0f / 9.0f;
static const float2 Standard_size = float2(1920.0, 1080.0);
#ifdef CRT_SHADER
static const float PI = 3.141592653589;
#endif
#ifdef PIN_SHADER
static const float BackGlass_ratio = 5.0f / 4.0f;
#else
static const float2 GameScreen_resolution = float2(ReShade::ScreenSize.x, ReShade::ScreenSize.y);
#endif



// General Functions
float2 GetSize(float2 given_size, float2 default_size)
{
	if (given_size.x < 1.0f)
		given_size.x = default_size.x;
	if (given_size.y < 1.0f)
		given_size.y = default_size.y;
	return given_size;
}


float GetRatio(float2 given_ratio, float2 default_ratio)
{
	if (given_ratio.y > 0.0f)
		given_ratio.x /= given_ratio.y;
	if ((given_ratio.x < 0.2f) || (given_ratio.x > 5.0f))
	{
		given_ratio.x = default_ratio.x;
		if (default_ratio.y > 0.0f)
			given_ratio.x /= default_ratio.y;
	}
	return given_ratio.x;
}



// Video Resize
float2 VideoSize(float2 full_video_size)
{
	float CenterLockedRatio = GetRatio(CenterLocked_ratio, full_video_size);
	float full_video_ratio = full_video_size.x / full_video_size.y;
	float2 resize_ratio = 1.0f;
	if (CenterLockedRatio < full_video_ratio)
		resize_ratio.x = CenterLockedRatio / full_video_ratio;
	else
		resize_ratio.y = full_video_ratio / CenterLockedRatio;
	return full_video_size * resize_ratio;
}


float2 CropRatioFix(bool PIXEL_TESTS, float2 full_video_size)
{
	float2 CropFix = 0.0f;
#ifndef PIN_SHADER
	if (PIXEL_TESTS || CROP_OFF)
	{
		float video_ratio = GetRatio(CenterLocked_ratio, full_video_size);;
		float crop_ratio = GetRatio(Crop_ratio, float2(video_ratio, 1.0));
		if (crop_ratio < video_ratio)
			CropFix.x = 1.0f - (crop_ratio / video_ratio);
		else
			CropFix.y = 1.0f - (video_ratio / crop_ratio);
	}
#endif
	return CropFix;
}


float4 Starts(float2 full_video_size, float2 CropFix)
{
#ifndef PIN_SHADER
	float2 h_start = float2(CropFix.x / 2.0f, 1.0f - CropFix.x / 2.0f) + float2(h_starts.x / 100.0f, h_starts.y / 100.0f - 1.0f) * (1.0f - CropFix.x);
	float2 v_start = float2(CropFix.y / 2.0f, 1.0f - CropFix.y / 2.0f) + float2(v_starts.x / 100.0f, v_starts.y / 100.0f - 1.0f) * (1.0f - CropFix.y);
	return float4(h_start, v_start);
#else
	return float4(0.0, 1.0, 0.0, 1.0);
#endif
}



// Pixel Tests
bool PIXELTESTS(float2 video_size, float2 full_video_size)
{
	// Position should be defined "stretched" in 1920x1080 (standard resolution)
	bool TEST = true;
	if (PIXEL_TEST)
	{
		float2 offset = (full_video_size - video_size) / FullScreen_size / 2.0f;
		float2 scale = video_size / FullScreen_size;
		float3 delta = tex2D(ReShade::BackBuffer, (test_pixel * scale / Standard_size + offset)).rgb - test_color;
		if (test_epsilon < dot(delta, delta))
			TEST = false;
#ifdef DBLE_TESTS
		delta = tex2D(ReShade::BackBuffer, (test_pixel2 * scale / Standard_size + offset)).rgb - test_color2;
		if (test_epsilon < dot(delta, delta))
			TEST = false;
#endif
		if (PIXEL_TEST == 2)
			TEST = !TEST;
	}
	return TEST;
}



// OUTS
#ifndef PIN_SHADER
bool OUT_STARTS(float2 uv, bool PIXEL_TESTS, float2 h_start, float2 v_start)
{
	if (!PIXEL_TESTS && !CROP_OFF)
	{
		if ((0.0f <= uv.x) && (uv.x <= 1.0f) && (0.0f <= uv.y) && (uv.y <= 1.0f))
			return false;
	}
	else if ((h_start.x <= uv.x) && (uv.x <= h_start.y) && (v_start.x <= uv.y) && (uv.y <= v_start.y))
		return false;
	return true;
}

#else

bool OUT_SCREEN(float2 uv, float2 Screen_size, float2 Screen_pos, bool BG_GRILL)
{
	Screen_size /= FullScreen_size;
	if (BG_GRILL)
		Screen_size.y *= BackGlass_ratio / Standard_ratio;
	Screen_pos /= FullScreen_size;
	if ((Screen_pos.x < uv.x) && (uv.x < Screen_pos.x + Screen_size.x) && (Screen_pos.y < uv.y) && (uv.y < Screen_pos.y + Screen_size.y))
		return false;
	return true;
}
#endif


bool OUT_DISPLAY(float2 uv)
{
	if ((0.0f <= uv.x) && (uv.x <= 1.0f) && (0.0f <= uv.y) && (uv.y <= 1.0f))
		return false;
	return true;
}



// Display ReSize
float GameRatio(bool PIXEL_TESTS, bool ROTATED, float2 full_video_size)
{
	float original_ratio = GetRatio(CenterLocked_ratio, full_video_size);
	float game_ratio = GetRatio(InGame_ratio, float2(original_ratio, 1.0));
	if (!PIXEL_TESTS)
		game_ratio = GetRatio(OffGame_ratio, float2(game_ratio, 1.0));
#ifndef PIN_SHADER
	if ((PIXEL_TESTS || CROP_OFF) && EXPAND_CROP)
	{
		float crop_ratio = GetRatio(Crop_ratio, float2(game_ratio, 1.0));
		if (crop_ratio != game_ratio)
			game_ratio = crop_ratio * game_ratio / original_ratio;
	}
#endif
	if (ROTATED)
		game_ratio = 1.0f / game_ratio;
	return game_ratio;
}


float2 RatioFix(bool PIXEL_TESTS, bool ROTATED, float2 GameScreen_size, float2 full_video_size, float2 CropFix)
{
	float2 ratio_fix = 1.0f;
	if (!FULL_STRETCH)
	{
		float GameScreen_ratio = GameScreen_size.x / GameScreen_size.y;
		float game_ratio = GameRatio(PIXEL_TESTS, ROTATED, full_video_size);
		if (game_ratio < GameScreen_ratio)
			ratio_fix.x = game_ratio / GameScreen_ratio;
		else
			ratio_fix.y = GameScreen_ratio / game_ratio;
	}
#ifndef PIN_SHADER
	if ((PIXEL_TESTS || CROP_OFF) && EXPAND_CROP)
	{
		if (ROTATED)
			CropFix = float2(CropFix.y, CropFix.x);
		ratio_fix /= (1.0f - CropFix);
	}
#endif
	return ratio_fix;
}



#ifdef CRV_SHADER
// Curvature
float intersect(float2 xy, float2 sinangle, float2 cosangle)
{
	float A = dot(xy, xy) + d * d;
	float B = 2.0f * (R * (dot(xy, sinangle) - d * cosangle.x * cosangle.y) - d * d);
	float C = d * d + 2.0f * R * d * cosangle.x * cosangle.y;
	return (-B - sqrt(B * B - 4.0f * A * C)) / (2.0f * A);
}


float2 bkwtrans(float2 xy, float2 sinangle, float2 cosangle)
{
	float c = intersect(xy, sinangle, cosangle);
	float2 pnt = c * xy;
	pnt += R * sinangle;
	pnt /= R;
	float2 tang = sinangle / cosangle;
	float2 poc = pnt / cosangle;
	float A = dot(tang, tang) + 1.0f;
	float B = -2.0f * dot(poc, tang);
	float C = dot(poc, poc) - 1.0f;
	float a = (-B + sqrt(B * B - 4.0f * A * C)) / (2.0f * A);
	float2 uv = (pnt - a * sinangle) / cosangle;
	float r = FIX(R * acos(a));
	return uv * r / sin(r / R);
}


float2 fwtrans(float2 uv, float2 sinangle, float2 cosangle)
{
	float r = FIX(sqrt(dot(uv, uv)));
	uv *= sin(r / R) / r;
	float x = 1.0f - cos(r / R);
	float D = d / R + x * cosangle.x * cosangle.y + dot(uv, sinangle);
	return d * (uv * cosangle-x * sinangle) / D;
}


float3 maxscale(float2 sinangle, float2 cosangle)
{
	float2 c = bkwtrans(-R * sinangle / (1.0f + R / d * cosangle.x * cosangle.y), sinangle, cosangle);
	float2 a = 0.5f * aspect;
	float2 lo = float2(fwtrans(float2(-a.x, c.y), sinangle, cosangle).x,
					   fwtrans(float2(c.x, -a.y), sinangle, cosangle).y) / aspect;
	float2 hi = float2(fwtrans(float2(+a.x, c.y), sinangle, cosangle).x,
					   fwtrans(float2(c.x, +a.y), sinangle, cosangle).y) / aspect;
	return float3((hi + lo) * aspect * 0.5f, max(hi.x - lo.x, hi.y - lo.y));
}


float2 curv(float2 xy)
{
	float2 sinangle = sin(float2(tilt.x, tilt.y));
	float2 cosangle = cos(float2(tilt.x, tilt.y));
	float3 stretch = maxscale(sinangle, cosangle);
	
	xy = (xy - (0.5f, 0.5f)) * aspect * stretch.z + stretch.xy;
	return bkwtrans(xy, sinangle, cosangle) / aspect + (0.5f, 0.5f);
}


float corner(float2 xy)
{
	xy = min(xy, (1.0f, 1.0f) - xy) * aspect;
	float2 cdist = float2(cornersize, cornersize);
	xy = (cdist - min(xy, cdist));
	float dist = sqrt(dot(xy, xy));
	return clamp((cdist.x - dist) * cornersmooth, 0.0f, 1.0f);
}
#endif



// UVs Definitions
float2 GameScreenUV(float2 uv, bool ROTATED, float2 GameScreen_size, float2 ratio_fix)
{
#ifdef PIN_SHADER
	uv += (FullScreen_size - GameScreen_size) / 2.0f / FullScreen_size;
	uv = (uv - (0.5f, 0.5f)) * FullScreen_size / (GameScreen_size * ratio_fix) + (0.5f, 0.5f);
#else
	uv = (uv - (0.5f, 0.5f)) / ratio_fix + (0.5f, 0.5f);
#endif
	if (ROTATED_180)
		uv = float2(1.0f - uv.x, 1.0f - uv.y);
	if (ROTATED)
	{
#ifndef PIN_SHADER
		if (NO_ROTATE == 3)
			uv = float2(uv.y, 1.0f - uv.x);
		else
#endif
			uv = float2(1.0f - uv.y, uv.x);
	}
	uv = (uv - (0.5f, 0.5f)) / GameScreen_scale + (0.5f, 0.5f) - GameScreen_offset;
	return uv;
}


float2 GameUV(float2 uv, bool PIXEL_TESTS)
{
	if (!PIXEL_TESTS)
		uv = (uv - (0.5f, 0.5f)) / OffGame_scale + (0.5f, 0.5f) - OffGame_offset;
#ifndef PIN_SHADER
	else
		uv = (uv - (0.5f, 0.5f)) / InGame_scale + (0.5f, 0.5f) - InGame_offset;
#endif
	return uv;
}


#ifndef PIN_SHADER
float2 DimUV(float2 uv, float2 h_start, float2 v_start)
{
	uv.x = (uv.x - h_start.x) / (h_start.y - h_start.x);
	uv.y = (uv.y - v_start.x) / (v_start.y - v_start.x);
	return uv;
}
#endif


#ifdef CRV_SHADER
float2 FrameFix(float2 uv)
{
	float coef = (CURVATURE) ? 1.0f : 0.75f;
	return (uv - (0.5f, 0.5f)) * ((1.0f, 1.0f) + Frame_size * coef) + (0.5f, 0.5f);
}


#ifdef FRAME_RFLX
float3 ReflectionUV(float2 uv)
{
	float k = 1.0f;
	if ((uv.x <= 0.0f) && (uv.x < uv.y) && (uv.x < 1.0f - uv.y))
	{
		k += uv.x * 10.0f / ReflectionFallOff;
		uv.y = (uv.y - 0.5f) * (0.5f + uv.x) / 0.5f + 0.5f;
		uv.x = -ReflectionStretch * uv.x;
	}
	else if ((1.0f <= uv.x) && (1.0f - uv.x < uv.y) && (1.0f - uv.x < 1.0f - uv.y))
	{
		k += (1.0f - uv.x) * 10.0f / ReflectionFallOff;
		uv.y = (uv.y - 0.5f) * (0.5f + 1.0f - uv.x) / 0.5f + 0.5f;
		uv.x = 1.0f + ReflectionStretch * (1.0f - uv.x);
	}
	else if (uv.y <= 0.0f)
	{
		k += uv.y * 10.0f / ReflectionFallOff;
		uv.x = (uv.x - 0.5f) * (0.5f + uv.y) / 0.5f + 0.5f;
		uv.y = -ReflectionStretch * uv.y;
	}
	else if (1.0f <= uv.y)
	{
		k += (1.0f - uv.y) * 10.0f / ReflectionFallOff;
		uv.x = (uv.x - 0.5f) * (0.5f + 1.0f - uv.y) / 0.5f + 0.5f;
		uv.y = 1.0f + ReflectionStretch * (1.0f - uv.y);
	}
	k = clamp(k, 0.0f, 1.0f);
	return float3(uv, k * k);
}
#endif
#endif


#ifndef PIN_SHADER
float2 BezelUV(float2 uv)
{
	if (ROTATED_180)
		uv = float2(1.0f - uv.x, 1.0f - uv.y);
	float GameScreen_ratio = FullScreen_size.x / FullScreen_size.y;
	if (((NO_ROTATE != 1) && FullScreen_size.x < FullScreen_size.y))	// Vertical screen
	{
		GameScreen_ratio = 1.0f / GameScreen_ratio;
		uv = (uv - (0.5f, 0.5f)) / Bezel_scale * float2(1.0, GameScreen_ratio / GetRatio(Bezel_ratio, float2(GameScreen_ratio, 1.0))) + (0.5f, 0.5f) - Bezel_offset;
		uv = float2(1.0f - uv.y, uv.x);
	}
	else
		uv = (uv - (0.5f, 0.5f)) / Bezel_scale * float2(GameScreen_ratio / GetRatio(Bezel_ratio, float2(GameScreen_ratio, 1.0)), 1.0) + (0.5f, 0.5f) - Bezel_offset;
	return uv;
}

#else

float2 BackGlassUV(float2 uv, float2 BackGlassScreen_size, float2 BackGlassScreen_pos, bool BG_GRILL)
{
	uv = (uv * FullScreen_size - BackGlassScreen_pos) / BackGlassScreen_size;
	if (!BG_GRILL)
		uv.y *= BackGlass_ratio / Standard_ratio;
	return uv;
}


float2 BackGlassScreenUV(float2 uv, bool PIXEL_TESTS, float2 BackGlassScreen_size, float2 BackGlassScreen_pos, bool BG_GRILL)
{
	if (PIXEL_TESTS && BG_CATCH)
	{
		float2 BackGlassOriginal_size = BackGlassOriginal_resolution;
		float2 BackGlassOriginal_pos = BackGlassOriginal_position;
		uv = (uv * FullScreen_size - BackGlassScreen_pos) * BackGlassOriginal_size / BackGlassScreen_size + BackGlassOriginal_pos;
		uv /= Standard_size;  // Original size defined in 1920x1080 (standard resolution)
	}
	else
		uv = (uv * FullScreen_size - BackGlassScreen_pos) / BackGlassScreen_size;
	if (BG_GRILL)
		uv.y /= BackGlass_ratio / Standard_ratio;
	return uv;
}


float2 DMDScreenUV(float2 uv, bool PIXEL_TESTS, bool DMD_ROTATE, bool DMD_ROTATE180, float2 DMDScreen_size, float2 DMDScreen_pos)
{
	if (PIXEL_TESTS && DMD_CATCH)
	{
		float2 DMDOriginal_size = DMDOriginal_resolution;
		float2 DMDOriginal_pos = DMDOriginal_position;
		if (DMD_ROTATE)
		{
			DMDOriginal_pos.x = Standard_size.x - DMDOriginal_pos.x - DMDOriginal_size.x;
			DMDOriginal_pos = float2(DMDOriginal_pos.y * Standard_ratio, DMDOriginal_pos.x / Standard_ratio);
			DMDOriginal_size = float2(DMDOriginal_size.y * Standard_ratio, DMDOriginal_size.x / Standard_ratio);
		}
		if (DMD_ROTATE180)
			DMDOriginal_pos = Standard_size - DMDOriginal_pos - DMDOriginal_size;
		uv = (uv * FullScreen_size - DMDScreen_pos) * DMDOriginal_size / DMDScreen_size + DMDOriginal_pos;
		uv /= Standard_size;  // Original size defined in 1920x1080 (standard resolution)
	}
	else
		uv = (uv * FullScreen_size - DMDScreen_pos) / DMDScreen_size;
	if (DMD_ROTATE)
		uv = float2(1.0f - uv.y, uv.x);
	if (DMD_ROTATE180)
		uv = float2(1.0f - uv.x, 1.0f - uv.y);
	return uv;
}
#endif



#ifdef CRT_SHADER
// CRT Effect
float2 TextureDim(float2 video_size, float2 full_video_size, float2 CropFix)
{
	float2 texture_dim = texture_size;
	if ((texture_dim.x < 1.0f) && (texture_dim.y < 1.0f))
	{
		if (!VERTICAL_SCANLINES)
		{
			texture_dim.y = 240.0f;	// why not?? :)
			texture_dim.x = texture_dim.y * video_size.x / video_size.y;
		}
		else
		{
			texture_dim.x = 320.0f;	// why not?? :)
			texture_dim.y = texture_dim.x * video_size.y / video_size.x;
		}
	}
	else
	{
#ifndef PIN_SHADER
		if (TEXTURE_CROP)
			texture_dim /= (1.0f, 1.0f) - CropFix;
#endif
		if (texture_dim.x < 1.0f)
		{
			texture_dim.x = texture_dim.y * video_size.x / video_size.y;
			if (TEXTURE_ROUND == 1)
				texture_dim.x = floor(texture_dim.x);
			else if (TEXTURE_ROUND == 2)
				texture_dim.x = ceil(texture_dim.x);
		}
		if (texture_dim.y < 1.0f)
		{
			texture_dim.y = texture_dim.x * video_size.y / video_size.x;
			if (TEXTURE_ROUND == 1)
				texture_dim.y = floor(texture_dim.y);
			else if (TEXTURE_ROUND == 2)
				texture_dim.y = ceil(texture_dim.y);
		}
	}
	return texture_dim;
}


float3 TEX2D(float2 c, bool outscreen)
{
	float3 col = (outscreen) ? 0.0f : tex2D(ReShade::BackBuffer, c).rgb;
	return max(col * pow(2.0f, GameBrightness), 0.01f);
}


float3 sample_scanline(float2 xy, float4 coeffs, float one, bool outscreen)
{
	// Calculate the effective colour of the given
	// scanline at the horizontal location of the current pixel,
	// using the Lanczos coefficients.
	if (!VERTICAL_SCANLINES)
		return clamp(TEX2D(xy + float2(-one, 0.0), outscreen) * coeffs.x +
					TEX2D(xy, outscreen) * coeffs.y +
					TEX2D(xy + float2(one, 0.0), outscreen) * coeffs.z +
					TEX2D(xy + float2(2.0f * one, 0.0), outscreen) * coeffs.w, 0.0f, 1.0f);
	else
		return clamp(TEX2D(xy + float2(0.0, -one), outscreen) * coeffs.x +
					TEX2D(xy, outscreen) * coeffs.y +
					TEX2D(xy + float2(0.0, one), outscreen) * coeffs.z +
					TEX2D(xy + float2(0.0, 2.0f * one), outscreen) * coeffs.w, 0.0f, 1.0f);
}


float3 scanlineWeights(float distance, float3 color)
{
	// "wid" controls the width of the scanline beam, for each RGB
	// channel The "weights" lines basically specify the formula
	// that gives you the profile of the beam, i.e. the intensity as
	// a function of distance from the vertical center of the
	// scanline. In this case, it is gaussian if width=2, and
	// becomes nongaussian for larger widths. Ideally this should
	// be normalized so that the integral across the beam is
	// independent of its width. That is, for a narrower beam
	// "weights" should have a higher peak at the center of the
	// scanline than for a wider beam.
	
	float3 wid = 0.3f + 0.1f * pow(color, 3.0f);
	float3 weights = distance / wid;
	return (lum - 0.3f) * exp(-weights * weights) / wid;
}


float fmod(float a, float b)
{
	float c = frac(abs(a / b)) * abs(b);
	return (a < 0) ? -c : c;   // if ( a < 0 ) c = 0 - c
}
#endif



#if defined CRT_SHADER || defined FRAME_RFLX
// Bloom/Blur Effect
float2 BloomFix()
{
	float2 fix = 1.0f; 
	fix.x = GetRatio(GameVideo_resolution, FullScreen_size);
	fix.x = GetRatio(CenterLocked_ratio, float2(fix.x, 1.0));
#ifdef PIN_SHADER
	float2 GameScreen_size = GetSize(GameScreen_resolution, FullScreen_size);
	bool ROTATED = (!NO_ROTATE && GameScreen_size.x > GameScreen_size.y) || NO_ROTATE == 2;
#else
	fix.x = GetRatio(Crop_ratio, float2(fix.x, 1.0));
	bool ROTATED = !NO_ROTATE || (NO_ROTATE == 2 && FullScreen_size.x < FullScreen_size.y) || (NO_ROTATE == 3 && FullScreen_size.x > FullScreen_size.y);
#endif
	if (!ROTATED)
		fix.x /= FullScreen_size.x / FullScreen_size.y;
	fix.x /= Intern_scale.x / Intern_scale.y;
	if (fix.x > 1.0f)
		fix = float2(1.0, 1.0f / fix.x);
	if (ROTATED)
		fix = float2(fix.y, fix.x);
	return fix;
}


float3 BloomBlurCommon(sampler source, float4 pos, float2 uv, float2 dir)
{
	float3 color = tex2D(source, uv).rgb;
	float offset[3] = { 0.0, 1.3846153846, 3.2307692308 };
	float weight[3] = { 0.2270270270, 0.3162162162, 0.0702702703 };
	color *= weight[0];
	
	dir /= BloomFix();
	
	[loop]
	for(int i = 1; i < 3; ++i)
	{
		color += tex2D(source, uv + offset[i] * dir * BloomBlurOffset * 1.0f).rgb * weight[i];
		color += tex2D(source, uv - offset[i] * dir * BloomBlurOffset * 1.0f).rgb * weight[i];
		color += tex2D(source, uv + offset[i] * dir * BloomBlurOffset * 2.0f).rgb * weight[i];
		color += tex2D(source, uv - offset[i] * dir * BloomBlurOffset * 2.0f).rgb * weight[i];
	}
	return color / 2.0f;
}
#endif



#if defined CRT_SHADER || defined FRAME_RFLX
void PS_CRTGeomMod(float4 vpos : SV_Position, float2 uv : TexCoord, out float4 BackBufferCopy : SV_Target0, out float4 GameCopy : SV_Target1, out float3 BloomBlur : SV_Target2)
#else
void PS_CRTGeomMod(float4 vpos : SV_Position, float2 uv : TexCoord, out float4 BackBufferCopy : SV_Target0, out float4 GameCopy : SV_Target1)
#endif
{
	float2 full_video_size = GetSize(GameVideo_resolution, FullScreen_size);
	float2 video_size = VideoSize(full_video_size);
#ifdef PIN_SHADER
	float2 GameScreen_size = GetSize(GameScreen_resolution, FullScreen_size);
	bool ROTATED = (!NO_ROTATE && GameScreen_size.x > GameScreen_size.y) || NO_ROTATE == 2;
#else
	bool ROTATED = !NO_ROTATE || (NO_ROTATE == 2 && FullScreen_size.x < FullScreen_size.y) || (NO_ROTATE == 3 && FullScreen_size.x > FullScreen_size.y);
#endif
	BackBufferCopy = tex2D(ReShade::BackBuffer, ((uv - (0.5f, 0.5f)) * video_size / full_video_size + (0.5f, 0.5f)) * full_video_size / FullScreen_size);
	bool PIXEL_TESTS = PIXELTESTS(video_size, full_video_size);
	if (ROTATED)  // rotate GameCopy and BloomBlur texture display (it looks better!)
		uv = float2(uv.y, uv.x);
#ifdef PIN_SHADER
	float2 apron_uv = 0.0f;
	if (PIXEL_TESTS)
	{
		uv = pow(abs(uv), (1.0f, 1.0f) + float2(InGame_POV.y, InGame_POV.x) * float2(InGamePOV_factor, InGamePOV_factor));
		apron_uv = ((uv - (0.5f, 0.5f)) * video_size / full_video_size + (0.5f, 0.5f)) * full_video_size / FullScreen_size;
		uv = (uv - (0.5f, 0.5f)) * ((1.0f, 1.0f) - InGame_POV * ((1.0f, 1.0f) - float2(uv.y, uv.x))) + (0.5f, 0.5f);
	}
#else
	float2 CropFix = CropRatioFix(PIXEL_TESTS, full_video_size);
	if (PIXEL_TESTS || CROP_OFF)
	{
		float4 starts = Starts(full_video_size, CropFix);
		uv = uv * float2(starts.y - starts.x, starts.w - starts.z) + float2(starts.x, starts.z);
	}
#endif
	// Texture coordinates of the texel containing the active pixel.
	float2 xy0 = uv;
	if (PIXEL_TESTS)
		xy0 = (xy0 - (0.5f, 0.5f)) / Intern_scale + (0.5f, 0.5f) - Intern_offset;
	float2 xy = ((xy0 - (0.5f, 0.5f)) * video_size / full_video_size + (0.5f, 0.5f)) * full_video_size / FullScreen_size;
float3 screen_col = tex2D(ReShade::BackBuffer, xy).rgb;
	if (OUT_DISPLAY(xy))
		screen_col = 0.0f;
#ifdef PIN_SHADER
	if (USE_APRON && PIXEL_TESTS)
	{
		float4 apron = tex2D(apron_sampler, apron_uv);
		screen_col = lerp(screen_col, apron.rgb, apron.a);
	}
#endif
#ifdef CRT_SHADER
	if ((!PIXEL_TESTS && !CRT_EFFECT_OFF) || !CRT_EFFECT)
	{
#endif
	GameCopy = float4(screen_col, 1.0);
#if defined CRT_SHADER || defined FRAME_RFLX
	BloomBlur = pow(screen_col, 1.0f / 2.2f);
#endif
#ifdef CRT_SHADER
	}
	else
	{
		bool outscreen = OUT_DISPLAY(xy);
#ifdef PIN_SHADER
		float2 texture_dim = TextureDim(video_size, full_video_size, 0.0f);
#else
		float2 texture_dim = TextureDim(video_size, full_video_size, CropFix);
#endif
		float2 sc_texture_size = texture_dim * FullScreen_size / video_size;
		float2 one = 1.0f / sc_texture_size;
		
		// Here's a helpful diagram to keep in mind while trying to
		// understand the code:
		//
		//  |      |      |      |      |
		// -------------------------------
		//  |      |      |      |      |
		//  |  00  |  10  |  20  |  30  | <-- previous scanline
		//  |      |      |      |      |
		// -------------------------------
		//  |      |      |      |      |
		//  |  01  |  11  |  21  |  31  | <-- current scanline
		//  |      | @    |      |      |
		// -------------------------------
		//  |      |      |      |      |
		//  |  02  |  12  |  22  |  32  | <-- next scanline
		//  |      |      |      |      |
		// -------------------------------
		//  |      |      |      |      |
		//
		// Each character-cell represents a pixel on the output
		// surface, "@" represents the current pixel (always somewhere
		// in the current scan-line). The grid of lines represents the
		// edges of the texels of the underlying texture.
		// The "deluxe" shader includes contributions from the
		// previous, current, and next scanlines.
		
		// Of all the pixels that are mapped onto the texel we are
		// currently rendering, which pixel are we currently rendering?
#ifdef PERF_MODE
		float2 ratio_scale = xy * sc_texture_size - (0.5f, 0.5f);
		float2 uv_ratio = frac(ratio_scale);
#else
		float2 ratio_scale;
		float2 uv_ratio;
		if (!VERTICAL_SCANLINES)
		{
			ratio_scale = xy * sc_texture_size - float2(0.5, 0.0);
			uv_ratio = frac(ratio_scale) - float2(0.0, 0.5);
		}
		else
		{
			ratio_scale = xy * sc_texture_size - float2(0.0, 0.5);
			uv_ratio = frac(ratio_scale) - float2(0.5, 0.0);
		}
#endif
		
		// Snap to the center of the underlying texel.
		xy = (floor(ratio_scale) + (0.5f, 0.5f)) / sc_texture_size;
		xy += buffer_offset / video_size;
		
		// Calculate Lanczos scaling coefficients describing the effect
		// of various neighbour texels in a scanline on the current pixel.
		if (VERTICAL_SCANLINES)
		{
			uv_ratio = float2(uv_ratio.y, uv_ratio.x);
			texture_dim = float2(texture_dim.y, texture_dim.x);
			video_size = float2(video_size.y, video_size.x);
			xy0 = float2(xy0.y, xy0.x);
		}
		float4 coeffs = PI * float4(1.0f + uv_ratio.x, uv_ratio.x, 1.0f - uv_ratio.x, 2.0f - uv_ratio.x);
		// Prevent division by zero.
		coeffs = FIX(coeffs);
		// Lanczos2 kernel.
		coeffs = 2.0f * sin(coeffs) * sin(coeffs / 2.0f) / (coeffs * coeffs);
		// Normalize.
		coeffs /= dot(coeffs, 1.0f);
		
		// Calculate the effective colour of the current and next
		// scanlines at the horizontal location of the current pixel,
		// using the Lanczos coefficients above.
		float3 col;
#ifndef PERF_MODE
		float3 col_prev;
#endif
		float3 col_next;
		float filter = texture_dim.y / video_size.y;
		if (!VERTICAL_SCANLINES)
		{
			col = sample_scanline(xy, coeffs, one.x, outscreen);
#ifndef PERF_MODE
			col_prev = sample_scanline(xy + float2(0.0,-one.y), coeffs, one.x, outscreen);
#endif
			col_next = sample_scanline(xy + float2(0.0, one.y), coeffs, one.x, outscreen);
			filter /=  Intern_scale.y;
		}
		else
		{
			col = sample_scanline(xy, coeffs, one.y, outscreen);
#ifndef PERF_MODE
			col_prev = sample_scanline(xy + float2(-one.x, 0.0), coeffs, one.y, outscreen);
#endif
			col_next = sample_scanline(xy + float2(one.x, 0.0), coeffs, one.y, outscreen);
			filter /=  Intern_scale.x;
		}
		col = max(pow(col, CRTgamma), 0.003f);
#ifndef PERF_MODE
		col_prev = max(pow(col_prev, CRTgamma), 0.003f);
#endif
		col_next = max(pow(col_next, CRTgamma), 0.003f);
		
		// Calculate the influence of the current and next scanlines on the current pixel
		float3 weights = scanlineWeights(uv_ratio.y, col);
#ifndef PERF_MODE
		float3 weights_prev = scanlineWeights(uv_ratio.y + 1.0f, col_prev);
#endif
		float3 weights_next = scanlineWeights(uv_ratio.y - 1.0f, col_next);
		if (OVERSAMPLE)
		{
			if (ovs_boost > 1.0f)
				filter *= ovs_boost;
			else // auto-boost
			{
#ifndef PIN_SHADER
				float2 GameScreen_size = FullScreen_size;
#endif
				if (ROTATED)
					GameScreen_size = float2(GameScreen_size.y, GameScreen_size.x);
				if (PIXEL_TESTS)
					GameScreen_size *= Intern_scale;
#ifndef PIN_SHADER
				GameScreen_size /= (1.0f, 1.0f) - CropFix;
				if (TEXTURE_CROP)
					GameScreen_size /= (1.0f, 1.0f) - CropFix;
#endif
				if (VERTICAL_SCANLINES)
					GameScreen_size = float2(GameScreen_size.y, GameScreen_size.x);
				if (texture_dim.y / GameScreen_size.y > 0.33f)
					filter *= 2.0f;
				else if (texture_dim.y / GameScreen_size.y > 0.25f)
					filter *= 1.5f;
			}
			uv_ratio.y += 1.0f/3.0f * filter;
			weights = (weights + scanlineWeights(uv_ratio.y, col)) / 3.0f;
#ifndef PERF_MODE
			weights_prev = (weights_prev + scanlineWeights(uv_ratio.y+1.0f, col_prev)) / 3.0f;
#endif
			weights_next = (weights_next + scanlineWeights(uv_ratio.y-1.0f, col_next)) / 3.0f;
			uv_ratio.y -= 2.0f/3.0f * filter;
			weights += scanlineWeights(uv_ratio.y, col) / 3.0f;
#ifndef PERF_MODE
			weights_prev += scanlineWeights(uv_ratio.y+1.0f, col_prev) / 3.0f;
#endif
			weights_next += scanlineWeights(uv_ratio.y-1.0f, col_next) / 3.0f;
		}
#ifdef PERF_MODE
		float3 mul_res = clamp(col * weights + col_next * weights_next, 0.001f, 1.0f);
#else
		float3 mul_res = clamp(col * weights + col_prev * weights_prev + col_next * weights_next, 0.001f, 1.0f);
#endif
		
		// Dot-Mask emulation
		xy = xy0 * texture_dim;
		float base = 1.0f + dotbright;
		if (aperture_type < 1)
		{
			// Output pixels are tinted green and separated magenta.
			float val = fmod(2.0f * xy.x + 1.0f, 2.0f) - 1.0f;
			val = 2.0f * (abs(val) - 0.5f) + 0.5f;
			mul_res *= lerp(float3(base, base - dotmask, base), float3(base - dotmask, base, base - dotmask), val);
		}
		else
		{
			float4 mask = (aperture_type > 1) ? tex2D(mask2x2_sampler, xy / 2.0f) : tex2D(mask_sampler, xy);
			mul_res *= lerp(base, mask.rgb * base, dotmask * mask.a);
		}
		
		// Convert the image gamma for display on our output device.
		GameCopy = float4(pow(mul_res, 1.0f / monitorgamma), 1.0);
		BloomBlur = pow(screen_col, 1.0f / monitorgamma);
	}
#endif
}



#if defined CRT_SHADER || defined FRAME_RFLX
float3 PS_BloomBlurH1(float4 vpos : SV_Position, float2 uv : TexCoord) : COLOR
{
	return BloomBlurCommon(BloomBlurSampler, vpos, uv, float2(ReShade::PixelSize.x, 0.0));
}


float3 PS_BloomBlurV1(float4 vpos : SV_Position, float2 uv : TexCoord) : COLOR
{
	return BloomBlurCommon(BloomBlurSampler1, vpos, uv, float2(0.0, ReShade::PixelSize.y));
}


float3 PS_BloomBlurH2(float4 vpos : SV_Position, float2 uv : TexCoord) : COLOR
{
	return BloomBlurCommon(BloomBlurSampler2, vpos, uv, float2(2.0f * ReShade::PixelSize.x, 0.0));
}


float3 PS_BloomBlurV2(float4 vpos : SV_Position, float2 uv : TexCoord) : COLOR
{
	return BloomBlurCommon(BloomBlurSampler1, vpos, uv, float2(0.0, ReShade::PixelSize.y));
}
#endif



float4 PS_CabView(float4 vpos : SV_Position, float2 uv : TexCoord) : SV_Target
{
	float2 full_video_size = GetSize(GameVideo_resolution, FullScreen_size);
	bool PIXEL_TESTS = PIXELTESTS(VideoSize(full_video_size), full_video_size);
	float2 CropFix = CropRatioFix(PIXEL_TESTS, full_video_size);
	float4 starts = Starts(full_video_size, CropFix);
	float2 h_start = starts.xy;
	float2 v_start = starts.zw;
#ifdef PIN_SHADER
	float2 GameScreen_size = GetSize(GameScreen_resolution, FullScreen_size);
	bool ROTATED = (!NO_ROTATE && GameScreen_size.x > GameScreen_size.y) || NO_ROTATE == 2;
	float2 ratio_fix = RatioFix(PIXEL_TESTS, ROTATED, GameScreen_size, full_video_size, CropFix);
	float2 game_screen_uv = GameScreenUV(uv, ROTATED, GameScreen_size, ratio_fix);
#else
	bool ROTATED = !NO_ROTATE || (NO_ROTATE == 2 && FullScreen_size.x < FullScreen_size.y) || (NO_ROTATE == 3 && FullScreen_size.x > FullScreen_size.y);
	float2 ratio_fix = RatioFix(PIXEL_TESTS, ROTATED, FullScreen_size, full_video_size, CropFix);
	float2 game_screen_uv = GameScreenUV(uv, ROTATED, FullScreen_size, ratio_fix);
#endif
	float2 game_uv = GameUV(game_screen_uv, PIXEL_TESTS);
	
#ifndef PIN_SHADER
	// BEZEL
	float4 bezel = 0.0f;
	if (USE_BEZEL)
	{
		float2 bezel_uv = uv;
		if (USE_BEZEL == 1)
			bezel_uv = BezelUV(uv);
		else
		{
			bezel_uv = game_screen_uv;
			float bezel_ratio = GetRatio(Bezel_ratio, Standard_size);
			float game_ratio = GetRatio(CenterLocked_ratio, full_video_size);
			bezel_uv = (bezel_uv - (0.5f, 0.5f)) / Bezel_scale * float2(game_ratio, 1.0) / float2(bezel_ratio, 1.0) + (0.5f, 0.5f) - Bezel_offset;
		}
		if (NO_ROTATE <= 1)
			bezel = (PIXEL_TESTS || USE_BEZEL_OFF) ? tex2D(bezel_sampler, bezel_uv) : tex2D(bezel_off_sampler, bezel_uv);
		else
			bezel = (PIXEL_TESTS || USE_BEZEL_OFF) ? tex2D(bezelv_sampler, bezel_uv) : tex2D(bezelv_off_sampler, bezel_uv);
	}
#endif
	// True Game UV
	float2 true_game_uv = game_uv;
	float3 game_col = 0.0f;
	float3 background = bg_col;
#ifdef PIN_SHADER
	if ((uv.x > GameScreen_size.x / FullScreen_size.x) || (uv.y > GameScreen_size.y / FullScreen_size.y))
	{
#ifdef DMD_BGND
		if (BackImage_resolution.x > 0 && BackImage_resolution.y > 0)
		{
			float4 imageBackground = tex2D(background_sampler, (uv * FullScreen_size - float2(BackImage_position.x, BackImage_position.y)) / float2(BackImage_resolution.x, BackImage_resolution.y));
			background = lerp(background, imageBackground.rgb, imageBackground.a);
		}
#endif
		game_col = background * pow(2.0f, BackgroundBrightness);
	}
	else
	{
		bool IN_GAME = !OUT_DISPLAY(game_uv);
#else
		bool IN_GAME = !OUT_STARTS(game_uv, PIXEL_TESTS, h_start, v_start);
		if (PIXEL_TESTS || CROP_OFF)
			true_game_uv = DimUV(true_game_uv, h_start, v_start);
#endif
		// GAME DISPLAY
		float cval = 0.0f;
		if (IN_GAME)
		{
#ifdef CRV_SHADER
			if ((PIXEL_TESTS || USE_FRAME_OFF) && USE_FRAME)
				true_game_uv = FrameFix(true_game_uv);
			if ((PIXEL_TESTS || CURVATURE_OFF) && CURVATURE)
				true_game_uv = curv(true_game_uv);
#endif
			if (ROTATED)
				true_game_uv = float2(true_game_uv.y, true_game_uv.x);
			if (!OUT_DISPLAY(true_game_uv))
			{
				game_col = tex2D(GameCopySampler, true_game_uv).rgb;
#ifdef CRT_SHADER
				if ((PIXEL_TESTS || CRT_EFFECT_OFF) && CRT_EFFECT)
				{
					if (BLOOM)
					{
						float3 bloom = tex2D(BloomBlurSampler2, true_game_uv).rgb * BloomBlurContrast;
#ifndef PERF_MODE
						bloom *= 2.0f;
#endif
						game_col = lerp(game_col, pow(bloom, BloomBlurContrast), BloomStrength);
					}
				}
				else
#endif
				// GAME BRIGHTNESS
				game_col *= pow(2.0f, GameBrightness);
#ifdef CRV_SHADER
				if ((PIXEL_TESTS || CURVATURE_OFF) && CURVATURE)
				{
					if (curv_boost > 0.0f)
						game_col *= 1.0f - min((pow((0.5f - true_game_uv.x) / 0.5f, 2) + pow((0.5f - true_game_uv.y) / 0.5f, 2)) * curv_boost / (d + R), 1.0f);
					game_col = max(game_col, 0.01f);
					cval = pow(corner(true_game_uv), 0.5f);
					game_col *= cval;
				}
				else
#endif
				cval = 1.0f;
			}
		}
		else
		{
#if defined CRT_SHADER || defined FRAME_RFLX
			// BLUR BACKGROUND
			if (BLUR_BACKGROUND)
			{
				float2 blur_uv = uv;
				if (ROTATED_180)
					blur_uv = float2(1.0f - blur_uv.x, 1.0f - blur_uv.y);
				if (ROTATED)
				{
					blur_uv = (NO_ROTATE == 3) ? float2(blur_uv.y, 1.0f - blur_uv.x) : float2(1.0f - blur_uv.y, blur_uv.x);
					blur_uv = float2(blur_uv.y, blur_uv.x);
				}
				float3 blur = max(tex2D(BloomBlurSampler2, blur_uv).rgb, 0.01f) * BloomBlurContrast;
#ifdef PERF_MODE
				blur /= 2.0f;
#endif
				background = lerp(background, pow(blur, BloomBlurContrast), 0.25f) * pow(2.0f, BackgroundBrightness);
			}
#endif
#ifndef PIN_SHADER
			// BACKGROUNDS && EXTERN
			if (BEZEL_BACK && USE_BEZEL)
				background = lerp(background, bezel.rgb, bezel.a);
			if (PIXEL_TESTS || CROP_OFF)
			{
				float2 ext_uv = (game_uv + InGame_offset - (0.5f, 0.5f)) * InGame_scale / Extern_scale + (0.5f, 0.5f) - Extern_offset;
				if (EXT_DISPLAY && !OUT_DISPLAY(game_uv) && !OUT_DISPLAY(ext_uv))
					background = tex2D(BackBufferSampler, ext_uv).rgb;
#ifdef BGND_TEX
				float4 imageBackground = tex2D(background_sampler, ext_uv);
				background = lerp(background, imageBackground.rgb, imageBackground.a);
#endif
			}
#endif
			game_col = background * pow(2.0f, BackgroundBrightness);
		}
		
#ifdef CRV_SHADER
		// FRAME
		if ((PIXEL_TESTS || USE_FRAME_OFF) && USE_FRAME)
		{
			float2 frame_uv = game_uv;
#ifndef PIN_SHADER
			if (PIXEL_TESTS || CROP_OFF)
				frame_uv = DimUV(frame_uv, h_start, v_start);
#endif
#ifdef FRAME_RFLX
			float3 reflection = ReflectionUV(true_game_uv);
			reflection = tex2D(BloomBlurSampler2, reflection.xy).rgb * reflection.z * BloomBlurContrast;
#ifndef PERF_MODE
			reflection *= 2.0f;
#endif
#endif
			if (!OUT_DISPLAY(frame_uv))
			{
				float4 frame = 0.0f;
				if (OUT_DISPLAY(true_game_uv))
				{
					game_col = 0.0f;
					frame = tex2D(frame_sampler, frame_uv);
				}
				else if ((PIXEL_TESTS || CURVATURE_OFF) && CURVATURE)
					frame = tex2D(frame_sampler, frame_uv);
				if (FrameColor.r + FrameColor.g + FrameColor.b > 0.1f)
					frame.rgb = (0.299f * frame.r + 0.587f * frame.g + 0.114f * frame.b) * FrameColor;
				frame.rgb *= pow(3.0f, FrameBrightness);
#ifdef FRAME_RFLX
				frame.rgb = lerp(frame.rgb, pow(reflection, BloomBlurContrast), ReflectionIntensity);
#endif
				game_col = lerp(game_col, frame.rgb, (1.0f-cval) * frame.a);
			}
		}
#endif
#ifndef PIN_SHADER
		// FRONT BEZEL
		if (USE_BEZEL && !BEZEL_BACK)
			game_col = lerp(game_col, bezel.rgb, bezel.a);
#else
	}
	// BACKGLASS
	float2 BackGlassScreen_size = BackGlassScreen_resolution;
	float2 BackGlassScreen_pos = BackGlassScreen_position;
	bool BG_GRILL = false;
	float4 backglass = 0.0f;
	if (BG_DISPLAY)
	{
		if ((BackGlassScreen_size.x / BackGlassScreen_size.y < 1.6f) && !NO_GRILL)
			BG_GRILL = true;
		backglass = tex2D(backglass_sampler, BackGlassUV(uv, BackGlassScreen_size, BackGlassScreen_pos, BG_GRILL));
		float3 backglass_screen = 0.0f;
		if (BG_CATCH && PIXEL_TESTS)
			backglass_screen = tex2D(BackBufferSampler, BackGlassScreenUV(uv, PIXEL_TESTS, BackGlassScreen_size, BackGlassScreen_pos, BG_GRILL)).rgb;
		else
			backglass_screen = tex2D(backglass_off_sampler, BackGlassScreenUV(uv, PIXEL_TESTS, BackGlassScreen_size, BackGlassScreen_pos, BG_GRILL)).rgb;
		if (!OUT_SCREEN(uv, BackGlassScreen_size, BackGlassScreen_pos, BG_GRILL))
		{
			backglass_screen = lerp(backglass_screen, backglass.rgb, backglass.a);
			backglass = float4(backglass_screen, 1.0);
			if (PIXEL_TESTS)
				backglass.rgb *= pow(2.0f, BackGlassBrightness);
			game_col = lerp(game_col, backglass.rgb, backglass.a);
		}
		else if (BG_GRILL)
			game_col = lerp(game_col, backglass.rgb, backglass.a);
	}
	// DMD
	if (DMD_DISPLAY)
	{
		float2 DMDScreen_size = DMDScreen_resolution;
		float2 DMDScreen_pos = DMDScreen_position;
		bool DMD_ROTATE = false;
		bool DMD_ROTATE180 = false;
		if (DMDScreen_pos.x < GameScreen_size.x)
		{
			if (ROTATED_180)
				DMD_ROTATE180 = true;
			if (ROTATED)
			{
				DMD_ROTATE = true;
				DMDScreen_size = float2(DMDScreen_resolution.y, DMDScreen_resolution.x);
			}
		}
		if (!OUT_SCREEN(uv, DMDScreen_size, DMDScreen_pos, false))
		{
			float2 dmd_uv = DMDScreenUV(uv, PIXEL_TESTS, DMD_ROTATE, DMD_ROTATE180, DMDScreen_size, DMDScreen_pos);
			if (PIXEL_TESTS && DMD_CATCH)
			{
				game_col = tex2D(BackBufferSampler, dmd_uv).rgb;
				if (DMDFilter > 0.0f)
				{
					if (game_col.r < DMDFilter)
						game_col.r = 0.0f;
					if (game_col.g < DMDFilter)
						game_col.g = 0.0f;
					if (game_col.b < DMDFilter)
						game_col.b = 0.0f;
				}
				if (DMDColor.r + DMDColor.g + DMDColor.b > 0.5f)
					game_col = (0.299f * game_col.r + 0.587f * game_col.g + 0.114f * game_col.b) * DMDColor;
				game_col *= pow(3.0f, DMDBrightness);
			}
			else
			{
				float4 dmd_off = tex2D(dmd_off_sampler, dmd_uv);
				if (DMDColor.r + DMDColor.g + DMDColor.b > 0.1f)
					dmd_off.rgb = (0.299f * dmd_off.r + 0.587f * dmd_off.g + 0.114f * dmd_off.b) * DMDColor;
				game_col = lerp(game_col, dmd_off.rgb, dmd_off.a);
			}
			// Display the backglass grill over the DMD
			if (BG_GRILL && (uv.y < (BackGlassScreen_pos.y + BackGlassScreen_size.y) / FullScreen_size.y) && (uv.y > (BackGlassScreen_pos.y + BackGlassScreen_size.y * BackGlass_ratio / Standard_ratio) / FullScreen_size.y))
				game_col = lerp(game_col, backglass.rgb, backglass.a);
		}
	}
#endif
	return float4(game_col, 1.0);
}



#ifndef PIN_SHADER
technique ArcCabView
#else
technique PinCabView
#endif
{
	pass CRTGeomMod
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_CRTGeomMod;
		RenderTarget0 = BackBufferTex;
		RenderTarget1 = GameCopyTex;
#if defined CRT_SHADER || defined FRAME_RFLX
		RenderTarget2 = BloomBlurTex;
#endif
	}
#if defined CRT_SHADER || defined FRAME_RFLX
	pass BloomBlurH1
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_BloomBlurH1;
		RenderTarget = BloomBlurTex1;
	}
	pass BloomBlurV1
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_BloomBlurV1;
		RenderTarget = BloomBlurTex2;
	}
#ifndef PERF_MODE
	pass BloomBlurH2
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_BloomBlurH2;
		RenderTarget = BloomBlurTex1;
	}
	pass BloomBlurV2
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_BloomBlurV2;
		RenderTarget = BloomBlurTex2;
	}
#endif
#endif
	pass CabView
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_CabView;
	}
}
