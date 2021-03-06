/****************************************************************************

**

** COPYRIGHT(C) : Samsung Electronics Co.Ltd, 2006-2010 ALL RIGHTS RESERVED

**

****************************************************************************/

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/types.h>
#include <linux/errno.h>
#include <linux/delay.h>
#include <linux/poll.h>
#include <linux/miscdevice.h>
#include <linux/slab.h>
#include <linux/netdevice.h>
#include <linux/etherdevice.h>
#include <linux/random.h>
#include <linux/if_arp.h>
#include <linux/proc_fs.h>
#include <linux/freezer.h>
#include <linux/tty.h>
#include <linux/tty_driver.h>
#include <linux/tty_flip.h>
#include <linux/poll.h>
#include <linux/workqueue.h>

/* Multiple PDP */
typedef struct pdp_arg {
	unsigned char	id;
	char		ifname[16];
} __attribute__ ((packed)) pdp_arg_t;

#if 0
#define IOC_MZ2_MAGIC		('h')
#define HN_PDP_ACTIVATE		_IOWR(IOC_MZ2_MAGIC, 0xf6, pdp_arg_t)
#define HN_PDP_DEACTIVATE	_IOW (IOC_MZ2_MAGIC, 0xf7, pdp_arg_t)
#define HN_PDP_ADJUST		_IOW (IOC_MZ2_MAGIC, 0xe2, int)
#else
#define IOC_MZ2_MAGIC		(0xC1)
#define HN_PDP_ACTIVATE		_IOWR(IOC_MZ2_MAGIC, 0xe0, pdp_arg_t)
#define HN_PDP_DEACTIVATE	_IOW(IOC_MZ2_MAGIC, 0xe1, pdp_arg_t)
#define HN_PDP_ADJUST		_IOW(IOC_MZ2_MAGIC, 0xe2, int)
#define HN_PDP_TXSTART		_IO(IOC_MZ2_MAGIC, 0xe3)
#define HN_PDP_TXSTOP		_IO(IOC_MZ2_MAGIC, 0xe4)
#endif

//#include <asm/hardware.h>
//#include <asm/uaccess.h>
#include <mach/hardware.h>
#include <linux/uaccess.h>

/*
 * Driver macros
 */

#define MULTIPDP_ERROR			/* Define this for error messages */
#undef USE_LOOPBACK_PING		/* Use loopback ping test */

#ifdef USE_LOOPBACK_PING
#include <linux/ip.h>
#include <linux/icmp.h>
#include <net/checksum.h>
#endif

#ifdef MULTIPDP_ERROR
#define EPRINTK(X...) \
		do { \
			printk("%s(): ", __FUNCTION__); \
			printk(X); \
		} while (0)
#else
#define EPRINTK(X...)		do { } while (0)
#endif

#define CONFIG_MULTIPDP_DEBUG 0

#if (CONFIG_MULTIPDP_DEBUG > 0)
#define DPRINTK(N, X...) \
		do { \
			if (N <= CONFIG_MULTIPDP_DEBUG) { \
				printk("%s(): ", __FUNCTION__); \
				printk(X); \
			} \
		} while (0)
#else
#define DPRINTK(N, X...)	do { } while (0)
#endif

/* Maximum number of PDP context */
#define MAX_PDP_CONTEXT			10

/* Maximum PDP data length */
#define MAX_PDP_DATA_LEN		1500

/* Maximum PDP packet length including header and start/stop bytes */
#define MAX_PDP_PACKET_LEN		(MAX_PDP_DATA_LEN + 4 + 2)

/* Prefix string of virtual network interface */
#define VNET_PREFIX				"pdp"

/* Device node name for application interface */
#define APP_DEVNAME				"multipdp"

/* DPRAM device node name */
#define DPRAM_DEVNAME			"/dev/dpram1"

/* Device types */
#define DEV_TYPE_NET			0 /* network device for IP data */
#define DEV_TYPE_SERIAL			1 /* serial device for CSD */

/* Device flags */
#define DEV_FLAG_STICKY			0x1 /* Sticky */

/* Device major & minor number */
#define CSD_MAJOR_NUM			251
#define CSD_MINOR_NUM			0

/*
 * Variable types
 */

/* PDP data packet header format */
struct pdp_hdr {
	u16	len;		/* Data length */
	u8	id;			/* Channel ID */
	u8	control;	/* Control field */
} __attribute__ ((packed));

/* PDP information type */
struct pdp_info {
	/* PDP context ID */
	u8		id;

	/* Device type */
	unsigned		type;

	/* Device flags */
	unsigned		flags;

	/* Tx packet buffer */
	u8		*tx_buf;

	/* App device interface */
	union {
		/* Virtual network interface */
		struct {
			struct net_device	*net;
			struct net_device_stats	stats;
			struct work_struct	xmit_task;
		} vnet_u;

		/* Virtual serial interface */
		struct {
			struct tty_driver	tty_driver[4];	// CSD, ROUTER, GPS, XGPS
			int			refcount;
			struct tty_struct	*tty_table[1];
			struct ktermios		*termios[1];
			struct ktermios		*termios_locked[1];
			char			tty_name[16];
			struct tty_struct	*tty;
			struct semaphore	write_lock;
		} vs_u;
	} dev_u;
#define vn_dev		dev_u.vnet_u
#define vs_dev		dev_u.vs_u
};

/*
 * Global variables
 */

/* PDP information table */
static struct pdp_info *pdp_table[MAX_PDP_CONTEXT];
static DEFINE_MUTEX(pdp_lock);
//static DECLARE_MUTEX(pdp_lock);
static DEFINE_MUTEX(pdp_demux_mutex);

/* DPRAM-related stuffs */
static struct task_struct *dpram_task;
static struct file *dpram_filp;
static DECLARE_COMPLETION(dpram_complete);

static int g_adjust = 9;
static unsigned long workqueue_data = 0;
static unsigned char pdp_rx_buf[MAX_PDP_DATA_LEN];

static int pdp_tx_flag = 0;
/*
 * Function declarations
 */
static int pdp_mux(struct pdp_info *dev, const void *data, size_t len);
static int pdp_demux(void);
static inline struct pdp_info * pdp_get_serdev(const char *name);

/*
 * DPRAM I/O functions
 */
static inline struct file *dpram_open(void)
{
	int ret;
	struct file *filp;
	struct termios termios;
	mm_segment_t oldfs;

	filp = filp_open(DPRAM_DEVNAME, O_RDWR|O_NONBLOCK, 0);
	if (IS_ERR(filp)) {
		DPRINTK(1, "filp_open() failed~!: %ld\n", PTR_ERR(filp));
		return NULL;
	}

#if 1	// hobac.
	oldfs = get_fs(); set_fs(get_ds());

	ret = filp->f_op->unlocked_ioctl(filp, 
				TCGETA, (unsigned long)&termios);
	set_fs(oldfs);
	if (ret < 0) {
		DPRINTK(1, "f_op->ioctl() failed: %d\n", ret);
		filp_close(filp, current->files);
		return NULL;
	}

	termios.c_cflag = CS8 | CREAD | HUPCL | CLOCAL | B115200;
	termios.c_iflag = IGNBRK | IGNPAR;
	termios.c_lflag = 0;
	termios.c_oflag = 0;
	termios.c_cc[VMIN] = 1;
	termios.c_cc[VTIME] = 1;

	oldfs = get_fs(); set_fs(get_ds());
	ret = filp->f_op->unlocked_ioctl(filp, 
				TCSETA, (unsigned long)&termios);
	set_fs(oldfs);
	if (ret < 0) {
		DPRINTK(1, "f_op->ioctl() failed: %d\n", ret);
		filp_close(filp, current->files);
		return NULL;
	}
#endif
	return filp;
}

static inline void dpram_close(struct file *filp)
{
	filp_close(filp, current->files);
}

static inline int dpram_poll(struct file *filp)
{
	int ret;
	unsigned int mask;
	struct poll_wqueues wait_table;
	//poll_table wait_table;
	mm_segment_t oldfs;

	poll_initwait(&wait_table);
	for (;;) {
		set_current_state(TASK_INTERRUPTIBLE);

		oldfs = get_fs(); set_fs(get_ds());
		mask = filp->f_op->poll(filp, &wait_table.pt);
		set_fs(oldfs);

		if (mask & POLLIN) {
			/* got data */
			ret = 0;
			break;
		}

		if (wait_table.error) {
			DPRINTK(1, "error in f_op->poll()\n");
			ret = wait_table.error;
			break;
		}

		if (signal_pending(current)) {
			/* got signal */
			ret = -ERESTARTSYS;
			break;
		}

		schedule();
	}
	set_current_state(TASK_RUNNING);
	poll_freewait(&wait_table);

	return ret;
}

static inline int dpram_write(struct file *filp, const void *buf, size_t count,
			      int nonblock)
{
	int ret, n = 0;
	mm_segment_t oldfs;

	if(pdp_tx_flag) {
		printk("IN USE\n");
		return -EAGAIN;
	}

	while (count) {
		if (!dpram_filp) {
			DPRINTK(1, "DPRAM not available\n");
			return -ENODEV;
		}

        dpram_filp->f_flags |= O_NONBLOCK;
		oldfs = get_fs(); set_fs(get_ds());
		ret = filp->f_op->write(filp, buf + n, count, &filp->f_pos);
		set_fs(oldfs);
        dpram_filp->f_flags &= ~O_NONBLOCK;
		if (ret < 0) {
#if 0            
			if (ret == -EAGAIN && !nonblock) {
				continue;
			}
			DPRINTK(1, "f_op->write() failed: %d\n", ret);
			return ret;
#else 
            if (ret == -EAGAIN){
                continue;
            }
            DPRINTK(1, "f_op->write() failed: %d\n", ret);
			return ret;
#endif 
		}
		n += ret;
		count -= ret;
	}
	return n;
}

static inline int dpram_read(struct file *filp, void *buf, size_t count)
{
	int ret, n = 0;
	mm_segment_t oldfs;

	while (count) {
        dpram_filp->f_flags |= O_NONBLOCK;
		oldfs = get_fs(); set_fs(get_ds());
		ret = filp->f_op->read(filp, buf + n, count, &filp->f_pos);
		set_fs(oldfs);
        dpram_filp->f_flags &= ~O_NONBLOCK;
		if (ret < 0) {
			if (ret == -EAGAIN) {
				continue;
			}
			DPRINTK(1, "f_op->read() failed: %d\n", ret);
			return ret;
		}
		n += ret;
		count -= ret;
//		printk("[%s] ret: %d, count: %d n: %d\n", __func__, ret, count, n);
	}
	return n;
}

static inline int dpram_flush_rx(struct file *filp, size_t count)
{
	int ret, n = 0;
	char *buf;
	mm_segment_t oldfs;

	buf = kmalloc(count, GFP_KERNEL);
	if (buf == NULL) return -ENOMEM;

	while (count) {
        dpram_filp->f_flags |= O_NONBLOCK;
		oldfs = get_fs(); set_fs(get_ds());
		ret = filp->f_op->read(filp, buf + n, count, &filp->f_pos);
		set_fs(oldfs);
        dpram_filp->f_flags &= ~O_NONBLOCK;
		if (ret < 0) {
			if (ret == -EAGAIN) continue;
			DPRINTK(1, "f_op->read() failed: %d\n", ret);
			kfree(buf);
			return ret;
		}
		n += ret;
		count -= ret;
	}
	kfree(buf);
	return n;
}


static int dpram_thread(void *data)
{
	int ret = 0;
	unsigned long flag;
	struct file *filp;
    struct sched_param schedpar;

	dpram_task = current;

	daemonize("dpram_thread");
	strcpy(current->comm, "multipdp");

#if 0 
	/* set signals to accept */
	//spin_lock_irqsave(&current->sigmask_lock, flags); // for 2.6 kernel proting
	siginitsetinv(&current->blocked, sigmask(SIGUSR1));
	//recalc_sigpending(current);
	recalc_sigpending();
	//spin_unlock_irqrestore(&current->sigmask_lock, flags); // for 2.6 kernel proting
#endif 
    schedpar.sched_priority = 1;
    sched_setscheduler(current, SCHED_FIFO, &schedpar);

	/* set signals to accept */
    siginitsetinv(&current->blocked, sigmask(SIGUSR1));
    recalc_sigpending();


	filp = dpram_open();
	if (filp == NULL) {
		goto out;
	}
	dpram_filp = filp;

	/* send start signal */
	complete(&dpram_complete);

	while (1) {
		ret = dpram_poll(filp);

		if (ret == -ERESTARTSYS) {
			if (sigismember(&current->pending.signal, SIGUSR1)) {
				sigdelset(&current->pending.signal, SIGUSR1);
				recalc_sigpending();
				ret = 0;
				break;
			}
		}
		
		else if (ret < 0) {
			EPRINTK("dpram_poll() failed\n");
			break;
		}
		
		else {
			char ch;
			ret = dpram_read(dpram_filp, &ch, sizeof(ch));

			if(ret < 0) {
				return ret;
			}

			if (ch == 0x7f) {
				pdp_demux();
			}
		}

		// try_to_freeze();
	}

	dpram_close(filp);
	dpram_filp = NULL;

out:
	dpram_task = NULL;

	/* send finish signal and exit */
	complete_and_exit(&dpram_complete, ret);
}

/*
 * Virtual Network Interface functions
 */

static int vnet_open(struct net_device *net)
{
	struct pdp_info *dev = (struct pdp_info *)net->priv;
	INIT_WORK(&dev->vn_dev.xmit_task, NULL);
	netif_start_queue(net);

	return 0;
}

static int vnet_stop(struct net_device *net)
{
	struct pdp_info *dev = (struct pdp_info *)net->priv;
	netif_stop_queue(net);
	//flush_scheduled_work(); /* flush any pending tx tasks */
	cancel_work_sync(&dev->vn_dev.xmit_task);

	return 0;
}

static void vnet_defer_xmit(struct work_struct *data)
{
	struct sk_buff *skb = (struct sk_buff *)workqueue_data;
	struct net_device *net = (struct net_device *)skb->dev;
	struct pdp_info *dev = (struct pdp_info *)net->priv;

	int ret = 0;

	ret = pdp_mux(dev, skb->data, skb->len);

	if (ret < 0) {
		dev->vn_dev.stats.tx_dropped++;
	}
	
	else {
		net->trans_start = jiffies;
		dev->vn_dev.stats.tx_bytes += skb->len;
		dev->vn_dev.stats.tx_packets++;
	}

	dev_kfree_skb_any(skb);
	netif_wake_queue(net);
}

static int vnet_start_xmit(struct sk_buff *skb, struct net_device *net)
{
	struct pdp_info *dev = (struct pdp_info *)net->priv;

#ifdef USE_LOOPBACK_PING
	int ret;
	struct sk_buff *skb2;
	struct icmphdr *icmph;
	struct iphdr *iph;
#endif

#ifdef USE_LOOPBACK_PING
	dev->vn_dev.stats.tx_bytes += skb->len;
	dev->vn_dev.stats.tx_packets++;

	skb2 = alloc_skb(skb->len, GFP_ATOMIC);
	if (skb2 == NULL) {
		DPRINTK(1, "alloc_skb() failed\n");
		dev_kfree_skb_any(skb);
		return -ENOMEM;
	}

	memcpy(skb2->data, skb->data, skb->len);
	skb_put(skb2, skb->len);
	dev_kfree_skb_any(skb);

	icmph = (struct icmphdr *)(skb2->data + sizeof(struct iphdr));
	iph = (struct iphdr *)skb2->data;

	icmph->type = __constant_htons(ICMP_ECHOREPLY);

	ret = iph->daddr;
	iph->daddr = iph->saddr;
	iph->saddr = ret;
	iph->check = 0;
	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);

	skb2->dev = net;
	skb2->protocol = __constant_htons(ETH_P_IP);

	netif_rx(skb2);

	dev->vn_dev.stats.rx_packets++;
	dev->vn_dev.stats.rx_bytes += skb->len;
#else
	workqueue_data = (unsigned long)skb;
	PREPARE_WORK(&dev->vn_dev.xmit_task,vnet_defer_xmit);
	schedule_work(&dev->vn_dev.xmit_task);
	netif_stop_queue(net);
#endif

	return 0;
}

static int vnet_recv(struct pdp_info *dev, size_t len)
{
	struct sk_buff *skb;
	int ret;

	/* @LDK@ for multiple pdp.. , ex) email & streaming.. by hobac. */
	if (!dev) {
		return 0;
	}

	if (!netif_running(dev->vn_dev.net)) {
		DPRINTK(1, "%s(id: %u) is not running\n", 
			dev->vn_dev.net->name, dev->id);
		return -ENODEV;
	}

#if 0
	skb = alloc_skb(len, GFP_ATOMIC);
#else
	skb = alloc_skb(len, GFP_KERNEL);
#endif

	if (skb == NULL) {
		DPRINTK(1, "alloc_skb() failed\n");
		return -ENOMEM;
	}
	ret = dpram_read(dpram_filp, skb->data, len);

	if (ret < 0) {
		DPRINTK(1, "dpram_read() failed: %d\n", ret);
		dev_kfree_skb_any(skb);
		return ret;
	}

	skb_put(skb, ret);

	skb->dev = dev->vn_dev.net;
	skb->protocol = __constant_htons(ETH_P_IP);

	netif_rx(skb);

	dev->vn_dev.stats.rx_packets++;
	dev->vn_dev.stats.rx_bytes += skb->len;
	return 0;
}

static struct net_device_stats *vnet_get_stats(struct net_device *net)
{
	struct pdp_info *dev = (struct pdp_info *)net->priv;
	return &dev->vn_dev.stats;
}

static void vnet_tx_timeout(struct net_device *net)
{
	struct pdp_info *dev = (struct pdp_info *)net->priv;

	net->trans_start = jiffies;
	dev->vn_dev.stats.tx_errors++;
	netif_wake_queue(net);
}

static void vnet_setup(struct net_device *dev)
{
	dev->open		= vnet_open;
	dev->stop		= vnet_stop;
	dev->hard_start_xmit	= vnet_start_xmit;
	dev->get_stats		= vnet_get_stats;
	dev->tx_timeout		= vnet_tx_timeout;
	dev->type		= ARPHRD_PPP;
	dev->hard_header_len 	= 0;
	dev->mtu		= MAX_PDP_DATA_LEN;
	dev->addr_len		= 0;
	dev->tx_queue_len	= 1000;
	dev->flags		= IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
	dev->watchdog_timeo	= 40 * HZ;
}


static struct net_device *vnet_add_dev(void *priv)
{
	int ret;
	struct net_device *dev;
	dev = alloc_netdev(0, "pdp%d", vnet_setup);
	if (dev == NULL) {
		DPRINTK(1, "out of memory\n");
		return NULL;
	}
	dev->priv		= priv;

	ret = register_netdev(dev);

	if (ret != 0) {
		DPRINTK(1, "register_netdevice failed: %d\n", ret);
		kfree(dev);
		return NULL;
	}
	return dev;
}
#if 0
static struct net_device *vnet_add_dev(void *priv)
{
	int ret;
	struct net_device *net;

	net = kmalloc(sizeof(*net), GFP_KERNEL);

	if (net == NULL) {
		DPRINTK(1, "out of memory\n");
		return NULL;
	}

	memset(net, 0, sizeof(*net));

//	SET_MODULE_OWNER(net);
	strcpy(net->name, VNET_PREFIX "%d");
	net->open		= vnet_open;
	net->stop		= vnet_stop;
	net->hard_start_xmit	= vnet_start_xmit;
	net->get_stats		= vnet_get_stats;
	net->tx_timeout		= vnet_tx_timeout;
	net->type		= ARPHRD_PPP;
	net->hard_header_len 	= 0;
	net->mtu		= MAX_PDP_DATA_LEN;
	net->addr_len		= 0;
	net->tx_queue_len	= 1000;
	net->flags		= IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
	net->watchdog_timeo	= 5 * HZ;
	net->priv		= priv;

	ret = register_netdev(net);

	if (ret != 0) {
		DPRINTK(1, "register_netdevice failed: %d\n", ret);
		kfree(net);
		return NULL;
	}

	return net;
}
#endif
static void vnet_del_dev(struct net_device *net)
{
	unregister_netdev(net);
	kfree(net);
}

/*
 * Virtual Serial Interface functions
 */

static int vs_open(struct tty_struct *tty, struct file *filp)
{
	struct pdp_info *dev;

	dev = pdp_get_serdev(tty->driver->name); // 2.6 kernel porting

	if (dev == NULL) {
		return -ENODEV;
	}

	tty->driver_data = (void *)dev;
	tty->low_latency = 1;
	dev->vs_dev.tty = tty;

	return 0;
}

static void vs_close(struct tty_struct *tty, struct file *filp)
{
	// TODO..
}


static int vs_write(struct tty_struct *tty,
		const unsigned char *buf, int count)
{
	int ret;
	unsigned long flag;
	//struct pdp_info *dev = (struct pdp_info *)tty->driver_data;

    struct pdp_info *dev;
	//local_irq_save(flag);
	mutex_lock(&pdp_lock);

    dev = (struct pdp_info *)tty->driver_data; 
    
    ret = pdp_mux(dev, buf, count);

	if (ret == 0) {
		ret = count;
	}
    mutex_unlock(&pdp_lock);
	//local_irq_restore(flag);
	
	return ret;
}

static int vs_write_room(struct tty_struct *tty) 
{
//	return TTY_FLIPBUF_SIZE;
	return 8192*2;
}

static int vs_chars_in_buffer(struct tty_struct *tty) 
{
	return 0;
}

static int vs_read(struct pdp_info *dev, size_t len)
{
	int retval = 0;
    u32 size;
    u32 copied_size;
    int insert_size = 0;

	if (!dev) {
		return 0;
	}

		if (len > MAX_PDP_DATA_LEN) {	// RF cal data?
		unsigned char *prx_buf = kzalloc(len, GFP_ATOMIC);

		if(prx_buf == NULL)
			return 0;

            size = dpram_read(dpram_filp, prx_buf, len);
            printk("[CAL] multipdp_thread request read size : %d readed size %d \n",len ,size);

		if (size != len) {
            printk("ERROR!! MEMORY LEAK OCCUR \n");
            kfree(prx_buf); 
            return retval;
        }

		printk("RF cal data read. len: %d retval: %d\n", len, retval);

        while (size) {
        			copied_size = (size > MAX_PDP_DATA_LEN) ? MAX_PDP_DATA_LEN : size;
        	if (size > 0 && dev->vs_dev.tty != NULL) 
        		insert_size = tty_insert_flip_string(dev->vs_dev.tty, prx_buf+retval, copied_size);
            if (insert_size != copied_size) {
                printk("[ONEDRAM] flip buffer full : %s, insert size : %d, real size : %d\n",dev->vs_dev.tty->name,copied_size,insert_size);
                return -1; 
            }
        	size = size - copied_size;
        	retval += copied_size;
    	}
		
        printk("[CAL]retval : %d\n",retval);

		tty_flip_buffer_push(dev->vs_dev.tty);

		kfree(prx_buf);
	}
	else {
		
	    retval = dpram_read(dpram_filp, pdp_rx_buf, len);

		if (retval != len)
			return retval;

        if(retval > 0 && dev->vs_dev.tty != NULL){
    		insert_size = tty_insert_flip_string(dev->vs_dev.tty, pdp_rx_buf, retval);
            if (insert_size != retval) {
                printk("[MULTIPDP] flip buffer full : %s, insert size : %d, real size : %d\n",dev->vs_dev.tty->name,retval,insert_size);
                return -1; 
            }
    		tty_flip_buffer_push(dev->vs_dev.tty);
        }    
	}
	return 0;
}

static int vs_ioctl(struct tty_struct *tty, struct file *file, 
		    unsigned int cmd, unsigned long arg)
{
	return -ENOIOCTLCMD;
}

static void vs_break_ctl(struct tty_struct *tty, int break_state)
{
}

static struct tty_operations multipdp_tty_ops = {
	.open 		= vs_open,
	.close 		= vs_close,
	.write 		= vs_write,
	.write_room = vs_write_room,
	.ioctl 		= vs_ioctl,
	.chars_in_buffer = vs_chars_in_buffer,
//	.break_ctl	= vs_break_ctl,

	/* TODO: add more operations */
};

static int vs_add_dev(struct pdp_info *dev)
{
	struct tty_driver *tty_driver;

	switch (dev->id) {
		case 1:
			tty_driver = &dev->vs_dev.tty_driver[0];
			tty_driver->minor_start = CSD_MINOR_NUM;
			break;

		case 8:
			tty_driver = &dev->vs_dev.tty_driver[1];
			tty_driver->minor_start = 1;
			break;

		case 5:
			tty_driver = &dev->vs_dev.tty_driver[2];
			tty_driver->minor_start = 2;
			break;

		case 6:
			tty_driver = &dev->vs_dev.tty_driver[3];
			tty_driver->minor_start = 3;
			break;

		default:
			tty_driver = NULL;
	}

	if (!tty_driver) {
		printk("tty driver is NULL!\n");
		return -1;
	}

	#if 0 //hobac.
	kref_init(&tty_driver->kref);
	#endif

	tty_driver->magic	= TTY_DRIVER_MAGIC;
	tty_driver->driver_name	= "multipdp";
	tty_driver->name	= dev->vs_dev.tty_name;
	tty_driver->major	= CSD_MAJOR_NUM;
//	tty_driver->minor_start = CSD_MINOR_NUM;
	tty_driver->num		= 1;
	tty_driver->type	= TTY_DRIVER_TYPE_SERIAL;
	tty_driver->subtype	= SERIAL_TYPE_NORMAL;
	tty_driver->flags	= TTY_DRIVER_REAL_RAW;
	tty_driver->refcount	= dev->vs_dev.refcount;
	tty_driver->ttys	= dev->vs_dev.tty_table; // 2.6 kernel porting
	tty_driver->termios	= dev->vs_dev.termios;
	tty_driver->termios_locked	= dev->vs_dev.termios_locked;
#if 0
	tty_driver->init_termios.c_cflag = CS8 | CREAD | HUPCL | CLOCAL | B115200;
	tty_driver->init_termios.c_iflag = IGNBRK | IGNPAR;
	tty_driver->init_termios.c_lflag = 0;
	tty_driver->init_termios.c_oflag = 0;
	tty_driver->init_termios.c_cc[VMIN] = 1;
	tty_driver->init_termios.c_cc[VTIME] = 1;
#endif
//	tty_driver->init_termios = tty_std_termios;

	tty_set_operations(tty_driver, &multipdp_tty_ops);
	return tty_register_driver(tty_driver);
}

static void vs_del_dev(struct pdp_info *dev)
{
	struct tty_driver *tty_driver = NULL;

	switch (dev->id) {
		case 1:
			tty_driver = &dev->vs_dev.tty_driver[0];
			break;

		case 8:
			tty_driver = &dev->vs_dev.tty_driver[1];
			break;
			
		case 5:
			tty_driver = &dev->vs_dev.tty_driver[2];
			break;

		case 6:
			tty_driver = &dev->vs_dev.tty_driver[3];
			break;


	}

	tty_unregister_driver(tty_driver);
}

/*
 * PDP context and mux/demux functions
 */

static inline struct pdp_info * pdp_get_dev(u8 id)
{
	int slot;

	for (slot = 0; slot < MAX_PDP_CONTEXT; slot++) {
		if (pdp_table[slot] && pdp_table[slot]->id == id) {
			return pdp_table[slot];
		}
	}
	return NULL;
}

static inline struct pdp_info * pdp_get_serdev(const char *name)
{
	int slot;
	struct pdp_info *dev;

	for (slot = 0; slot < MAX_PDP_CONTEXT; slot++) {
		dev = pdp_table[slot];
		if (dev && dev->type == DEV_TYPE_SERIAL &&
		    strcmp(name, dev->vs_dev.tty_name) == 0) {
			return dev;
		}
	}
	return NULL;
}

static inline int pdp_add_dev(struct pdp_info *dev)
{
	int slot;

	if (pdp_get_dev(dev->id)) {
        printk("[MULTIPDP] pdp_add_dev() Error ..%d already exist \n",dev->id);
		return -EBUSY;
	}

	for (slot = 0; slot < MAX_PDP_CONTEXT; slot++) {
		if (pdp_table[slot] == NULL) {
			pdp_table[slot] = dev;
			return slot;
		}
	}
    printk("[MULTIPDP] pdp_add_dev() Error ..%d There is no space to make %d \n",dev->id);
	return -ENOSPC;
}

static inline struct pdp_info * pdp_remove_dev(u8 id)
{
	int slot;
	struct pdp_info *dev;

	for (slot = 0; slot < MAX_PDP_CONTEXT; slot++) {
		if (pdp_table[slot] && pdp_table[slot]->id == id) {
			dev = pdp_table[slot];
			pdp_table[slot] = NULL;
			return dev;
		}
	}
	return NULL;
}

static inline struct pdp_info * pdp_remove_slot(int slot)
{
	struct pdp_info *dev;

	dev = pdp_table[slot];
	pdp_table[slot] = NULL;
	return dev;
}

static int pdp_mux(struct pdp_info *dev, const void *data, size_t len   )
{
	int ret;
	size_t nbytes;
	u8 *tx_buf;
	struct pdp_hdr *hdr;
	const u8 *buf;

	tx_buf = dev->tx_buf;
	hdr = (struct pdp_hdr *)(tx_buf + 1);
	buf = data;

	hdr->id = dev->id;
	hdr->control = 0;

	while (len) {
		if (len > MAX_PDP_DATA_LEN) {
			nbytes = MAX_PDP_DATA_LEN;
		} else {
			nbytes = len;
		}
		hdr->len = nbytes + sizeof(struct pdp_hdr);

		tx_buf[0] = 0x7f;
		
		memcpy(tx_buf + 1 + sizeof(struct pdp_hdr), buf,  nbytes);
		
		tx_buf[1 + hdr->len] = 0x7e;

		DPRINTK(2, "hdr->id: %d, hdr->len: %d\n", hdr->id, hdr->len);

		ret = dpram_write(dpram_filp, tx_buf, hdr->len + 2, 
				  dev->type == DEV_TYPE_NET ? 1 : 0);
		if (ret < 0) {
			DPRINTK(1, "dpram_write() failed: %d\n", ret);
			return ret;
		}
		buf += nbytes;
		len -= nbytes;
	}

	return 0;
}

static int pdp_demux(void)
{
	int ret;
	u8 ch;
	size_t len;
	struct pdp_info *dev = NULL;
	struct pdp_hdr hdr;

    mutex_lock(&pdp_lock);
	/* read header */
	ret = dpram_read(dpram_filp, &hdr, sizeof(hdr));

	if (ret < 0) {
		return ret;
	}

	len = hdr.len - sizeof(struct pdp_hdr);

	/* check header */
	
	dev = pdp_get_dev(hdr.id);

	if (dev == NULL) {
		printk("invalid id: %u, there is no existing device.\n", hdr.id);
		ret = -ENODEV;
		goto err;
	}

	/* read data */
	switch (dev->type) {
		case DEV_TYPE_NET:
			ret = vnet_recv(dev, len);
			break;
		case DEV_TYPE_SERIAL:
			ret = vs_read(dev, len);
			break;
		default:
			ret = -1;
	}

	if (ret < 0) {
		goto err;
	}
	/* check stop byte */
	ret = dpram_read(dpram_filp, &ch, sizeof(ch));

	if (ret < 0 || ch != 0x7e) {
		return ret;
	}
    mutex_unlock(&pdp_lock);
    //printk("#### pdp demux terminated ..\n");
	return 0;
err:
	/* flush the remaining data including stop byte. */
	dpram_flush_rx(dpram_filp, len + 1);
    mutex_unlock(&pdp_lock);
	return ret;
}

static int pdp_activate(pdp_arg_t *pdp_arg, unsigned type, unsigned flags)
{
	int ret;
	struct pdp_info *dev;
	struct net_device *net;

	DPRINTK(1, "id: %d\n", pdp_arg->id);
	//DPRINTK(2, "id: %d\n", pdp_arg->id);

	dev = kmalloc(sizeof(struct pdp_info) + MAX_PDP_PACKET_LEN, GFP_KERNEL);
	if (dev == NULL) {
		DPRINTK(1, "out of memory\n");
		return -ENOMEM;
	}
	memset(dev, 0, sizeof(struct pdp_info));

	/* @LDK@ added by gykim on 20070203 for adjusting IPC 3.0 spec. */
	if (type == DEV_TYPE_NET) {
		dev->id = pdp_arg->id + g_adjust;
	}

	else {
		dev->id = pdp_arg->id;
	}
	/* @LDK@ added by gykim on 20070203 for adjusting IPC 3.0 spec. */

	dev->type = type;
	dev->flags = flags;
	dev->tx_buf = (u8 *)(dev + 1);

	if (type == DEV_TYPE_NET) {
		net = vnet_add_dev((void *)dev);
		if (net == NULL) {
			kfree(dev);
			return -ENOMEM;
		}

		dev->vn_dev.net = net;
		strcpy(pdp_arg->ifname, net->name);

		mutex_lock(&pdp_lock);
		ret = pdp_add_dev(dev);
		if (ret < 0) {
			DPRINTK(1, "pdp_add_dev() failed\n");
			mutex_unlock(&pdp_lock);
			vnet_del_dev(dev->vn_dev.net);
			kfree(dev);
			return ret;
		}
		mutex_unlock(&pdp_lock);

		DPRINTK(1, "%s(id: %u) network device created\n", 
			net->name, dev->id);
	} else if (type == DEV_TYPE_SERIAL) {
		init_MUTEX(&dev->vs_dev.write_lock);
		strcpy(dev->vs_dev.tty_name, pdp_arg->ifname);

		ret = vs_add_dev(dev);
		if (ret < 0) {
			kfree(dev);
			return ret;
		}

		mutex_lock(&pdp_lock);
		ret = pdp_add_dev(dev);
		if (ret < 0) {
			DPRINTK(1, "pdp_add_dev() failed\n");
			mutex_unlock(&pdp_lock);
			vs_del_dev(dev);
			kfree(dev);
			return ret;
		}
		mutex_unlock(&pdp_lock);

		if (dev->id == 1) {
			DPRINTK(1, "%s(id: %u) serial device is created.\n",
					dev->vs_dev.tty_driver[0].name, dev->id);
		}

		else if (dev->id == 8) {
			DPRINTK(1, "%s(id: %u) serial device is created.\n",
					dev->vs_dev.tty_driver[1].name, dev->id);
		}
	}

	return 0;
}

static int pdp_deactivate(pdp_arg_t *pdp_arg, int force)
{
	struct pdp_info *dev = NULL;

	DPRINTK(1, "id: %d\n", pdp_arg->id);

	mutex_lock(&pdp_lock);

	if (pdp_arg->id == 1) {
		DPRINTK(1, "Channel ID is 1, we will remove the network device (pdp) of channel ID: %d.\n",
				pdp_arg->id + g_adjust);
	}

	else {
		DPRINTK(1, "Channel ID: %d\n", pdp_arg->id);
	}

	pdp_arg->id = pdp_arg->id + g_adjust;
	//pdp_arg->id += PDP_ID_ADJUST;
	DPRINTK(1, "ID is adjusted, new ID: %d\n", pdp_arg->id);

	dev = pdp_get_dev(pdp_arg->id);

	if (dev == NULL) {
		DPRINTK(1, "not found id: %u\n", pdp_arg->id);
		mutex_unlock(&pdp_lock);
		return -EINVAL;
	}
	if (!force && dev->flags & DEV_FLAG_STICKY) {
		DPRINTK(1, "sticky id: %u\n", pdp_arg->id);
		mutex_unlock(&pdp_lock);
		return -EACCES;
	}

	pdp_remove_dev(pdp_arg->id);
	mutex_unlock(&pdp_lock);

	if (dev->type == DEV_TYPE_NET) {
		DPRINTK(1, "%s(id: %u) network device removed\n", 
			dev->vn_dev.net->name, dev->id);
		vnet_del_dev(dev->vn_dev.net);
	} else if (dev->type == DEV_TYPE_SERIAL) {
		if (dev->id == 1) {
			DPRINTK(1, "%s(id: %u) serial device removed\n",
					dev->vs_dev.tty_driver[0].name, dev->id);
		}

		else if (dev->id == 8) {
			DPRINTK(1, "%s(id: %u) serial device removed\n",
					dev->vs_dev.tty_driver[1].name, dev->id);
		}

		vs_del_dev(dev);
	}

	kfree(dev);

	return 0;
}

static void __exit pdp_cleanup(void)
{
	int slot;
	struct pdp_info *dev;

	mutex_lock(&pdp_lock);
	for (slot = 0; slot < MAX_PDP_CONTEXT; slot++) {
		dev = pdp_remove_slot(slot);
		if (dev) {
			if (dev->type == DEV_TYPE_NET) {
				DPRINTK(1, "%s(id: %u) network device removed\n", 
					dev->vn_dev.net->name, dev->id);
				vnet_del_dev(dev->vn_dev.net);
			} else if (dev->type == DEV_TYPE_SERIAL) {
				if (dev->id == 1) {
					DPRINTK(1, "%s(id: %u) serial device removed\n", 
							dev->vs_dev.tty_driver[0].name, dev->id);
				}

				else if (dev->id == 8) {
					DPRINTK(1, "%s(id: %u) serial device removed\n",
							dev->vs_dev.tty_driver[1].name, dev->id);
				}

				vs_del_dev(dev);
			}

			kfree(dev);
		}
	}
	mutex_unlock(&pdp_lock);
}

static int pdp_adjust(const int adjust)
{
	g_adjust = adjust;
	printk("adjusting value: %d\n", adjust);
	return 0;
}

/*
 * App. Interfece Device functions
 */

static int multipdp_ioctl(struct inode *inode, struct file *file, 
			      unsigned int cmd, unsigned long arg)
{
	int ret, adjust;
	pdp_arg_t pdp_arg;

	switch (cmd) {
	case HN_PDP_ACTIVATE:
		if (copy_from_user(&pdp_arg, (void *)arg, sizeof(pdp_arg)))
			return -EFAULT;
		ret = pdp_activate(&pdp_arg, DEV_TYPE_NET, 0);
		if (ret < 0) {
			return ret;
		}
		return copy_to_user((void *)arg, &pdp_arg, sizeof(pdp_arg));

	case HN_PDP_DEACTIVATE:
		if (copy_from_user(&pdp_arg, (void *)arg, sizeof(pdp_arg)))
			return -EFAULT;
		return pdp_deactivate(&pdp_arg, 0);

	case HN_PDP_ADJUST:
		if (copy_from_user(&adjust, (void *)arg, sizeof (int)))
			return -EFAULT;
		return pdp_adjust(adjust);
        
    case HN_PDP_TXSTART:
    	pdp_tx_flag = 0;
	    return 0;
			
	case HN_PDP_TXSTOP:
		pdp_tx_flag = 1;
		return 0;

	}

	return -EINVAL;
}

static struct file_operations multipdp_fops = {
	.owner =	THIS_MODULE,
	.ioctl =	multipdp_ioctl,
	.llseek =	no_llseek,
};

static struct miscdevice multipdp_dev = {
	.minor =	132, //MISC_DYNAMIC_MINOR,
	.name =		APP_DEVNAME,
	.fops =		&multipdp_fops,
};

/*
 * /proc fs interface
 */

#ifdef CONFIG_PROC_FS
static int multipdp_proc_read(char *page, char **start, off_t off,
			      int count, int *eof, void *data)
{

	char *p = page;
	int len;

	mutex_lock(&pdp_lock);

	p += sprintf(p, "modified multipdp driver on 20070205");
	for (len = 0; len < MAX_PDP_CONTEXT; len++) {
		struct pdp_info *dev = pdp_table[len];
		if (!dev) continue;

		p += sprintf(p,
			     "name: %s\t, id: %-3u, type: %-7s, flags: 0x%04x\n",
			     dev->type == DEV_TYPE_NET ? 
			     dev->vn_dev.net->name : dev->vs_dev.tty_name,
			     dev->id, 
			     dev->type == DEV_TYPE_NET ? "network" : "serial",
			     dev->flags);
	}
	mutex_unlock(&pdp_lock);

	len = (p - page) - off;
	if (len < 0)
		len = 0;

	*eof = (len <= count) ? 1 : 0;
	*start = page + off;

	return len;
}
#endif

/*
 * Module init/clanup functions
 */

static int __init multipdp_init(void)
{
	int ret;
	pdp_arg_t pdp_arg = { .id = 1, .ifname = "ttyCSD", };
	pdp_arg_t efs_arg = { .id = 8, .ifname = "ttyEFS", };
	pdp_arg_t gps_arg = { .id = 5, .ifname = "ttyGPS", };
	pdp_arg_t xtra_arg = { .id = 6, .ifname = "ttyXTRA", };


	/* run DPRAM I/O thread */
	ret = kernel_thread(dpram_thread, NULL, CLONE_FS | CLONE_FILES);
	if (ret < 0) {
		EPRINTK("kernel_thread() failed\n");
		return ret;
	}
	wait_for_completion(&dpram_complete);
	if (!dpram_task) {
		EPRINTK("DPRAM I/O thread error\n");
		return -EIO;
	}

	/* create serial device for Circuit Switched Data */
	ret = pdp_activate(&pdp_arg, DEV_TYPE_SERIAL, DEV_FLAG_STICKY);
	if (ret < 0) {
		EPRINTK("failed to create a serial device for CSD\n");
		goto err0;
	}

	ret = pdp_activate(&efs_arg, DEV_TYPE_SERIAL, DEV_FLAG_STICKY);
	if (ret < 0) {
		EPRINTK("failed to create a serial device for EFS\n");
		goto err1;
	}

	ret = pdp_activate(&gps_arg, DEV_TYPE_SERIAL, DEV_FLAG_STICKY);
	if (ret < 0) {
		EPRINTK("failed to create a serial device for GPS\n");
		goto err2;
	}

	ret = pdp_activate(&xtra_arg, DEV_TYPE_SERIAL, DEV_FLAG_STICKY);
	if (ret < 0) {
		EPRINTK("failed to create a serial device for XTRA\n");
		goto err3;
	}

	/* create app. interface device */
	ret = misc_register(&multipdp_dev);
	if (ret < 0) {
		EPRINTK("misc_register() failed\n");
		goto err1;
	}

#ifdef CONFIG_PROC_FS
	create_proc_read_entry(APP_DEVNAME, 0, 0, 
			       multipdp_proc_read, NULL);
#endif

//	printk(KERN_INFO 
//	       "$Id: multipdp.c,v 1.10 2008/01/11 05:40:56 melonzz Exp $\n");
	return 0;

err3:
	/* undo serial device for Circuit Switched Data */
	pdp_deactivate(&xtra_arg, 1);
err2:
	/* undo serial device for Circuit Switched Data */
	pdp_deactivate(&gps_arg, 1);
err1:
	/* undo serial device for Circuit Switched Data */
	pdp_deactivate(&pdp_arg, 1);
err0:
	/* kill DPRAM I/O thread */
	if (dpram_task) {
		send_sig(SIGUSR1, dpram_task, 1);
		wait_for_completion(&dpram_complete);
	}
	return ret;
}

static void __exit multipdp_exit(void)
{
#ifdef CONFIG_PROC_FS
	remove_proc_entry(APP_DEVNAME, 0);
#endif

	/* remove app. interface device */
	misc_deregister(&multipdp_dev);

	/* clean up PDP context table */
	pdp_cleanup();

	/* kill DPRAM I/O thread */
	if (dpram_task) {
		send_sig(SIGUSR1, dpram_task, 1);
		wait_for_completion(&dpram_complete);
	}
}

module_init(multipdp_init);
module_exit(multipdp_exit);

MODULE_AUTHOR("SAMSUNG ELECTRONICS CO., LTD");
MODULE_DESCRIPTION("Multiple PDP Muxer / Demuxer");
MODULE_LICENSE("GPL");

