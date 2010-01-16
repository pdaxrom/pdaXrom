/*
 * Project Name JPEG DRIVER IN Linux
 * Copyright  2007 Samsung Electronics Co, Ltd. All Rights Reserved. 
 *
 * This software is the confidential and proprietary information
 * of Samsung Electronics  ("Confidential Information").   
 * you shall not disclose such Confidential Information and shall use
 * it only in accordance with the terms of the license agreement
 * you entered into with Samsung Electronics 
 *
 * This file implements JPEG driver.
 *
 * @name JPEG DRIVER MODULE Module (JPGConf.h)
 * @author Jiun Yu (jiun.yu@samsung.com)
 * @date 05-07-07
 */
#ifndef __JPG_CONF_H__
#define __JPG_CONF_H__

//#define JPEG_ENCODE_LEVEL_1
//#define JPEG_ENCODE_LEVEL_2
#define JPEG_ENCODE_LEVEL_3
#define JPEG_ENCODE_LEVEL_4
//#define JPEG_ENCODE_LEVEL_5
#define JPEG_ENCODE_LEVEL_6    // -> thumbnail standard.
//#define JPEG_ENCODE_LEVEL_7
#define JPEG_ENCODE_LEVEL_8
 

const unsigned char QTBL_Luminance[4][64]=
{
	#ifdef JPEG_ENCODE_LEVEL_1
	// level 1
	{
		1, 1, 1, 1, 1, 2, 3, 3, 
		1, 1, 1, 1, 1, 3, 3, 3, 
		1, 1, 1, 1, 2, 3, 3, 3, 
		1, 1, 1, 1, 2, 4, 4, 3, 
		1, 1, 3, 4, 4, 6, 6, 4, 
		1, 2, 3, 3, 4, 5, 6, 5, 
		2, 3, 4, 4, 5, 6, 6, 5, 
		5, 5, 5, 5, 5, 5, 5, 5 
	},
	#endif //JPEG_ENCODE_LEVEL_1

	#ifdef JPEG_ENCODE_LEVEL_2
	// level 2
	{
		 1,  1,  1,  2,  3,  6,  8, 10,
		 1,  1,  2,  3,  4,  8,  9,  8, 
		 2,  2,  2,  3,  6,  8, 10,  8, 
		 2,  2,  3,  4,  7, 12, 11,  9, 
		 3,  3,  8, 11, 10, 16, 15, 11,
		 3,  5,  8, 10, 12, 15, 16, 13, 
		 7, 10, 11, 12, 15, 17, 17, 14,
		14, 13, 13, 15, 15, 14, 14, 14 
	},
	#endif //JPEG_ENCODE_LEVEL_2

	#ifdef JPEG_ENCODE_LEVEL_3
	// level 3
	{
		 3,  2,  2,  3,  5,  8, 10, 12, 
		 2,  2,  3,  4,  5, 11, 11, 13, 
		 3,  2,  3,  5,  8, 11, 13, 11,
		 3,  3,  4,  6, 10, 17, 15, 12, 
		 3,  4,  7, 11, 13, 21, 20, 15, 
		 5,  7, 10, 12, 15, 20, 21, 17, 
		 9, 12, 15, 17, 20, 23, 23, 19, 
		14, 17, 18, 19, 21, 19, 20, 19, 
	},
	#endif //JPEG_ENCODE_LEVEL_3

	#ifdef JPEG_ENCODE_LEVEL_4
	// level 4
	{
		 6,  4,  7, 11, 14, 17, 22, 17, 
		 4,  5,  6, 10, 14, 19, 12, 12, 
		 7,  6,  8, 14, 19, 12, 12, 12, 
		11, 10, 14, 19, 12, 12, 12, 12, 
		14, 14, 19, 12, 12, 12, 12, 12, 
		17, 19, 12, 12, 12, 12, 12, 12,
		22, 12, 12, 12, 12, 12, 12, 12, 
		17, 12, 12, 12, 12, 12, 12, 12 
	},
	#endif //JPEG_ENCODE_LEVEL_4

	#ifdef JPEG_ENCODE_LEVEL_5
	// level 5
	{
		8, 6, 6, 8, 12, 14, 16, 17,
		6, 6, 6, 8, 10, 13, 12, 15,
		6, 6, 7, 8, 13, 14, 18, 24,
		8, 8, 8, 14, 13, 19, 24, 35,
		12, 10, 13, 13, 20, 26, 34, 39,
		14, 13, 14, 19, 26, 34, 39, 39,
		16, 12, 18, 24, 34, 39, 39, 39,
		17, 15, 24, 35, 39, 39, 39, 39
	},	
	#endif //JPEG_ENCODE_LEVEL_5

	#ifdef JPEG_ENCODE_LEVEL_6	
	// level 6 -> thumbnail standard.
	{
		12, 8, 8, 12, 17, 21, 24, 23, 
		8, 9, 9, 11, 15, 19, 18, 23, 
		8, 9, 10, 12, 19, 20, 27, 36, 
		12, 11, 12, 21, 20, 28, 36, 53, 
		17, 15, 19, 20, 30, 39, 51, 59, 
		21, 19, 20, 28, 39, 51, 59, 59, 
		24, 18, 27, 36, 51, 59, 59, 59, 
		23, 23, 36, 53, 59, 59, 59, 59 
	},
	#endif //JPEG_ENCODE_LEVEL_6

	#ifdef JPEG_ENCODE_LEVEL_7
	// level 7
	{
		16, 11, 11, 16, 23, 27, 31, 30, 
		11, 12, 12, 15, 20, 23, 23, 30, 
		11, 12, 13, 16, 23, 26, 35, 47, 
		16, 15, 16, 23, 26, 37, 47, 64, 
		23, 20, 23, 26, 39, 51, 64, 64, 
		27, 23, 26, 37, 51, 64, 64, 64, 
		31, 23, 35, 47, 64, 64, 64, 64, 
		30, 30, 47, 64, 64, 64, 64, 64 
	},
	#endif //JPEG_ENCODE_LEVEL_7

	#ifdef JPEG_ENCODE_LEVEL_8
	// level 8
	{
		20, 16, 25, 39, 50, 46, 62, 68, 
		16, 18, 23, 38, 38, 53, 65, 68, 
		25, 23, 31, 38, 53, 65, 68, 68, 
		39, 38, 38, 53, 65, 68, 68, 68, 
		50, 38, 53, 65, 68, 68, 68, 68, 
		46, 53, 65, 68, 68, 68, 68, 68, 
		62, 65, 68, 68, 68, 68, 68, 68, 
		68, 68, 68, 68, 68, 68, 68, 68 
	}
	#endif //JPEG_ENCODE_LEVEL_8
};

const unsigned char QTBL_Chrominance[4][64]=
{
	#ifdef JPEG_ENCODE_LEVEL_1
	// level 1
	{
		 1,  1,  2,  4,  6, 11, 11, 11, 
		 1,  1,  2,  4,  8, 11, 11, 11, 
		 2,  2,  3,  4, 11, 11, 11, 11, 
		 4,  4,  4,  5, 11, 11, 11, 11, 
		 6,  8, 11, 11, 11, 11, 11, 11, 
		11, 11, 11, 11, 11, 11, 11, 11, 
		11, 11, 11, 11, 11, 11, 11, 11, 
		11, 11, 11, 11, 11, 11, 11, 11
	},
	#endif //JPEG_ENCODE_LEVEL_1

	#ifdef JPEG_ENCODE_LEVEL_2
	// level 2
	{
		 4,  4,  5,  9, 15, 26, 26, 26, 
		 4,  4,  5, 10, 19, 26, 26, 26, 
		 5,  5,  8,  9, 26, 26, 26, 26, 
		 9, 10,  9, 13, 26, 26, 26, 26, 
		15, 19, 26, 26, 26, 26, 26, 26, 
		26, 26, 26, 26, 26, 26, 26, 26, 
		26, 26, 26, 26, 26, 26, 26, 26,
		26, 26, 26, 26, 26, 26, 26, 26
	},
	#endif //JPEG_ENCODE_LEVEL_2

	#ifdef JPEG_ENCODE_LEVEL_3
	// level 3
	{
		 3,  3,  5,  9, 19, 19, 19, 19, 
		 3,  4,  5, 13, 19, 19, 19, 19, 
		 5,  5, 11, 19, 19, 19, 19, 19, 
		 9, 13, 19, 19, 19, 19, 19, 19, 
		19, 19, 19, 19, 19, 19, 19, 19, 
		19, 19, 19, 19, 19, 19, 19, 19,
		19, 19, 19, 19, 19, 19, 19, 19, 
		19, 19, 19, 19, 19, 19, 19, 19 
	},
	#endif //JPEG_ENCODE_LEVEL_3

	#ifdef JPEG_ENCODE_LEVEL_4
	// level 4
{
		 7,  9, 19, 34, 20, 20, 17, 17, 
		 9, 12, 19, 14, 14, 12, 12, 12, 
		19, 19, 14, 14, 12, 12, 12, 12, 
		34, 14, 14, 12, 12, 12, 12, 12, 
		20, 14, 12, 12, 12, 12, 12, 12, 
		20, 12, 12, 12, 12, 12, 12, 12, 
		17, 12, 12, 12, 12, 12, 12, 12, 
		17, 12, 12, 12, 12, 12, 12, 12 
	},
	#endif //JPEG_ENCODE_LEVEL_4
	
	#ifdef JPEG_ENCODE_LEVEL_5
	// level 5
	{
		9, 8, 9, 11, 14, 17, 19, 24, 
		8, 10, 9, 11, 14, 13, 17, 22, 
		9, 9, 13, 14, 13, 15, 23, 26, 
		11, 11, 14, 14, 15, 20, 26, 33, 
		14, 14, 13, 15, 20, 24, 33, 39, 
		17, 13, 15, 20, 24, 32, 39, 39, 
		19, 17, 23, 26, 33, 39, 39, 39, 
		24, 22, 26, 33, 39, 39, 39, 39
	},
	#endif //JPEG_ENCODE_LEVEL_5

	#ifdef JPEG_ENCODE_LEVEL_6
	// level 6
	{
		13, 11, 13, 16, 20, 20, 29, 37, 
		11, 14, 14, 14, 16, 20, 26, 32, 
		13, 14, 15, 17, 20, 23, 35, 40, 
		16, 14, 17, 21, 23, 30, 40, 50, 
		20, 16, 20, 23, 30, 37, 50, 59, 
		20, 20, 23, 30, 37, 48, 59, 59, 
		29, 26, 35, 40, 50, 59, 59, 59, 
		37, 32, 40, 50, 59, 59, 59, 59 
	},
	#endif //JPEG_ENCODE_LEVEL_6

	#ifdef JPEG_ENCODE_LEVEL_7
	// level 7
	{
		17, 15, 17, 21, 20, 26, 38, 48, 
		15, 19, 18, 17, 20, 26, 35, 43, 
		17, 18, 20, 22, 26, 30, 46, 53, 
		21, 17, 22, 28, 30, 39, 53, 64, 
		20, 20, 26, 30, 39, 48, 64, 64, 
		26, 26, 30, 39, 48, 63, 64, 64, 
		38, 35, 46, 53, 64, 64, 64, 64, 
		48, 43, 53, 64, 64, 64, 64, 64 
	},
	#endif //JPEG_ENCODE_LEVEL_7

	#ifdef JPEG_ENCODE_LEVEL_8
	// level 8
	{
		21, 25, 32, 38, 54, 68, 68, 68, 
		25, 28, 24, 38, 54, 68, 68, 68, 
		32, 24, 32, 43, 66, 68, 68, 68, 
		38, 38, 43, 53, 68, 68, 68, 68, 
		54, 54, 66, 68, 68, 68, 68, 68, 
		68, 68, 68, 68, 68, 68, 68, 68, 
		68, 68, 68, 68, 68, 68, 68, 68, 
		68, 68, 68, 68, 68, 68, 68, 68 
	}
	#endif //JPEG_ENCODE_LEVEL_8
};



const unsigned char QTBL0[64]=
{
#if 1
	0x10, 0x0B, 0x0A, 0x10, 0x18, 0x28, 0x33, 0x3D,
	0x0C, 0x0C, 0x0E, 0x13, 0x1A, 0x3A, 0x3C, 0x37,
	0x0E, 0x0D, 0x10, 0x18, 0x28, 0x39, 0x45, 0x38,
	0x0E, 0x11, 0x16, 0x1D, 0x33, 0x57, 0x50, 0x3E,
	0x12, 0x16, 0x25, 0x38, 0x44, 0x6D, 0x67, 0x4D,
	0x18, 0x23, 0x37, 0x40, 0x51, 0x68, 0x71, 0x5C,
	0x31, 0x40, 0x4E, 0x57, 0x67, 0x79, 0x78, 0x65,
	0x48, 0x5C, 0x5F, 0x62, 0x70, 0x64, 0x67, 0x63
#else
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
	0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
#endif
};

//Added Quantization Table
const unsigned char std_chrominance_quant_tbl_plus[64]=
{
	0x11, 0x12, 0x18, 0x2F, 0x63, 0x63, 0x63, 0x63,
	0x12, 0x15, 0x1A, 0x42, 0x63, 0x63, 0x63, 0x63,
	0x18, 0x1A, 0x38, 0x63, 0x63, 0x63, 0x63, 0x63,
	0x2F, 0x42, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63,
	0x63, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63,
	0x63, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63,
	0x63, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63,
	0x63, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63, 0x63
};

//Quantization Table0
unsigned char std_luminance_quant_tbl[64] =
{
	1,   1,   2,   1,   1,   2,   2,   2,
	2,   3,   2,   2,   3,   3,   6,   4,
	3,   3,   3,   3,   7,   5,   8,   4,
	6,   8,   8,  10,   9,   8,   7,  11,
	8,  10,  14,  13,  11,  10,  10,  12,
	10,   8,   8,  11,  16,  12,  12,  13,
	15,  15,  15,  15,   9,  11,  16,  17,
	15,  14,  17,  13,  14,  14,  14,   1
 };

//Quantization Table1
unsigned char std_chrominance_quant_tbl[64] =
{
	4,   4,   4,   5,   4,   5,   9,   5,
	5,   9,  15,  10,   8,  10,  15,  26,
	19,   9,   9,  19,  26,  26,  26,  26,
	13,  26,  26,  26,  26,  26,  26,  26,
	26,  26,  26,  26,  26,  26,  26,  26,
	26,  26,  26,  26,  26,  26,  26,  26,
	26,  26,  26,  26,  26,  26,  26,  26,
	26,  26,  26,  26,  26,  26,  26,  26
};

//Huffman Table
unsigned char HDCTBL0[16]  = {0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0};
unsigned char HDCTBLG0[12] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0xa, 0xb};

unsigned char HACTBL0[16]= {0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 0x7d};
const unsigned char HACTBLG0[162]=
{
	0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12,
	0x21, 0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07,
	0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xa1, 0x08,
	0x23, 0x42, 0xb1, 0xc1, 0x15, 0x52, 0xd1, 0xf0,
	0x24, 0x33, 0x62, 0x72, 0x82, 0x09, 0x0a, 0x16,
	0x17, 0x18, 0x19, 0x1a, 0x25, 0x26, 0x27, 0x28,
	0x29, 0x2a, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
	0x3a, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49,
	0x4a, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
	0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69,
	0x6a, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79,
	0x7a, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
	0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98,
	0x99, 0x9a, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7,
	0xa8, 0xa9, 0xaa, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6,
	0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4, 0xc5,
	0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4,
	0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xe1, 0xe2,
	0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea,
	0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8,
	0xf9, 0xfa
};

//Huffman Table0
unsigned char len_dc_luminance[16] ={ 0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 };
unsigned char val_dc_luminance[12] ={ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };

unsigned char len_ac_luminance[16] ={ 0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 0x7d };
unsigned char val_ac_luminance[162] =
{
	0x01, 0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12,
	0x21, 0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07,
	0x22, 0x71, 0x14, 0x32, 0x81, 0x91, 0xa1, 0x08,
	0x23, 0x42, 0xb1, 0xc1, 0x15, 0x52, 0xd1, 0xf0,
	0x24, 0x33, 0x62, 0x72, 0x82, 0x09, 0x0a, 0x16,
	0x17, 0x18, 0x19, 0x1a, 0x25, 0x26, 0x27, 0x28,
	0x29, 0x2a, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
	0x3a, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49,
	0x4a, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59,
	0x5a, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69,
	0x6a, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79,
	0x7a, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89,
	0x8a, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98,
	0x99, 0x9a, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7,
	0xa8, 0xa9, 0xaa, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6,
	0xb7, 0xb8, 0xb9, 0xba, 0xc2, 0xc3, 0xc4, 0xc5,
	0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xd2, 0xd3, 0xd4,
	0xd5, 0xd6, 0xd7, 0xd8, 0xd9, 0xda, 0xe1, 0xe2,
	0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea,
	0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7, 0xf8,
	0xf9, 0xfa
};

//Huffman Table1
unsigned char len_dc_chrominance[16] ={ 0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0 };
unsigned char val_dc_chrominance[12] ={ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };

unsigned char len_ac_chrominance[16] ={ 0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0, 1, 2, 0x77 };
unsigned char val_ac_chrominance[162] =
{
	0x00, 0x01, 0x02, 0x03, 0x11, 0x04, 0x05, 0x21,
	0x31, 0x06, 0x12, 0x41, 0x51, 0x07, 0x61, 0x71,
	0x13, 0x22, 0x32, 0x81, 0x81, 0x08, 0x14, 0x42,
	0x91, 0xa1, 0xb1, 0xc1, 0x09, 0x23, 0x33, 0x52,
	0xf0, 0x15, 0x62, 0x72, 0xd1, 0x0a, 0x16, 0x24,
	0x34, 0xe1, 0x25, 0xf1, 0x17, 0x18, 0x19, 0x1a,
	0x26, 0x27, 0x28, 0x29, 0x2a, 0x35, 0x36, 0x37,
	0x38, 0x39, 0x3a, 0x43, 0x44, 0x45, 0x46, 0x47,
	0x48, 0x49, 0x4a, 0x53, 0x54, 0x55, 0x56, 0x57,
	0x58, 0x59, 0x5a, 0x63, 0x64, 0x65, 0x66, 0x67,
	0x68, 0x69, 0x6a, 0x73, 0x74, 0x75, 0x76, 0x77,
	0x78, 0x79, 0x7a, 0x82, 0x83, 0x84, 0x85, 0x86,
	0x87, 0x88, 0x89, 0x8a, 0x92, 0x93, 0x94, 0x95,
	0x96, 0x97, 0x98, 0x99, 0x9a, 0xa2, 0xa3, 0xa4,
	0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xb2, 0xb3,
	0xb4, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xc2,
	0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca,
	0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8, 0xd9,
	0xda, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7, 0xe8,
	0xe9, 0xea, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7,
	0xf8, 0xf9
};

#endif
