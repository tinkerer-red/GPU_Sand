//////////////////////////////////////////////////////////////////////////
//   Shader To Human (S2H) - HLSL/GLSL library for debugging shaders    //
//  Copyright (c) 2024-2025 Electronic Arts Inc.  All rights reserved.  //
//  GLSL 1.20 / GameMaker port is made by Nikita Musatov @KeeVeeGames.  //
//////////////////////////////////////////////////////////////////////////

// Port specific

const int _S2H_PORT_VERSION = 1;

#define uint int
#define uvec2 ivec2

// imod(x, y) = x % y = x & (y - 1)
int imod(int x, int y)
{
    return x - y * (x / y);
}

// bit(n, b) = n & (1 << p), where b = 2^p
int bit(int n, int b)
{
    return imod(n / b, 2);
}

// shift_right(x, n) = x >> n = x / 2^n
int shift_right(int x, int n)
{
    return int(float(x) / pow(2.0, float(n)));
}

vec2 round(vec2 v) {
    return floor(v + 0.5);
}

// use texture font instead, as int-uint differences are breaking the font rendering
uniform sampler2D s2h_fontTexture;
bool s2h_fontLookup(int ascii, ivec2 pxPos)
{
    if (pxPos.x < 0 || pxPos.x >= 8 ||
        pxPos.y < 0 || pxPos.y >= 8)
        return false;

    if (ascii <= 32 || ascii > 127)
        return false;

    int chr = ascii - 32;

    ivec2 chrPos = ivec2(imod(chr, 16), chr / 16);
    ivec2 texel  = chrPos * 8 + pxPos;

    vec2 uv = (vec2(texel) + 0.5) / vec2(128.0, 48.0);

    return texture2D(s2h_fontTexture, uv).r > 0.5;
}

#pragma shady: skip_compilation

//

const int _S2H_VERSION = 11;

// pixel shader or compute shader looping through all pixels

// Example:
// #include "s2h.h"
// {
//   ContextGather ui;
//   // pxPos is the integer pixel position + 0.5 (pixel centered)
//   s2h_init(ui, pxPos + 0.5);
//   // print AB 
//   s2h_printTxt(ui, _A, _B);
//   // Note: ui.dstColor is premultiplied
//   linearColor = linearBackground * (1.0 - ui.dstColor.a) + ui.dstColor;
//   // for correct AntiAliasing 
//   srgbColor = float4(s2h_accurateLinearToSRGB(linearColor.rgb), 1);
// }

// Any potentially API breaking update we should increase the version by 1 allowing other code to adapt to S2H.


// documentation:
struct ContextGather
{
	// in pixels, no fractional part (half pixel offset)
	vec2 pxCursor;
	// 1/2/3/4
	float scale;
	// .xy:-100,-100 if not yet set, .xy:absolutePos, z:leftMouse 0/1, w:rightMouse 0/1, no fractional part (half pixel offset)
	vec4 mouseInput;

	// window left top, no fractional part (half pixel offset), set by s2h_setPos(), used by s2h_printLF()
	float pxLeftX;
	// in pixels, no fractional part (half pixel offset), set by s2h_init()
	vec2 pxPos;
	// premultiplied RGBA, alpha 1 is assumed to be opaque, don't init with a color or s2h_button() will not work
	vec4 dstColor;

	//

	// RGBA, alpha 1 is assumed to be opaque, s2h_progress()
	vec4 textColor;
	// for s2h_frame()
	vec4 frameFillColor;
	// for s2h_frame()
	vec4 frameBorderColor;
	// for s2h_button(), s2h_checkbox(), s2h_radiobutton, s2h_progress(), s2h_sliderFloat()
	vec4 buttonColor;
	//
	float lineWidth;

	// private ----------------------

	// for interactive UI, read int4 state from former frame
	ivec4 s2h_State;
};

struct s2h_Triangle
{
    vec2 A;
    vec2 B;
    vec2 C;
};

// first call this
void s2h_init(out ContextGather ui);
// set text cursor position, next printLF() will reset to this x position
void s2h_setCursor(inout ContextGather ui, vec2 inpxLeftTop);
// @param s2h_State write int4 state for next frame, don't call if you don't want UI State
void s2h_deinit(inout ContextGather ui, out ivec4 s2h_State);
// @param scale 1:pixel perfect, 2:2x, 3:3x, ..
void s2h_setScale(inout ContextGather ui, float scale);
// e.g. ui.s2h_printTxt('I', ' ', 'a', 'm');
// @param a ascii character or 0
void s2h_printTxt(inout ContextGather ui, uint a, uint b, uint c, uint d, uint e, uint f);
// useful for table headers and to center text
void s2h_printSpace(inout ContextGather ui, float numberOfChars);
// jump to next line (line feed)
void s2h_printLF(inout ContextGather ui);
// @param value e.g. 123, 0
void s2h_printInt(inout ContextGather ui, int value);
// print hexadecimal e.g. "0000aa34"
// @param value 32bit e.g. 0x123, 0xff00
void s2h_printHex(inout ContextGather ui, uint value);
// @param output e.g. g_output from RWTexture2D<float3> g_output : register(u0, space0);
// @param pos in pixels from left top, left top of the printout
// @param value
void s2h_printFloat(inout ContextGather ui, float value);
// don't use directly
void s2h_printCharacter(inout ContextGather ui, uint ascii);
// circle in a s2h_fontSize() x s2h_fontSize() character
void s2h_printDisc(inout ContextGather ui, vec4 color);
// block in a s2h_fontSize() x s2h_fontSize() character
void s2h_printBox(inout ContextGather ui, vec4 color);
// useful for table headers
// similar to s2h_button but not interactive, call after using s2h_printTxt()
void s2h_frame(inout ContextGather ui, uint widthInCharacters);

// draw anti aliased filled disc 
void s2h_drawDisc(inout ContextGather ui, vec2 pxCenter, float pxRadius, vec4 color);
// draw anti aliased circle
void s2h_drawCircle(inout ContextGather ui, vec2 pxCenter, float pxRadius, vec4 color, float pxThickness);
// draw anti aliased circle
void s2h_drawHalfSpace(inout ContextGather ui, vec3 halfSpace, vec2 visualizePoint, vec4 color, float pxCircleRadius, float pxLineRadius);
// draw not anti aliased rectangle (fast and simple), 
// @param pxLeftTop included
// @param pxBottomRight excluded
void s2h_drawRectangle(inout ContextGather ui, vec2 pxLeftTop, vec2 pxBottomRight, vec4 color);
// border half inwards and half outwards, pxThickness >0 results in rounded corners
void s2h_drawRectangleAA(inout ContextGather ui, vec2 pxA, vec2 pxB, vec4 borderColor, vec4 innerColor, float pxThickness);
// anti aliased, px position should be pixel centered (+0.5)
void s2h_drawCrosshair(inout ContextGather ui, vec2 pxCenter, float pxRadius, vec4 color, float pxThickness);
// hard edges, anti aliased, px position should be pixel centered (+0.5)
void s2h_drawLine(inout ContextGather ui, vec2 pxBegin, vec2 pxEnd, vec4 color, float pxThickness);
// anti aliased px position should be pixel centered (+0.5)
void s2h_drawArrow(inout ContextGather ui, vec2 pxStart, vec2 pxEnd, vec4 color, float arrowHeadLength, float arrowHeadWidth);
// anti aliased px position should be pixel centered (+0.5)
void s2h_drawTriangle(inout ContextGather ui, s2h_Triangle tri, vec4 color);
// 256x32 horizontal color ramp in sRGB space, 128 should be in the middle, RGB color gradient on outside
void s2h_drawSRGBRamp(inout ContextGather ui, vec2 pxPos);


// ------------------------------------------

// for state-full UI:

// call after using s2h_printTxt()
// e.g. if(s2h_button(ui, 5, float4(1,0,1,1))) do();
bool s2h_button(inout ContextGather ui, uint widthInCharacters);
// same as above but with the explicit fragment position at which the interaction will be registered
// use when saving the UI state on the texture
bool s2h_button(inout ContextGather ui, uint widthInCharacters, vec2 statePos);
// circle in a s2h_fontSize() x s2h_fontSize() character with mouse over
// e.g. if(s2h_radioButton(ui, float4(1,0,0,1), UIState[0].SplatMode == 0) && leftMouse) UIState[0].SplatMode = 0;
// @param checked fill inside using textColor
// @return mouseOver (can be used as button or radio button)
bool s2h_radioButton(inout ContextGather ui, bool checked);
// same as above but with the explicit fragment position at which the interaction will be registered
// use when saving the UI state on the texture
bool s2h_radioButton(inout ContextGather ui, bool checked, vec2 statePos);
// e.g. if(s2h_checkBox(ui, UIState[0].UICheckboxState == 0) && leftMouseClicked) UIState[0].UICheckboxState = !UIState[0].UICheckboxState;
// @param checked fill inside using textColor
bool s2h_checkBox(inout ContextGather ui, bool checked);
// same as above but with the explicit fragment position at which the interaction will be registered
// use when saving the UI state on the texture
bool s2h_checkBox(inout ContextGather ui, bool checked, vec2 statePos);
// @param fraction 0..1
void s2h_progress(inout ContextGather ui, uint widthInCharacters, float fraction);
//
void s2h_sliderFloat(inout ContextGather ui, uint widthInCharacters, inout float value, float minValue, float maxValue);
// LDR color (0..1 range)
void s2h_sliderRGB(inout ContextGather ui, uint widthInCharacters, inout vec3 value);
// LDR color (0..1 range) with alpha
void s2h_sliderRGBA(inout ContextGather ui, uint widthInCharacters, inout vec4 value);

// helper functions ----------------------------------------------------------------------

// slow but accurate
vec3 s2h_accurateLinearToSRGB(vec3 linearCol);
// slow but accurate
vec3 s2h_accurateSRGBToLinear(vec3 sRGBCol);
// extremely different colors, 0 is black
// intentionally not randomized so small indices result in human recognizable colors
// repeats every 512 elements
vec3 s2h_indexToColor(uint index);
// @param 0..1
// @return 0:red, 0.5:green, 1:blue, outside is clamped
vec3 s2h_colorRampRGB(float value);


// implementation ----------------------------------------------------------------------

const float S2H_FLT_MAX = 3.40282347e+38;

// You can define this to provide your own font (different size, visual or better lookup performance by using a texture)

// uniform int g_miniFont[192];

// const uint g_miniFont[] = uint[](
//     0x00306c6c, 0x30003860, 0x18600000, 0x00000006, 
//     0x00786c6c, 0x7cc66c60, 0x30306630, 0x0000000c, 
//     0x00786cfe, 0xc0cc38c0, 0x60183c30, 0x00000018, 
//     0x0030006c, 0x78187600, 0x6018fffc, 0x00fc0030, 
//     0x003000fe, 0x0c30dc00, 0x60183c30, 0x00000060, 
//     0x0000006c, 0xf866cc00, 0x30306630, 0x300030c0, 
//     0x0030006c, 0x30c67600, 0x18600000, 0x30003080, 
//     0x00000000, 0x00000000, 0x00000000, 0x60000000, 
//     0x7c307878, 0x1cfc38fc, 0x78780000, 0x18006078, 
//     0xc670cccc, 0x3cc060cc, 0xcccc3030, 0x300030cc, 
//     0xce300c0c, 0x6cf8c00c, 0xcccc3030, 0x60fc180c, 
//     0xde303838, 0xcc0cf818, 0x787c0000, 0xc0000c18, 
//     0xf630600c, 0xfe0ccc30, 0xcc0c0000, 0x60001830, 
//     0xe630cccc, 0x0ccccc30, 0xcc183030, 0x30fc3000, 
//     0x7cfcfc78, 0x1e787830, 0x78703030, 0x18006030, 
//     0x00000000, 0x00000000, 0x00000060, 0x00000000, 
//     0x7c30fc3c, 0xf8fefe3c, 0xcc781ee6, 0xf0c6c638, 
//     0xc6786666, 0x6c626266, 0xcc300c66, 0x60eee66c, 
//     0xdecc66c0, 0x666868c0, 0xcc300c6c, 0x60fef6c6, 
//     0xdecc7cc0, 0x667878c0, 0xfc300c78, 0x60fedec6,
//     0xdefc66c0, 0x666868ce, 0xcc30cc6c, 0x62d6cec6,
//     0xc0cc6666, 0x6c626066, 0xcc30cc66, 0x66c6c66c,
//     0x78ccfc3c, 0xf8fef03e, 0xcc7878e6, 0xfec6c638,
//     0x00000000, 0x00000000, 0x00000000, 0x00000000,
//     0xfc78fc78, 0xfcccccc6, 0xc6ccfe78, 0xc0781000,
//     0x66cc66cc, 0xb4ccccc6, 0xc6ccc660, 0x60183800,
//     0x66cc66e0, 0x30ccccc6, 0x6ccc8c60, 0x30186c00,
//     0x7ccc7c70, 0x30ccccd6, 0x38781860, 0x1818c600,
//     0x60dc6c1c, 0x30ccccfe, 0x38303260, 0x0c180000,
//     0x607866cc, 0x30cc78ee, 0x6c306660, 0x06180000,
//     0xf01ce678, 0x78fc30c6, 0xc678fe78, 0x02780000,
//     0x00000000, 0x00000000, 0x00000000, 0x000000ff,
//     0x3000e000, 0x1c003800, 0xe0300ce0, 0x70000000, 
//     0x30006000, 0x0c006c00, 0x60000060, 0x30000000, 
//     0x18786078, 0x0c786076, 0x6c700c66, 0x30ccf878, 
//     0x000c7ccc, 0x7cccf0cc, 0x76300c6c, 0x30fecccc, 
//     0x007c66c0, 0xccfc60cc, 0x66300c78, 0x30fecccc, 
//     0x00cc66cc, 0xccc0607c, 0x6630cc6c, 0x30d6cccc, 
//     0x0076dc78, 0x7678f00c, 0xe678cce6, 0x78c6cc78, 
//     0x00000000, 0x000000f8, 0x00007800, 0x00000000, 
//     0x00000000, 0x10000000, 0x0000001c, 0x18e076ff, 
//     0x00000000, 0x30000000, 0x00000030, 0x1830dcff, 
//     0xdc76dc7c, 0x7cccccc6, 0xc6ccfc30, 0x183000ff,
//     0x66cc76c0, 0x30ccccd6, 0x6ccc98e0, 0x001c00ff, 
//     0x66cc6678, 0x30ccccfe, 0x38cc3030, 0x183000ff, 
//     0x7c7c600c, 0x34cc78fe, 0x6c7c6430, 0x183000ff, 
//     0x600cf0f8, 0x1876306c, 0xc60cfc1c, 0x18e000ff, 
//     0xf01e0000, 0x00000000, 0x00f80000, 0x000000ff
// );

// todo: consider define or static cost int or float
// 8x8 font 
float s2h_fontSize() { return 8.0; }

// don't use directly
// can be used for scatter and gather
// @param ascii 32..127 are valid characters
// @param pxPos int2(0..s2h_fontSize()-1, 0..s2h_fontSize-1)
// @return true if there should be a pixel, false if not or outside the valid range
// bool s2h_fontLookup(uint ascii, ivec2 pxPos)
// {
// 	if(uint(pxPos.x) >= 8 || uint(pxPos.y) >= 8)
//         return false;
//
//     if (ascii <= 32 || ascii > 127)
//         return false;
//
//     // 0..16*6-1
//     uint chr = ascii - 32;
//     // uint2(0..127, 0..47) 
//     uvec2 chrPos = uvec2(imod(chr, 16), chr / 16);
//     uvec2 pixel = uvec2(chrPos.x * 8 + uint(pxPos.x), chrPos.y * 8 + uint(pxPos.y));
//     uint dwordId = pixel.x / 32 + (pixel.y * 4);
//     // 0..31
//     uint bitId	= imod(uint(pixel.x), 32);
//
//     // 0..ff
//     uint dwordValue = g_miniFont[dwordId];
//
//     return imod(shift_right(dwordValue, (31 - bitId)), 2) != 0;
// }

void s2h_printCharacter(inout ContextGather ui, uint ascii)
{
	ivec2 pxLocal = ivec2(floor((ui.pxPos - ui.pxCursor) / ui.scale));

	if(s2h_fontLookup(ascii, pxLocal))
		ui.dstColor = mix(ui.dstColor, vec4(ui.textColor.rgb, 1), ui.textColor.a);

	ui.pxCursor.x += s2h_fontSize() * ui.scale;
}

const uint _A = 65;
const uint _B = 66;
const uint _C = 67;
const uint _D = 68;
const uint _E = 69;
const uint _F = 70;
const uint _G = 71;
const uint _H = 72;
const uint _I = 73;
const uint _J = 74;
const uint _K = 75;
const uint _L = 76;
const uint _M = 77;
const uint _N = 78;
const uint _O = 79;
const uint _P = 80;
const uint _Q = 81;
const uint _R = 82;
const uint _S = 83;
const uint _T = 84;
const uint _U = 85;
const uint _V = 86;
const uint _W = 87;
const uint _X = 88;
const uint _Y = 89;
const uint _Z = 90;

const uint _a = (_A + 32);
const uint _b = (_B + 32);
const uint _c = (_C + 32);
const uint _d = (_D + 32);
const uint _e = (_E + 32);
const uint _f = (_F + 32);
const uint _g = (_G + 32);
const uint _h = (_H + 32);
const uint _i = (_I + 32);
const uint _j = (_J + 32);
const uint _k = (_K + 32);
const uint _l = (_L + 32);
const uint _m = (_M + 32);
const uint _n = (_N + 32);
const uint _o = (_O + 32);
const uint _p = (_P + 32);
const uint _q = (_Q + 32);
const uint _r = (_R + 32);
const uint _s = (_S + 32);
const uint _t = (_T + 32);
const uint _u = (_U + 32);
const uint _v = (_V + 32);
const uint _w = (_W + 32);
const uint _x = (_X + 32);
const uint _y = (_Y + 32);
const uint _z = (_Z + 32);

const uint _SINGLEQUOTE = 39;   // '
const uint _UNDERSCORE = 95;    // _
const uint _MINUS = 45;         // -
const uint _PLUS = 43;          // +
const uint _ASTERISK = 42;      // *
const uint _PERIOD = 46;        // .
const uint _COLON = 58;         // :
const uint _COMMA = 44;         // ,
const uint _SPACE = 32;         //  
const uint _LESS = 60;          // <
const uint _EQUAL = 61;         // =
const uint _GREATER = 62;       // >
const uint _SLASH = 47;         // /
const uint _BACKSLASH = 92;     //
const uint _0 = 48;
const uint _1 = 49;
const uint _2 = 50;
const uint _3 = 51;
const uint _4 = 52;
const uint _5 = 53;
const uint _6 = 54;
const uint _7 = 55;
const uint _8 = 56;
const uint _9 = 57;

void s2h_init(out ContextGather ui, vec2 inPxPos)
{
	// white, opaque 
	ui.textColor = vec4(1, 1, 1, 1); 
	ui.pxLeftX = 0.0; 
	ui.pxCursor = vec2(0, 0); 
	ui.scale = 1.0;
	ui.mouseInput = vec4(-100, -100, 0, 0); 

	ui.pxPos = inPxPos;
	// see through
	ui.dstColor = vec4(0, 0, 0, 0);
	ui.s2h_State = ivec4(0, 0, 0, 0);

	ui.frameFillColor = vec4(0.9, 0.9, 0.9, 1);
	ui.frameBorderColor = vec4(0.7, 0.7, 0.7, 1);
	ui.buttonColor = vec4(0.5, 0.5, 0.5, 1);
	ui.lineWidth = 2.0;
}

void s2h_setCursor(inout ContextGather ui, vec2 inpxLeftTop)
{
	ui.pxCursor = inpxLeftTop; 
	ui.pxLeftX = inpxLeftTop.x;
}

void s2h_deinit(inout ContextGather ui, out ivec4 s2h_State)
{
	// if mouse input was set and mouse is released, we forget which button was active
	if(ui.mouseInput.x != -100.0 && ui.mouseInput.z == 0.0)
		ui.s2h_State = ivec4(0,0,0,0);

	s2h_State = ui.s2h_State;
}

void s2h_setScale(inout ContextGather ui, float scale)
{
	ui.scale = scale;
}

void s2h_printTxt(inout ContextGather ui, uint a)
{
	s2h_printCharacter(ui, a);
}

// glsl has no default arguments to we implement multiple functions instead making porting easier
void s2h_printTxt(inout ContextGather ui, uint a, uint b)
{ s2h_printTxt(ui, a); s2h_printCharacter(ui, b); }
void s2h_printTxt(inout ContextGather ui, uint a, uint b, uint c)
{ s2h_printTxt(ui, a, b); s2h_printCharacter(ui, c); }
void s2h_printTxt(inout ContextGather ui, uint a, uint b, uint c, uint d)
{ s2h_printTxt(ui, a, b, c); s2h_printCharacter(ui, d); }
void s2h_printTxt(inout ContextGather ui, uint a, uint b, uint c, uint d, uint e)
{ s2h_printTxt(ui, a, b, c, d); s2h_printCharacter(ui, e); }
void s2h_printTxt(inout ContextGather ui, uint a, uint b, uint c, uint d, uint e, uint f)
{ s2h_printTxt(ui, a, b, c, d, e); s2h_printCharacter(ui, f); }

void s2h_printSpace(inout ContextGather ui, float numberOfChars)
{
	ui.pxCursor.x += s2h_fontSize() * numberOfChars * ui.scale;
}

void s2h_printLF(inout ContextGather ui)
{
	ui.pxCursor.x = ui.pxLeftX;
	ui.pxCursor.y += s2h_fontSize() * ui.scale;
}

void s2h_printInt(inout ContextGather ui, int value)
{
	// leading '-'
	if (value < 0)
	{
		s2h_printCharacter(ui, _MINUS);
		value = -value;
	}
	if (value == 0)
	{
		s2h_printCharacter(ui, _0);
		return;
	}
	// move to right depending on number length
	{
		uint tmp = uint(value);
		while (tmp != 0)
		{
			ui.pxCursor.x += s2h_fontSize() * ui.scale;
			tmp = int(float(tmp) / 10.0);
		}
	}
	// digits
	{
		float backup = ui.pxCursor.x;
		uint tmp = uint(value);
		while (tmp != 0)
		{
			// 0..9
			uint digit = imod(tmp, 10);
			tmp = int(float(tmp) / 10.0);
			// go backwards
			ui.pxCursor.x -= s2h_fontSize() * ui.scale;
			s2h_printCharacter(ui, _0 + digit);
			// counter +=s2h_fontSize() from printCharacter ()
			ui.pxCursor.x -= s2h_fontSize() * ui.scale;
		}
		ui.pxCursor.x = backup;
	}
}

void s2h_printHex(inout ContextGather ui, uint value)
{
	// 4 nibbles
	for(int i = 3; i >= 0; --i)
	{
		// 0..15
		uint nibble = imod(shift_right(value, (uint(i) * 4)), 16);
		uint start = (nibble < 10) ? _0 : (_A - 10);
		s2h_printCharacter(ui, start + nibble);
	}
}

void s2h_printFloat(inout ContextGather ui, float value)
{
	s2h_printInt(ui, int(value));
	float fractional = fract(abs(value));

	s2h_printCharacter(ui, _PERIOD);

	const uint digitCount = 3;

	// todo: unit tests, this is likely wrong at lower precision

	// fractional digits
	for(uint i = 0; i < digitCount; ++i)
	{
		fractional *= 10.0;
		// 0..9
		uint digit = uint(fractional);
		fractional = fract(fractional);
		s2h_printCharacter(ui, _0 + digit);
	}
}

void s2h_printBox(inout ContextGather ui, vec4 color)
{
	vec2 pxLocal = vec2(ui.pxPos - ui.pxCursor) / float(ui.scale) - vec2(4, 4);

	float mask = clamp(4.0 - max(abs(pxLocal.x), abs(pxLocal.y)),0.0,1.0);

//	dstColor = lerp(dstColor, float4(color.rgb, 1), color.a * mask);
	if(mask > 0.0)
		ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a);

	ui.pxCursor.x += s2h_fontSize() * ui.scale;
}

void s2h_drawDisc(inout ContextGather ui, vec2 pxCenter, float pxRadius, vec4 color)
{
	vec2 pxLocal = ui.pxPos - pxCenter;

	float len = length(pxLocal);
	float mask = clamp(pxRadius - len,0.0,1.0);

	ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a * mask);
}

void s2h_drawCircle(inout ContextGather ui, vec2 pxCenter, float pxRadius, vec4 color, float pxThickness)
{
	float r = pxThickness * 0.5;
	vec2 pxLocal = ui.pxPos - pxCenter;

	float len = length(pxLocal);
	float mask = clamp(pxRadius - len + r,0.0,1.0) * (1.0 - clamp(pxRadius - len - r,0.0,1.0));

	ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a * mask);
}

void s2h_drawHalfSpace(inout ContextGather ui, vec3 halfSpace, vec2 visualizePoint, vec4 color, float pxCircleRadius, float lineRadius)
{
    // normalize
    halfSpace /= length(halfSpace.xy);

    //
    vec2 onPoint = visualizePoint - halfSpace.xy * dot(halfSpace, vec3(visualizePoint, 1));

    float planeDist = dot(halfSpace, vec3(ui.pxPos, 1));
    float diskDist = length(onPoint - ui.pxPos);

	// 0..1
    float sideMask = clamp(planeDist,0.0,1.0);
	// 0..1
    float lineMask = clamp(ui.lineWidth - abs(planeDist - ui.lineWidth),0.0,1.0) * clamp(lineRadius - diskDist,0.0,1.0);
	// 0..1
    float semiDiskMask = clamp(pxCircleRadius - diskDist,0.0,1.0) * sideMask;
    float mask = max(semiDiskMask, lineMask);

	ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a * mask);
}

void s2h_drawRectangle(inout ContextGather ui, vec2 pxLeftTop, vec2 pxBottomRight, vec4 color)
{
	if(ui.pxPos.x >= pxLeftTop.x && ui.pxPos.y >= pxLeftTop.y && ui.pxPos.x < pxBottomRight.x && ui.pxPos.y < pxBottomRight.y)
		ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a);
}

void s2h_drawRectangleAA(inout ContextGather ui, vec2 pxA, vec2 pxB, vec4 borderColor, vec4 innerColor, float pxThickness)
{
	float r = pxThickness * 0.5;

	vec2 pxCenter = (pxA + pxB) * 0.5;
	vec2 pxHalfSize = abs(pxB - pxA) * 0.5;
	
	vec2 pxLocalOuter = max(abs(ui.pxPos - pxCenter) - pxHalfSize, vec2(0, 0));
	vec2 pxLocalInner = max(abs(ui.pxPos - pxCenter) - pxHalfSize + r, vec2(0, 0));

	float maskOuter = clamp(1.0 + r - length(pxLocalOuter),0.0,1.0);
	float maskInner = clamp(length(pxLocalInner) - 0.5,0.0,1.0);

	vec4 color = mix(innerColor, vec4(borderColor.rgb, 1), borderColor.a * maskInner);

	ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a * maskOuter);
}

void s2h_drawCrosshair(inout ContextGather ui, vec2 pxCenter, float pxRadius, vec4 color, float pxThickness)
{
	vec2 h = vec2(pxRadius, 0);
	vec2 v = vec2(0, pxRadius);

	s2h_drawLine(ui, pxCenter - h , pxCenter + h, color, pxThickness);
	s2h_drawLine(ui, pxCenter - v, pxCenter + v, color, pxThickness);
}

void s2h_drawLine(inout ContextGather ui, vec2 pxBegin, vec2 pxEnd, vec4 color, float pxThickness)
{
	pxThickness++;
	float r = pxThickness * 0.5;
	vec2 delta = pxEnd - pxBegin;
	float len = length(delta);
	if(len > 0.01)
	{
		vec2 tangent = delta / len;
		vec2 normal = vec2(tangent.y, -tangent.x);
		vec2 local = vec2(ui.pxPos) - pxBegin;
		vec2 uv = vec2(dot(local, tangent), dot(local, normal));
		// 0...1
		float mask = clamp(r - abs(uv.y),0.0,1.0) * clamp(r - uv.x + len,0.0,1.0) * clamp(r + uv.x,0.0,1.0);

		ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a * mask);
	}
}

vec3 s2h_getHalfSpacePlane(vec2 pointA, vec2 pointB)
{
    vec2 ab = normalize(pointA - pointB);
    vec3 abPlane = vec3(-ab.y, ab.x, 0);
    abPlane.z = dot(abPlane.xy, -pointA);

    return abPlane;
}

void s2h_drawTriangle(inout ContextGather ui, s2h_Triangle tri, vec4 color)
{
    vec3 abPlane = s2h_getHalfSpacePlane(tri.A, tri.B);
    float abMask = clamp(dot(abPlane, vec3(ui.pxPos, 1)) - 0.5,0.0,1.0);

    vec3 bcPlane = s2h_getHalfSpacePlane(tri.B, tri.C);
    float bcMask = clamp(dot(bcPlane, vec3(ui.pxPos, 1))- 0.5,0.0,1.0);

    vec3 caPlane = s2h_getHalfSpacePlane(tri.C, tri.A);
    float caMask = clamp(dot(caPlane, vec3(ui.pxPos, 1)) - 0.5,0.0,1.0);
    
    float mask = abMask * bcMask * caMask;
    ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a * mask);
}

void s2h_drawArrow(inout ContextGather ui, vec2 pxStart, vec2 pxEnd, vec4 color,  float arrowHeadLength, float arrowHeadWidth)
{
    vec2 direction = vec2(0,1);
    direction = normalize(pxEnd - pxStart);

    const float Thickness = 10.0;

    vec2 lineStart = pxStart;
    // Subtract the arrow length from lineEnd - arrow fits in pxStart...pxEnd
    vec2 lineEnd = pxEnd - direction * arrowHeadLength;

    vec2 perpendicularDir = normalize(vec2(direction.y, -direction.x)); 

    s2h_drawLine(ui, lineStart, lineEnd, color, Thickness);

    s2h_Triangle triA;
    triA.A = lineEnd - perpendicularDir * arrowHeadWidth;
    triA.B = lineEnd + direction * arrowHeadLength;
    triA.C = lineEnd + perpendicularDir * arrowHeadWidth;
    s2h_drawTriangle(ui, triA, color);
}

void s2h_drawSRGBRamp(inout ContextGather ui, vec2 pxPos)
{
	// snap to pixel center
	pxPos = floor(pxPos) + 0.5;

	vec2 local = ui.pxPos - pxPos;

	float u = local.x / 256.0;

	if(local.y > 16.0)
		u = floor(u * 16.0) / 16.0;

	vec3 col = s2h_accurateSRGBToLinear(vec3(u, u, u));

	s2h_drawRectangle(ui, pxPos - 2.0, pxPos + vec2(256, 32) + 2.0, vec4(s2h_colorRampRGB(u), 1));
	s2h_drawRectangle(ui, pxPos, pxPos + vec2(256, 32), vec4(col, 1));

	ContextGather backup = ui;
	s2h_setScale(ui, 1.0);
	ui.textColor = vec4(1, 1, 1, 1);
	s2h_setCursor(ui, pxPos + vec2(2.0, 22));
	s2h_printTxt(ui, _0);
	s2h_setCursor(ui, pxPos + vec2(128.0 - 1.5 * 8.0, 22));
	s2h_printTxt(ui, _1, _2, _7);
	ui.textColor = vec4(0, 0, 0, 1);
	s2h_setCursor(ui, pxPos + vec2(256.0 - 3.2 * 8.0, 22));
	s2h_printTxt(ui, _2, _5, _5);

	ui.pxCursor = backup.pxCursor;
	ui.scale = backup.scale;
	ui.textColor = backup.textColor;
	ui.pxLeftX = backup.pxLeftX;
}

void s2h_printDisc(inout ContextGather ui, vec4 color) 
{ 
	vec2 pxLocal = vec2(ui.pxPos - ui.pxCursor) / float(ui.scale) - vec2(4, 4); 
 
	float mask = clamp(4.0 - length(pxLocal),0.0,1.0); 
 
//	dstColor = lerp(stColor, float4(color.rgb, 1), color.a * mask); 
	// no AA for now
	if(mask > 0.0) 
		ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a);
 
	ui.pxCursor.x += s2h_fontSize() * ui.scale; 
}

float s2h_computeDistToBox(inout ContextGather ui, vec2 p, vec2 center, vec2 halfSize)
{
	vec2 pxLocal = vec2(p - center);// - float2(3.5, 3.5) * ui.scale;
	vec2 dist2 = max(vec2(0, 0), abs(pxLocal) - halfSize);
	return max(dist2.x, dist2.y);
}

// @param aabb .x:minx, .y:miny, z:maxx, w:maxy
float s2h_computeDistToBox(inout ContextGather ui, vec2 p, vec4 aabb)
{
	vec2 center = (aabb.xy + aabb.zw) * 0.5; 
	vec2 halfSize = (aabb.zw - aabb.xy) * 0.5;
	vec2 pxLocal = vec2(p - center);// - float2(3.5, 3.5) / ui.scale;
	vec2 dist2 = max(vec2(0, 0), abs(pxLocal) - halfSize);
	return max(dist2.x, dist2.y);
}

void s2h_frame(inout ContextGather ui, uint widthInCharacters)
{
	vec4 aabb = vec4(ui.pxCursor - vec2(widthInCharacters, 0) * s2h_fontSize() * ui.scale, ui.pxCursor);

	// shrink
	aabb += vec4(4, 4, -4, 4) * ui.scale;

	float dist = s2h_computeDistToBox(ui, ui.pxPos, aabb) / ui.scale;

	float rimMask = clamp(3.0 - dist,0.0,1.0);
	float outerMask = clamp(4.0 - dist,0.0,1.0);

	vec4 localColor = vec4(0,0,0,0);

	// no AA for now
	if(outerMask > 0.0)
		localColor = ui.frameBorderColor;

	if(rimMask > 0.0)
		localColor = ui.frameFillColor;

	ui.dstColor = mix(ui.dstColor, vec4(localColor.rgb, 1), localColor.a * (1.0 - ui.dstColor.a));
}

bool s2h_button(inout ContextGather ui, uint widthInCharacters, vec2 statePos)
{
	vec4 color = ui.buttonColor;
	const float border = 0.0;

	vec4 aabb = vec4(ui.pxCursor - vec2(widthInCharacters, 0) * s2h_fontSize() * ui.scale, ui.pxCursor);

	// shrink
	aabb += vec4(4, 4, -4, 4) * ui.scale;

	float dist = s2h_computeDistToBox(ui, ui.pxPos, aabb) / ui.scale;
	bool mouseOver = s2h_computeDistToBox(ui, ui.mouseInput.xy, aabb) / ui.scale < 5.0 + border;

	float rimMask = clamp(5.0 - dist + border,0.0,1.0);
	float outerMask = clamp(4.0 - dist + border,0.0,1.0);

	vec4 localColor = vec4(0,0,0,0);

	if(mouseOver && rimMask > 0.0)
		localColor = vec4(1, 1, 1, 1);

	// no AA for now
	if(outerMask > 0.0)
		localColor = color;

	ui.dstColor = mix(ui.dstColor, vec4(localColor.rgb, 1), localColor.a * (1.0 - ui.dstColor.a));

	vec2 delta = round(statePos + 0.5 - ui.pxPos);

	return mouseOver && delta.x == 0.0 && delta.y == 0.0;
}
bool s2h_button(inout ContextGather ui, uint widthInCharacters)
{
    return s2h_button(ui, widthInCharacters, ui.mouseInput.xy);
}

bool s2h_radioButton(inout ContextGather ui, bool checked, vec2 statePos)
{
	vec4 color = ui.buttonColor;

	vec2 pxLocal = vec2(ui.pxPos - ui.pxCursor - 0.5) / float(ui.scale) - vec2(3.5, 3.5);
	float dist = length(pxLocal);

	float rimMask = clamp(5.0 - dist,0.0,1.0);
	float outerMask = clamp(4.0 - dist,0.0,1.0);
	float innerMask = clamp(2.5 - dist,0.0,1.0);

	bool mouseOver = length(vec2(ui.mouseInput.xy - ui.pxCursor) / float(ui.scale) - vec2(3.5, 3.5)) < 4.0;

	if(mouseOver && rimMask > 0.0)
		ui.dstColor = vec4(1, 1, 1 ,1);

	// no AA for now
	if(outerMask > 0.0)
		ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a);
	if(checked && innerMask > 0.0)
		ui.dstColor = mix(ui.dstColor, vec4(ui.textColor.rgb, 1), ui.textColor.a);

	ui.pxCursor.x += s2h_fontSize() * ui.scale;

	vec2 delta = round(statePos + 0.5 - ui.pxPos);

	return mouseOver && delta.x == 0.0 && delta.y == 0.0;
}
bool s2h_radioButton(inout ContextGather ui, bool checked)
{
    return s2h_radioButton(ui, checked, ui.mouseInput.xy);
}

bool s2h_checkBox(inout ContextGather ui, bool checked, vec2 statePos)
{
	vec4 color = ui.buttonColor;

	vec2 pxLocal = vec2(ui.pxPos - ui.pxCursor - 0.5) / float(ui.scale) - vec2(3.5, 3.5);
	float dist = max(abs(pxLocal.x), abs(pxLocal.y));

	float rimMask = clamp(5.0 - dist,0.0,1.0);
	float outerMask = clamp(4.0 - dist,0.0,1.0);
	float innerMask = clamp(2.5 - dist,0.0,1.0);

	bool mouseOver = length(vec2(ui.mouseInput.xy - ui.pxCursor) / float(ui.scale) - vec2(3.5, 3.5)) < 4.0;

	if(mouseOver && rimMask > 0.0)
		ui.dstColor = vec4(1, 1, 1 ,1);

	// no AA for now
	if(outerMask > 0.0)
		ui.dstColor = mix(ui.dstColor, vec4(color.rgb, 1), color.a);
	if(checked && innerMask > 0.0)
		ui.dstColor = mix(ui.dstColor, vec4(ui.textColor.rgb, 1), ui.textColor.a);

	ui.pxCursor.x += s2h_fontSize() * ui.scale;

	vec2 delta = round(statePos + 0.5 - ui.pxPos);

	return mouseOver && delta.x == 0.0 && delta.y == 0.0;
}
bool s2h_checkBox(inout ContextGather ui, bool checked)
{
    return s2h_checkBox(ui, checked, ui.mouseInput.xy);
}

void s2h_progress(inout ContextGather ui, uint widthInCharacters, float fraction)
{
	vec4 color = ui.buttonColor;
	vec4 outerAABB = vec4(ui.pxCursor, ui.pxCursor + vec2(float(widthInCharacters) * s2h_fontSize(), s2h_fontSize() - 2.0) * ui.scale);
	outerAABB += 0.5;

	// shrink
	vec4 innerAABB = outerAABB + vec4(1, 1, -1, -1) * ui.scale;

	innerAABB.z = mix(innerAABB.x, innerAABB.z, clamp(fraction,0.0,1.0));

	float sliderDist = s2h_computeDistToBox(ui, ui.pxPos, outerAABB);
	float innerDist = s2h_computeDistToBox(ui, ui.pxPos, innerAABB);

	vec4 localColor = vec4(0,0,0,0);

	// no AA for now
	if(sliderDist <= 0.0)
		localColor = color;

	if(innerDist <= 0.0)
		localColor = mix(localColor, vec4(ui.textColor.rgb, 1), ui.textColor.a);

	ui.pxCursor.x += float(widthInCharacters) * s2h_fontSize() * ui.scale;

	ui.dstColor = mix(ui.dstColor, vec4(localColor.rgb, 1), localColor.a * (1.0 - ui.dstColor.a));
}

void s2h_sliderFloat(inout ContextGather ui, uint widthInCharacters, inout float value, float minValue, float maxValue)
{
	vec4 color = ui.buttonColor; 
	vec4 outerAABB = vec4(ui.pxCursor, ui.pxCursor + vec2(float(widthInCharacters) * s2h_fontSize(), s2h_fontSize() - 2.0) * ui.scale);
 	outerAABB += 0.5;

	float halfChar = s2h_fontSize() / 2.0;
 
	// shrink 
	vec4 innerAABB = outerAABB + vec4(1, 1, -1, -1) * ui.scale;
 
	float sliderDist = s2h_computeDistToBox(ui, ui.pxPos, outerAABB);
 
	// todo: active button should be made for all UI interactive buttons (checkbox, radio, button)
	vec2 currentMouse = (ui.s2h_State.x == 0 && ui.s2h_State.y == 0) ? ui.mouseInput.xy : vec2(ui.s2h_State.xy);
 
	bool mouseOver = s2h_computeDistToBox(ui, currentMouse, outerAABB) <= 0.0;
 
	vec3 knobColor = ui.textColor.rgb; 

	// mouse over and left mouse button pressed
	if(mouseOver && ui.mouseInput.z != 0.0)
	{ 
		float newFraction = clamp((ui.mouseInput.xy.x - innerAABB.x) / (innerAABB.z - innerAABB.x),0.0,1.0);
		newFraction = floor(newFraction * 255.0) / 255.0;
		value = mix(minValue, maxValue, newFraction); 
 
		knobColor = vec3(1, 1, 1); 
 
		// todo: active button should be made for all UI interactive buttons (checkbox, radio, button)
		if(ui.s2h_State.x == 0 && ui.s2h_State.y == 0)
			ui.s2h_State.xy = ivec2(ui.mouseInput.xy);
	} 
 
	float fraction = clamp((value - minValue) / (maxValue - minValue),0.0,1.0);

	float knobRange = (float(widthInCharacters) - 1.0) * s2h_fontSize() * ui.scale;
	vec2 knobPos = ui.pxCursor + vec2(halfChar * ui.scale, 0.0) + vec2(fraction * knobRange, 3.0 * ui.scale);
	vec2 knobSize = vec2(s2h_fontSize() - 4.0, s2h_fontSize() - 4.0) * 0.5 * ui.scale;
	vec4 knobAABB = vec4(knobPos - knobSize, knobPos + knobSize);
 	knobAABB += 0.5;

	float knobDist = s2h_computeDistToBox(ui, ui.pxPos, knobAABB);

	vec4 localColor = vec4(0,0,0,0);

	if(mouseOver && sliderDist <= 2.0)
		localColor = vec4(1, 1, 1 ,1);

	// no AA for now
	if(sliderDist <= 0.0)
		localColor = color;

//	if(innerDist <= 0.0)
//		localColor = lerp(localColor, float4(ui.textColor.rgb, 1), ui.textColor.a);

	if(knobDist <= 0.0)
		localColor = mix(localColor, vec4(knobColor, 1), ui.textColor.a);

	ui.pxCursor.x += float(widthInCharacters) * s2h_fontSize() * ui.scale;

	ui.dstColor = mix(ui.dstColor, vec4(localColor.rgb, 1), localColor.a * (1.0 - ui.dstColor.a));
} 

void s2h_sliderRGB(inout ContextGather ui, uint widthInCharacters, inout vec3 value)
{
	float r = 3.0 * s2h_fontSize() * 0.5 * ui.scale - 1.0;
	vec4 backup = ui.buttonColor;

	vec2 initialPos = ui.pxCursor;
	vec2 pos = initialPos + vec2(3.0 * s2h_fontSize() * ui.scale, 0.0);

	ui.pxCursor.x = pos.x;
	ui.buttonColor = vec4(1,0.1,0.1,1);
	s2h_sliderFloat(ui, widthInCharacters - 3, value.r, 0.0, 1.0);
	s2h_printLF(ui);

	ui.pxCursor.x = pos.x;
	ui.buttonColor = vec4(0,1,0,1);
	s2h_sliderFloat(ui, widthInCharacters - 3, value.g, 0.0, 1.0);
	s2h_printLF(ui);

	ui.pxCursor.x = pos.x;
	ui.buttonColor = vec4(0.2,0.2,1,1);
	s2h_sliderFloat(ui, widthInCharacters - 3, value.b, 0.0, 1.0);
	s2h_printLF(ui);

	// todo: don't abuse circle drawing for disk drawing
	// todo: check if sRGB blending is right, it looks wrong with white
	s2h_drawDisc(ui, initialPos + r, r, vec4(value, 1));

	ui.pxCursor = initialPos + vec2(float(widthInCharacters) * s2h_fontSize() * ui.scale, 0.0);

	ui.buttonColor = backup;
}

void s2h_sliderRGBA(inout ContextGather ui, uint widthInCharacters, inout vec4 value)
{
	float r = 3.0 * s2h_fontSize() * 0.5 * ui.scale - 1.0;
	vec4 backup = ui.buttonColor;

	vec2 initialPos = ui.pxCursor;
	vec2 pos = initialPos + vec2(3.0 * s2h_fontSize() * ui.scale, 0.0);

	ui.pxCursor.x = pos.x;
	ui.buttonColor = vec4(1,0.1,0.1,1);
	s2h_sliderFloat(ui, widthInCharacters - 3, value.r, 0.0, 1.0);
	s2h_printLF(ui);

	ui.pxCursor.x = pos.x;
	ui.buttonColor = vec4(0,1,0,1);
	s2h_sliderFloat(ui, widthInCharacters - 3, value.g, 0.0, 1.0);
	s2h_printLF(ui);

	ui.pxCursor.x = pos.x;
	ui.buttonColor = vec4(0.2,0.2,1,1);
	s2h_sliderFloat(ui, widthInCharacters - 3, value.b, 0.0, 1.0);
	s2h_printLF(ui);

	ui.pxCursor.x = pos.x;
	ui.buttonColor = vec4(0.5,0.5,0.5,1);
	s2h_sliderFloat(ui, widthInCharacters - 3, value.a, 0.0, 1.0);
	s2h_printLF(ui);

	// todo: don't abuse circle drawing for disk drawing
	// todo: check if sRGB blending is right, it looks wrong with white
	s2h_drawDisc(ui, initialPos + r, r, value);

	ui.pxCursor = initialPos + vec2(float(widthInCharacters) * s2h_fontSize() * ui.scale, 0.0);

	ui.buttonColor = backup;
}

vec3 s2h_accurateLinearToSRGB(vec3 linearCol)
{
	vec3 sRGBLo = linearCol * 12.92;
	vec3 sRGBHi = (pow(abs(linearCol), vec3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
	vec3 sRGB;
	sRGB.r = linearCol.r <= 0.0031308 ? sRGBLo.r : sRGBHi.r;
	sRGB.g = linearCol.g <= 0.0031308 ? sRGBLo.g : sRGBHi.g;
	sRGB.b = linearCol.b <= 0.0031308 ? sRGBLo.b : sRGBHi.b;
	return sRGB;
}

vec3 s2h_accurateSRGBToLinear(vec3 sRGBCol)
{
	vec3 linearRGBLo = sRGBCol / 12.92;
	vec3 linearRGBHi = pow((sRGBCol + 0.055) / 1.055, vec3(2.4, 2.4, 2.4));
	vec3 linearRGB;
	linearRGB.r = sRGBCol.r <= 0.04045 ? linearRGBLo.r : linearRGBHi.r;
	linearRGB.g = sRGBCol.g <= 0.04045 ? linearRGBLo.g : linearRGBHi.g;
	linearRGB.b = sRGBCol.b <= 0.04045 ? linearRGBLo.b : linearRGBHi.b;
	return linearRGB;
}

vec3 s2h_indexToColor(uint index)
{
    uint a = bit(index,   1);
    uint d = bit(index,   2);
    uint g = bit(index,   4);

    uint b = bit(index,   8);
    uint e = bit(index,  16);
    uint h = bit(index,  32);

    uint c = bit(index,  64);
    uint f = bit(index, 128);
    uint i = bit(index, 256);

	return vec3(a * 4 + b * 2 + c, d * 4 + e * 2 + f, g * 4 + h * 2 + i) / 7.0;
}

vec3 s2h_colorRampRGB(float value)
{
	return vec3(
		clamp(1.0 - abs(value) * 2.0,0.0,1.0),
		clamp(1.0 - abs(value - 0.5) * 2.0,0.0,1.0),
		clamp(1.0 - abs(value - 1.0) * 2.0,0.0,1.0));
}

void main() {}