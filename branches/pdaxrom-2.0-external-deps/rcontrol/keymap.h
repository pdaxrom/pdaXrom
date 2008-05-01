enum {
    MODE_UNK = 0,
    MODE_KEYBOARD,
    MODE_MOUSE
};

struct rc_event {
    int		scan;
    int		mode;
    __u16	type;
    __u16	code;
    __s32	value;
};

struct rc_event rc_events[] = {
    { 0x1e0, MODE_MOUSE, EV_REL, REL_X, -5},
    { 0x1e1, MODE_MOUSE, EV_REL, REL_Y, -5},
    { 0x1d4, MODE_MOUSE, EV_REL, REL_X,  5},
    { 0x1d5, MODE_MOUSE, EV_REL, REL_Y,  5},
    { 0x1c2, MODE_KEYBOARD, EV_KEY, BTN_LEFT, 1},
    { 0x1e4, MODE_KEYBOARD, EV_KEY, KEY_1, 1},
    { 0x1cb, MODE_KEYBOARD, EV_KEY, KEY_2, 1},
    { 0x1c9, MODE_KEYBOARD, EV_KEY, KEY_3, 1},
    { 0x1e5, MODE_KEYBOARD, EV_KEY, KEY_4, 1},
    { 0x1cf, MODE_KEYBOARD, EV_KEY, KEY_5, 1},
    { 0x1cd, MODE_KEYBOARD, EV_KEY, KEY_6, 1},
    { 0x1e6, MODE_KEYBOARD, EV_KEY, KEY_7, 1},
    { 0x1ce, MODE_KEYBOARD, EV_KEY, KEY_8, 1},
    { 0x1cc, MODE_KEYBOARD, EV_KEY, KEY_9, 1},
    { 0x1ca, MODE_KEYBOARD, EV_KEY, KEY_ESC, 1},
    { 0x1d2, MODE_KEYBOARD, EV_KEY, KEY_0, 1},
    { 0x1c0, MODE_KEYBOARD, EV_KEY, KEY_ENTER, 1},

    { 0x1e9, MODE_KEYBOARD, EV_KEY, KEY_BACKSPACE, 1},
    { 0x1e8, MODE_KEYBOARD, EV_KEY, KEY_PAGEUP, 1},
    { 0x1d8, MODE_KEYBOARD, EV_KEY, KEY_PAGEDOWN, 1},
    { 0x1dd, MODE_KEYBOARD, EV_KEY, BTN_RIGHT, 1},

    {0, 0, 0, 0, 0}
};

