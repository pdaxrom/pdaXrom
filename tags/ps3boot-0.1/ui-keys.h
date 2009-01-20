static inline unsigned int key_shifted_key(unsigned int k)
{
    switch(k) {
    case DB_KEY_BACKQUOTE: return '~';
    case DB_KEY_1: 	return DB_KEY_EXCLAIM;
    case DB_KEY_2: 	return DB_KEY_AT;
    case DB_KEY_3: 	return DB_KEY_HASH;
    case DB_KEY_4: 	return DB_KEY_DOLLAR;
    case DB_KEY_5: 	return '%';
    case DB_KEY_6: 	return '^';
    case DB_KEY_7: 	return DB_KEY_AMPERSAND;
    case DB_KEY_8: 	return DB_KEY_ASTERISK;
    case DB_KEY_9: 	return DB_KEY_LEFTPAREN;
    case DB_KEY_0: 	return DB_KEY_RIGHTPAREN;
    case DB_KEY_MINUS: 	return DB_KEY_UNDERSCORE;
    case DB_KEY_EQUALS: return DB_KEY_PLUS;
    case DB_KEY_q: 	return 'Q';
    case DB_KEY_w: 	return 'W';
    case DB_KEY_e: 	return 'E';
    case DB_KEY_r: 	return 'R';
    case DB_KEY_t: 	return 'T';
    case DB_KEY_y: 	return 'Y';
    case DB_KEY_u: 	return 'U';
    case DB_KEY_i: 	return 'I';
    case DB_KEY_o: 	return 'O';
    case DB_KEY_p: 	return 'P';
    case DB_KEY_LEFTBRACKET: 	return '[';
    case DB_KEY_RIGHTBRACKET: 	return ']';
    case DB_KEY_a: 	return 'A';
    case DB_KEY_s: 	return 'S';
    case DB_KEY_d: 	return 'D';
    case DB_KEY_f: 	return 'F';
    case DB_KEY_g: 	return 'G';
    case DB_KEY_h: 	return 'H';
    case DB_KEY_j: 	return 'J';
    case DB_KEY_k: 	return 'K';
    case DB_KEY_l: 	return 'L';
    case DB_KEY_SEMICOLON: 	return DB_KEY_COLON;
    case DB_KEY_QUOTE: 		return DB_KEY_QUOTEDBL;
    case DB_KEY_BACKSLASH:	return '|';
    case DB_KEY_z: 	return 'Z';
    case DB_KEY_x: 	return 'X';
    case DB_KEY_c: 	return 'C';
    case DB_KEY_v: 	return 'V';
    case DB_KEY_b: 	return 'B';
    case DB_KEY_n: 	return 'N';
    case DB_KEY_m: 	return 'M';
    case DB_KEY_COMMA: 	return DB_KEY_LESS;
    case DB_KEY_PERIOD:	return DB_KEY_GREATER;
    case DB_KEY_SLASH: 	return DB_KEY_QUESTION;
    }
    return k;
}
