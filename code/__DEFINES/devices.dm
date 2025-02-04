// Role disk defines

#define DISK_POWER (1<<0)
#define DISK_ATMOS (1<<1)
#define DISK_MED (1<<2)
#define DISK_CHEM (1<<3)
#define DISK_MANIFEST (1<<4)
#define DISK_NEWS (1<<5)
#define DISK_SIGNAL	(1<<6)
#define DISK_STATUS (1<<7)
#define DISK_CARGO (1<<8)
#define DISK_ROBOS (1<<9)
#define DISK_JANI (1<<10)
#define DISK_SEC (1<<11)
#define DISK_BUDGET (1<<12)

// Used to stringify message targets before sending the signal datum.
#define STRINGIFY_PDA_TARGET(name, job) "[name] ([job])"
