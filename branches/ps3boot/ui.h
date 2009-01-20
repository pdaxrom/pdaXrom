#ifndef _UI_H_
#define _UI_H_

#include "image.h"

enum {
    DB_EVENT_NONE = 0,
    DB_EVENT_KEYPRESS,
    DB_EVENT_KEYRELEASE,
    DB_EVENT_QUIT
};

#define DB_KBD_NO_KEY	-1

enum {
    DB_KEY_RSHIFT_BIT = 1,
    DB_KEY_LSHIFT_BIT = 2
};

typedef enum {
	/* The keyboard syms have been cleverly chosen to map to ASCII */
	DB_KEY_UNKNOWN		= 0,
	DB_KEY_FIRST		= 0,
	DB_KEY_BACKSPACE	= 8,
	DB_KEY_TAB		= 9,
	DB_KEY_CLEAR		= 12,
	DB_KEY_RETURN		= 13,
	DB_KEY_PAUSE		= 19,
	DB_KEY_ESCAPE		= 27,
	DB_KEY_SPACE		= 32,
	DB_KEY_EXCLAIM		= 33,
	DB_KEY_QUOTEDBL		= 34,
	DB_KEY_HASH		= 35,
	DB_KEY_DOLLAR		= 36,
	DB_KEY_AMPERSAND	= 38,
	DB_KEY_QUOTE		= 39,
	DB_KEY_LEFTPAREN	= 40,
	DB_KEY_RIGHTPAREN	= 41,
	DB_KEY_ASTERISK		= 42,
	DB_KEY_PLUS		= 43,
	DB_KEY_COMMA		= 44,
	DB_KEY_MINUS		= 45,
	DB_KEY_PERIOD		= 46,
	DB_KEY_SLASH		= 47,
	DB_KEY_0		= 48,
	DB_KEY_1		= 49,
	DB_KEY_2		= 50,
	DB_KEY_3		= 51,
	DB_KEY_4		= 52,
	DB_KEY_5		= 53,
	DB_KEY_6		= 54,
	DB_KEY_7		= 55,
	DB_KEY_8		= 56,
	DB_KEY_9		= 57,
	DB_KEY_COLON		= 58,
	DB_KEY_SEMICOLON	= 59,
	DB_KEY_LESS		= 60,
	DB_KEY_EQUALS		= 61,
	DB_KEY_GREATER		= 62,
	DB_KEY_QUESTION		= 63,
	DB_KEY_AT		= 64,
	/* 
	   Skip uppercase letters
	 */
	DB_KEY_LEFTBRACKET	= 91,
	DB_KEY_BACKSLASH	= 92,
	DB_KEY_RIGHTBRACKET	= 93,
	DB_KEY_CARET		= 94,
	DB_KEY_UNDERSCORE	= 95,
	DB_KEY_BACKQUOTE	= 96,
	DB_KEY_a		= 97,
	DB_KEY_b		= 98,
	DB_KEY_c		= 99,
	DB_KEY_d		= 100,
	DB_KEY_e		= 101,
	DB_KEY_f		= 102,
	DB_KEY_g		= 103,
	DB_KEY_h		= 104,
	DB_KEY_i		= 105,
	DB_KEY_j		= 106,
	DB_KEY_k		= 107,
	DB_KEY_l		= 108,
	DB_KEY_m		= 109,
	DB_KEY_n		= 110,
	DB_KEY_o		= 111,
	DB_KEY_p		= 112,
	DB_KEY_q		= 113,
	DB_KEY_r		= 114,
	DB_KEY_s		= 115,
	DB_KEY_t		= 116,
	DB_KEY_u		= 117,
	DB_KEY_v		= 118,
	DB_KEY_w		= 119,
	DB_KEY_x		= 120,
	DB_KEY_y		= 121,
	DB_KEY_z		= 122,
	DB_KEY_DELETE		= 127,
	/* End of ASCII mapped keysyms */

	/* International keyboard syms */
	DB_KEY_WORLD_0		= 160,		/* 0xA0 */
	DB_KEY_WORLD_1		= 161,
	DB_KEY_WORLD_2		= 162,
	DB_KEY_WORLD_3		= 163,
	DB_KEY_WORLD_4		= 164,
	DB_KEY_WORLD_5		= 165,
	DB_KEY_WORLD_6		= 166,
	DB_KEY_WORLD_7		= 167,
	DB_KEY_WORLD_8		= 168,
	DB_KEY_WORLD_9		= 169,
	DB_KEY_WORLD_10		= 170,
	DB_KEY_WORLD_11		= 171,
	DB_KEY_WORLD_12		= 172,
	DB_KEY_WORLD_13		= 173,
	DB_KEY_WORLD_14		= 174,
	DB_KEY_WORLD_15		= 175,
	DB_KEY_WORLD_16		= 176,
	DB_KEY_WORLD_17		= 177,
	DB_KEY_WORLD_18		= 178,
	DB_KEY_WORLD_19		= 179,
	DB_KEY_WORLD_20		= 180,
	DB_KEY_WORLD_21		= 181,
	DB_KEY_WORLD_22		= 182,
	DB_KEY_WORLD_23		= 183,
	DB_KEY_WORLD_24		= 184,
	DB_KEY_WORLD_25		= 185,
	DB_KEY_WORLD_26		= 186,
	DB_KEY_WORLD_27		= 187,
	DB_KEY_WORLD_28		= 188,
	DB_KEY_WORLD_29		= 189,
	DB_KEY_WORLD_30		= 190,
	DB_KEY_WORLD_31		= 191,
	DB_KEY_WORLD_32		= 192,
	DB_KEY_WORLD_33		= 193,
	DB_KEY_WORLD_34		= 194,
	DB_KEY_WORLD_35		= 195,
	DB_KEY_WORLD_36		= 196,
	DB_KEY_WORLD_37		= 197,
	DB_KEY_WORLD_38		= 198,
	DB_KEY_WORLD_39		= 199,
	DB_KEY_WORLD_40		= 200,
	DB_KEY_WORLD_41		= 201,
	DB_KEY_WORLD_42		= 202,
	DB_KEY_WORLD_43		= 203,
	DB_KEY_WORLD_44		= 204,
	DB_KEY_WORLD_45		= 205,
	DB_KEY_WORLD_46		= 206,
	DB_KEY_WORLD_47		= 207,
	DB_KEY_WORLD_48		= 208,
	DB_KEY_WORLD_49		= 209,
	DB_KEY_WORLD_50		= 210,
	DB_KEY_WORLD_51		= 211,
	DB_KEY_WORLD_52		= 212,
	DB_KEY_WORLD_53		= 213,
	DB_KEY_WORLD_54		= 214,
	DB_KEY_WORLD_55		= 215,
	DB_KEY_WORLD_56		= 216,
	DB_KEY_WORLD_57		= 217,
	DB_KEY_WORLD_58		= 218,
	DB_KEY_WORLD_59		= 219,
	DB_KEY_WORLD_60		= 220,
	DB_KEY_WORLD_61		= 221,
	DB_KEY_WORLD_62		= 222,
	DB_KEY_WORLD_63		= 223,
	DB_KEY_WORLD_64		= 224,
	DB_KEY_WORLD_65		= 225,
	DB_KEY_WORLD_66		= 226,
	DB_KEY_WORLD_67		= 227,
	DB_KEY_WORLD_68		= 228,
	DB_KEY_WORLD_69		= 229,
	DB_KEY_WORLD_70		= 230,
	DB_KEY_WORLD_71		= 231,
	DB_KEY_WORLD_72		= 232,
	DB_KEY_WORLD_73		= 233,
	DB_KEY_WORLD_74		= 234,
	DB_KEY_WORLD_75		= 235,
	DB_KEY_WORLD_76		= 236,
	DB_KEY_WORLD_77		= 237,
	DB_KEY_WORLD_78		= 238,
	DB_KEY_WORLD_79		= 239,
	DB_KEY_WORLD_80		= 240,
	DB_KEY_WORLD_81		= 241,
	DB_KEY_WORLD_82		= 242,
	DB_KEY_WORLD_83		= 243,
	DB_KEY_WORLD_84		= 244,
	DB_KEY_WORLD_85		= 245,
	DB_KEY_WORLD_86		= 246,
	DB_KEY_WORLD_87		= 247,
	DB_KEY_WORLD_88		= 248,
	DB_KEY_WORLD_89		= 249,
	DB_KEY_WORLD_90		= 250,
	DB_KEY_WORLD_91		= 251,
	DB_KEY_WORLD_92		= 252,
	DB_KEY_WORLD_93		= 253,
	DB_KEY_WORLD_94		= 254,
	DB_KEY_WORLD_95		= 255,		/* 0xFF */

	/* Numeric keypad */
	DB_KEY_KP0		= 256,
	DB_KEY_KP1		= 257,
	DB_KEY_KP2		= 258,
	DB_KEY_KP3		= 259,
	DB_KEY_KP4		= 260,
	DB_KEY_KP5		= 261,
	DB_KEY_KP6		= 262,
	DB_KEY_KP7		= 263,
	DB_KEY_KP8		= 264,
	DB_KEY_KP9		= 265,
	DB_KEY_KP_PERIOD	= 266,
	DB_KEY_KP_DIVIDE	= 267,
	DB_KEY_KP_MULTIPLY	= 268,
	DB_KEY_KP_MINUS		= 269,
	DB_KEY_KP_PLUS		= 270,
	DB_KEY_KP_ENTER		= 271,
	DB_KEY_KP_EQUALS	= 272,

	/* Arrows + Home/End pad */
	DB_KEY_UP		= 273,
	DB_KEY_DOWN		= 274,
	DB_KEY_RIGHT		= 275,
	DB_KEY_LEFT		= 276,
	DB_KEY_INSERT		= 277,
	DB_KEY_HOME		= 278,
	DB_KEY_END		= 279,
	DB_KEY_PAGEUP		= 280,
	DB_KEY_PAGEDOWN		= 281,

	/* Function keys */
	DB_KEY_F1		= 282,
	DB_KEY_F2		= 283,
	DB_KEY_F3		= 284,
	DB_KEY_F4		= 285,
	DB_KEY_F5		= 286,
	DB_KEY_F6		= 287,
	DB_KEY_F7		= 288,
	DB_KEY_F8		= 289,
	DB_KEY_F9		= 290,
	DB_KEY_F10		= 291,
	DB_KEY_F11		= 292,
	DB_KEY_F12		= 293,
	DB_KEY_F13		= 294,
	DB_KEY_F14		= 295,
	DB_KEY_F15		= 296,

	/* Key state modifier keys */
	DB_KEY_NUMLOCK		= 300,
	DB_KEY_CAPSLOCK		= 301,
	DB_KEY_SCROLLOCK	= 302,
	DB_KEY_RSHIFT		= 303,
	DB_KEY_LSHIFT		= 304,
	DB_KEY_RCTRL		= 305,
	DB_KEY_LCTRL		= 306,
	DB_KEY_RALT		= 307,
	DB_KEY_LALT		= 308,
	DB_KEY_RMETA		= 309,
	DB_KEY_LMETA		= 310,
	DB_KEY_LSUPER		= 311,		/* Left "Windows" key */
	DB_KEY_RSUPER		= 312,		/* Right "Windows" key */
	DB_KEY_MODE		= 313,		/* "Alt Gr" key */
	DB_KEY_COMPOSE		= 314,		/* Multi-key compose key */

	/* Miscellaneous function keys */
	DB_KEY_HELP		= 315,
	DB_KEY_PRINT		= 316,
	DB_KEY_SYSREQ		= 317,
	DB_KEY_BREAK		= 318,
	DB_KEY_MENU		= 319,
	DB_KEY_POWER		= 320,		/* Power Macintosh power key */
	DB_KEY_EURO		= 321,		/* Some european keyboards */
	DB_KEY_UNDO		= 322,		/* Atari keyboard has Undo */

	/* Add any other keys here */

	DB_KEY_LAST
} DBKey;

typedef struct {
    int type;
    int keycode;
    int key;
} db_ui_key_event;

typedef struct {
} db_ui_mouse_event;

typedef union _db_ui_event {
    int type;
    db_ui_key_event key;
    db_ui_mouse_event mouse;
} db_ui_event;

int db_ui_create(void);

db_image *db_ui_get_screen(void);

int db_ui_update_screen(void);

int db_ui_check_events(db_ui_event *event);

void db_ui_close(void);

#endif
