#ifndef HAVE_NS_WIRELESS_H
#define HAVE_NS_WIRELESS_H

/* auth protocol */
#define NS_WIRELESS_AUTH_OFF          0
#define NS_WIRELESS_AUTH_WEP          1
#define NS_WIRELESS_AUTH_WPA          2

/* Cypher values in GENIE (pairwise and group) */
#define NS_IW_IE_CIPHER_NONE          0
#define NS_IW_IE_CIPHER_WEP40         1
#define NS_IW_IE_CIPHER_TKIP          2
#define NS_IW_IE_CIPHER_WRAP          3
#define NS_IW_IE_CIPHER_CCMP          4
#define NS_IW_IE_CIPHER_WEP104        5

/* Key management in GENIE */
#define NS_IW_IE_KEY_MGMT_NONE        0
#define NS_IW_IE_KEY_MGMT_802_1X      1
#define NS_IW_IE_KEY_MGMT_PSK         2

#ifndef TRUE
#define	TRUE	1
#endif

#ifndef FALSE
#define	FALSE	0
#endif

typedef struct {
	char *essid;
	char *apaddr;
	int quality;
	int en_method;
	int pairwise;
	int group;
	int key_mgmt;
	int haskey;
} ap_info;

typedef struct APLIST {
	ap_info		*info;
	struct APLIST	*next;
} APLIST;

void wireless_aplist_free(APLIST *aplist);
APLIST *wireless_scanning(int iwsockfd, const char *ifname);

#endif
