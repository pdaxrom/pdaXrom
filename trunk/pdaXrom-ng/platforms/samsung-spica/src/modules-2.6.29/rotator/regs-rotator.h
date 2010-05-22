/* rotator/regs-rotator.h
 *
 * Copyright (c) 2008 Samsung Electronics
 *
 * Samsung S3C Rotator driver
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
#ifndef __ASM_ARCH_REGS_ROTATOR_H
#define __ASM_ARCH_REGS_ROTATOR_H __FILE__


/*************************************************************************
 * Macro part
 ************************************************************************/
#define S3C_ROT_SRC_WIDTH(x)		((x) << 0)
#define S3C_ROT_SRC_HEIGHT(x)		((x) << 16)


/*************************************************************************
 * Bit definition part
 ************************************************************************/
#define S3C_ROTATOR_IDLE				(0 << 0)
#define S3C_ROTATOR_CTRLREG_MASK			0xE0F0

#define S3C_ROTATOR_CTRLCFG_ENABLE_INT		    (1 << 24)

#define S3C_ROTATOR_CTRLCFG_INPUT_YUV420	    (0 << 13)
#define S3C_ROTATOR_CTRLCFG_INPUT_YUV422	    (3 << 13)
#define S3C_ROTATOR_CTRLCFG_INPUT_RGB565	    (4 << 13)
#define S3C_ROTATOR_CTRLCFG_INPUT_RGB888	    (5 << 13)

#define S3C_ROTATOR_CTRLCFG_DEGREE_BYPASS	    (0 << 6)
#define S3C_ROTATOR_CTRLCFG_DEGREE_90		    (1 << 6)
#define S3C_ROTATOR_CTRLCFG_DEGREE_180		    (2 << 6)
#define S3C_ROTATOR_CTRLCFG_DEGREE_270		    (3 << 6)

#define S3C_ROTATOR_CTRLCFG_FLIP_BYPASS		    (0 << 4)
#define S3C_ROTATOR_CTRLCFG_FLIP_VER		    (2 << 4)
#define S3C_ROTATOR_CTRLCFG_FLIP_HOR		    (3 << 4)

#define S3C_ROTATOR_STATCFG_STATUS_IDLE		    (0 << 0)
#define S3C_ROTATOR_CTRLCFG_START_ROTATE	    (1 << 0)
#define S3C_ROTATOR_STATCFG_STATUS_BUSY		    (2 << 0)
#define S3C_ROTATOR_STATCFG_STATUS_BUSY_MORE	(3 << 0)


/*************************************************************************
 * Register part
 ************************************************************************/
#define S3C_ROTATOR(x)	((x))
#define S3C_ROTATOR_CTRLCFG			    S3C_ROTATOR(0x0)
#define S3C_ROTATOR_SRCADDRREG0			S3C_ROTATOR(0x4)
#define S3C_ROTATOR_SRCADDRREG1			S3C_ROTATOR(0x8)
#define S3C_ROTATOR_SRCADDRREG2			S3C_ROTATOR(0xC)
#define S3C_ROTATOR_SRCSIZEREG			S3C_ROTATOR(0x10)
#define S3C_ROTATOR_DESTADDRREG0		S3C_ROTATOR(0x18)
#define S3C_ROTATOR_DESTADDRREG1		S3C_ROTATOR(0x1C)
#define S3C_ROTATOR_DESTADDRREG2		S3C_ROTATOR(0x20)
#define S3C_ROTATOR_STATCFG			    S3C_ROTATOR(0x2C)

#endif /* __ASM_ARCH_REGS_ROTATOR_H */

