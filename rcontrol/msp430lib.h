/////////////////////////////////////////////////////////////////////////////
//                                                                         //
//  Project:        Set-top box                                            //
//                                                                         //
//  file:           msp430lib.h                                            //
//  desc:           .                                                      //
//  target:         .                                                      //
//  start:          2007.05.08                                             //
//  lastcorrection: 2007.08.13                                             //
//  currentversion: 0.2.1                                                  //
//                                                                         //
//  comments :                                                             //
//                                                                         //
//                                                                         //
//                                                                         //
//  copyright:                                                             //
//  authors:        Igor Fadin, ......................................     //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////


/**
 * @file    msp430lib.h
 * @brief   
 * @version 00.10
 *
 * Put the file comments here.
 *
 * @verbatim
 * ============================================================================
 * Copyright (c) Texas Instruments Inc 2005
 *
 * Use of this software is controlled by the terms and conditions found in the
 * license agreement under which this software has been supplied or provided.
 * ============================================================================
 * @endverbatim
 */

#ifndef __FILE_STB_MSP430LIB_H__
#define __FILE_STB_MSP430LIB_H__

#define MSP430LIB_SUCCESS 1     //!< Indicates success of an API call.
#define MSP430LIB_FAILURE 0     //!< Indicates failure of an API call.

enum toggle_switcher_t
{
    MSP430LIB_WITHOUT_TOGGLE = 0,
    MSP430LIB_WITH_TOGGLE    = 1
};

/**
 * @brief The IR remote keycodes returned by the MSP430. Requires the DVD
 * function on Philips PM4S set to code 020.
 */
  

#define KEYCODE_POWERONOFF      0
#define KEYCODE_PLAY            1
#define KEYCODE_STOP            2
#define KEYCODE_ENTER           3

#define KEYCODE_POINTER_UP      4
#define KEYCODE_POINTER_DOWN    5
#define KEYCODE_POINTER_LEFT    6
#define KEYCODE_POINTER_RIGHT   7

#define KEYCODE_WEB				8
#define KEYCODE_MENU			9
#define KEYCODE_PREV    		10
#define KEYCODE_NEXT    		11
#define KEYCODE_F2    			12

#define KEYCODE_PAUSE  			13
#define KEYCODE_FASTFORWARD		14
#define KEYCODE_FASTBACKWARD	15
#define KEYCODE_REBOOT			16

#define KEYCODE_UNDEFINED   0xffff


#define rc5_clear_togglebit(a) a &= ~(1<<11)
#define rc5_get_togglebit(a)   ((a & (1<<11))?1:0)

#define rc5_clear_startbits(a) a &= 0xfff
#define rc5_getsystem(a) ((a & (0x1f<<6))>>6)
#define rc5_getcmd(a)    ( a & 0x3f )


#if defined (__cplusplus)
extern "C" {
#endif

/**
 * @brief Initializes the MSP430 library. Must be called before any API calls.
 * @return MSP430LIB_SUCCESS on success and MSP430LIB_FAILURE on failure.
 */
extern int msp430lib_init(void);

/**
 * @brief Get the current Real Time Clock value from the MSP430.
 * @param year The current year returned in hexadecimal.
 * @param month The current month returned in hexadecimal.
 * @param day The current day returned in hexadecimal.
 * @param hour The current hour returned in hexadecimal.
 * @param minute The current minute returned in hexadecimal.
 * @param second The current second returned in hexadecimal.
 * @return MSP430LIB_SUCCESS on success and MSP430LIB_FAILURE on failure.
 */
extern int msp430lib_get_rtc(int *year, int *month, int *day, int *hour,
                             int *minute, int *second);

/**
 * @brief Set the current Real Time Clock value on the MSP430.
 * @param year The year to set in hexadecimal.
 * @param month The month to set in hexadecimal.
 * @param day The day to set in hexadecimal.
 * @param hour The hour to set in hexadecimal.
 * @param minute The minute to set hexadecimal.
 * @param second The second to set hexadecimal.
 * @return MSP430LIB_SUCCESS on success and MSP430LIB_FAILURE on failure.
 */
extern int msp430lib_set_rtc(int year, int month, int day, int hour,
                             int minute, int second);

/**
 * @brief Get a new IR key from the msp430 (if any).
 * @param key The key pressed returned or 0 if no new key pressed.
 * @return MSP430LIB_SUCCESS on success and MSP430LIB_FAILURE on failure.
 */
extern int msp430lib_get_ir_key(int  *key, enum toggle_switcher_t t);  

/**
 * @brief Deinitalize the MSP430 library. No API calls can be made after this
 * function has been called.
 * @return MSP430LIB_SUCCESS on success and MSP430LIB_FAILURE on failure.
 */
extern int msp430lib_exit(void);

#if defined (__cplusplus)
}
#endif

#endif // __FILE_STB_MSP430LIB_H__

