#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <sys/time.h>

//#include <stb_debug.h>

#include "i2c-dev.h"

#include "msp430lib.h"

#define DEBUG_MESSAGE printf

#define I2C_DEVICE   "/dev/i2c/0"
#define I2C_DEVICE1   "/dev/i2c/1"
#define I2C_DEV_ADDR 0x23

static int msp430lib_fd = -1;
static struct timeval time_old;

static int get_ir_val(int *val)
{
    __u8 buf[4]; int rc,tmp_errno;

    buf[0] = 2;
    buf[1] = 3;

    errno = 0;
    rc = write(msp430lib_fd, buf, 2);
    tmp_errno = errno;
    if( rc  != 2 )
    {
        DEBUG_MESSAGE("Failed to write get IR value command to device [%s](rc=%d)\n",
                      strerror(errno),rc);
        return MSP430LIB_FAILURE;
    };

    usleep(100);

    if( read(msp430lib_fd, buf, 4) != 4 )
    {
        DEBUG_MESSAGE("Failed to read RTC data\n");
        return MSP430LIB_FAILURE;
    }

#if 0
    if( buf[0] != 4 || buf[1] != 3 )
    {
        DEBUG_MESSAGE("Failed to read IR ACK from device [%d %d]\n", buf[0], buf[1]);
        return MSP430LIB_FAILURE;
    }
#endif

    *val = buf[2] | (buf[3] << 8);

    return MSP430LIB_SUCCESS;
}


int msp430lib_get_rtc(int *year, int *month, int *day, int *hour,
                      int *minute, int *second)
{
    __u8 buf[9];

    if( msp430lib_fd == -1 )
    {
        DEBUG_MESSAGE("Library not initialized\n");
        return MSP430LIB_FAILURE;
    }

    buf[0] = 0x2;
    buf[1] = 0x1;

    if( write(msp430lib_fd, buf, 2) != 2 )
    {
        DEBUG_MESSAGE("Failed to write get RTC command to device [%s]\n",
                      strerror(errno));
        return MSP430LIB_FAILURE;
    }

    usleep(100);

    if( read(msp430lib_fd, buf, 9) != 9 )
    {
        DEBUG_MESSAGE("Failed to read RTC data [%s]\n", strerror(errno));
        return MSP430LIB_FAILURE;
    }

    if( buf[0] != 9 || buf[1] != 1 )
    {
        DEBUG_MESSAGE("get_rtc - Failed to read RTC ACK from device [got %#x%#x]\n",
                      buf[0], buf[1]);
        return MSP430LIB_FAILURE;
    }

    *year   =  buf[2] | (buf[3] << 8);
    *month  = buf[4];
    *day    = buf[5];
    *hour   = buf[6];
    *minute = buf[7];
    *second = buf[8];

    usleep(100);

    return MSP430LIB_SUCCESS;
}

int msp430lib_set_rtc(int year, int month, int day, int hour,
                      int minute, int second)
{
    __u8 buf[9];

    if( msp430lib_fd == -1 )
    {
        DEBUG_MESSAGE("Library not initialized\n");
        return MSP430LIB_FAILURE;
    }

    buf[0] = 0x9;
    buf[1] = 0;
    buf[2] = year & 0xff;
    buf[3] = year >> 8;
    buf[4] = month;
    buf[5] = day;
    buf[6] = hour;
    buf[7] = minute;
    buf[8] = second;

    if( write(msp430lib_fd, buf, 9) != 9 )
    {
        DEBUG_MESSAGE("Failed to write set RTC command to device [%s]\n",
                      strerror(errno));
        return MSP430LIB_FAILURE;
    }

    usleep(100);

    return MSP430LIB_SUCCESS;
}


int msp430lib_get_ir_key( int *key, enum toggle_switcher_t t )  //enum msp430lib_keycode
{
    int val; 
    //    int rc, tmp_errno;
    //struct timeval time_new;

    if( msp430lib_fd == -1 )
    {
        DEBUG_MESSAGE("Library not initialized\n");
        return MSP430LIB_FAILURE;
    };

    if( get_ir_val(&val) == MSP430LIB_FAILURE )
    {
        return MSP430LIB_FAILURE;
    }
    else
    {
        //val &= 0xfff;//clear START bits
        rc5_clear_startbits(val);
        if(t == MSP430LIB_WITHOUT_TOGGLE)
        {//clear toggle bit
          //val &= ~(1<<11);
          rc5_clear_togglebit(val);
        };
        *key   = val;
    };

/*
    if( oldval == -1 )
    {
        if( get_ir_val(&oldval) == MSP430LIB_FAILURE )
        {
            return MSP430LIB_FAILURE;
        }
        else
        {
            errno = 0;
            rc = gettimeofday(&time_old, NULL);
            tmp_errno = errno;
            if( rc )
            {
                DEBUG_MESSAGE("gettimeofday: err: %s\n",strerror(tmp_errno));
            };
        };
    }
    else
    {

        if( get_ir_val(&val) == MSP430LIB_FAILURE )
        {
            return MSP430LIB_FAILURE;
        }
        else
        {
            //val &= ~(1<<11); //clear toggle bit
        };

        memset(&time_new,0,sizeof(time_new));
        errno = 0;
        rc = gettimeofday(&time_new, NULL);
        tmp_errno = errno;
        if( rc )
        {
            DEBUG_MESSAGE("gettimeofday: err: %s\n",strerror(tmp_errno));
        };

        *key   = val;

        if( val != oldval )
        {
          //  *key   = val & ~(1<<11); //clear toggle bit
            *key   = val;
            oldval = val;
        }
        else
        {//filtering it
            *key = 0;
        };  
    };
*/
    //usleep(100);

    return MSP430LIB_SUCCESS;
}

int msp430lib_init(void)
{
    int tmp_errno;

    if( msp430lib_fd != -1 )
    {
        DEBUG_MESSAGE("Library already initialized\n");
        return MSP430LIB_FAILURE;
    };

    errno = 0;
    msp430lib_fd = open(I2C_DEVICE, O_RDWR);
    tmp_errno = errno;
    DEBUG_MESSAGE("opening i2c device %s: %s fd=%d\n", 
                  I2C_DEVICE, strerror(tmp_errno),msp430lib_fd);
    if( msp430lib_fd < 0 )
    {
	msp430lib_fd = open(I2C_DEVICE1, O_RDWR);
	tmp_errno = errno;
	DEBUG_MESSAGE("opening i2c device %s: %s fd=%d\n", 
            	    I2C_DEVICE1, strerror(tmp_errno),msp430lib_fd);
    }

    if( msp430lib_fd < 0 )
    {
        //  DEBUG_MESSAGE("Error while opening i2c device %s\n", I2C_DEVICE);
        return MSP430LIB_FAILURE;
    };

    if( ioctl(msp430lib_fd, I2C_SLAVE, I2C_DEV_ADDR) == -1 )
    {
        DEBUG_MESSAGE("Failed to set I2C_SLAVE to %#x\n", I2C_DEV_ADDR);
        return MSP430LIB_FAILURE;
    };

    memset(&time_old,0,sizeof(time_old));
/*
    if( get_ir_val(&oldval) == MSP430LIB_FAILURE )
    {
        return MSP430LIB_FAILURE;
    };
  */
    return MSP430LIB_SUCCESS;
}

int msp430lib_exit(void)
{
    if( msp430lib_fd == -1 )
    {
        DEBUG_MESSAGE("Library not initialized\n");
        return MSP430LIB_FAILURE;
    }

    if( close(msp430lib_fd) == -1 )
    {
        DEBUG_MESSAGE("Failed to close i2c device %s\n", I2C_DEVICE);
        return MSP430LIB_FAILURE;
    }

    msp430lib_fd = -1; 

    return MSP430LIB_SUCCESS;
}

