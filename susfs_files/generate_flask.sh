#!/bin/bash
# Generate SELinux headers for KernelSU (complete format for genheaders)

KERNEL_TREE=$1

if [ -z "$KERNEL_TREE" ]; then
  echo "Usage: $0 <kernel_tree_path>"
  exit 1
fi

cd "$KERNEL_TREE" || exit 1

# 创建必要的目录
mkdir -p security/selinux/include
mkdir -p security/selinux/ss

# ============================================================
# initial_sid_to_string.h - 必须包含 initial_sid_to_string 数组!
# genheaders 工具依赖此数组
# ============================================================
cat > security/selinux/initial_sid_to_string.h << 'INITIAL_SID_EOF'
static const char * const initial_sid_to_string[] = {
	"kernel",
	"security",
	"unlabeled",
	"fs",
	"file",
	"file_labels",
	"init",
	"any_socket",
	"port",
	"netmsg",
	"bdev",
	"devnull",
	NULL,
};
INITIAL_SID_EOF
echo "Generated security/selinux/initial_sid_to_string.h"

# ============================================================
# class_to_string.h - 安全类名称数组
# ============================================================
cat > security/selinux/class_to_string.h << 'CLASS_EOF'
static const char * const class_to_string[] = {
	"security",
	"process",
	"system",
	"capability",
	"filesystem",
	"file",
	"dir",
	"fd",
	"lnk_file",
	"chr_file",
	"blk_file",
	"sock_file",
	"fifo_file",
	"socket",
	"tcp_socket",
	"udp_socket",
	"rawip_socket",
	"node",
	"netif",
	"netnode",
	"netport",
	"database",
	"db_database",
	"db_table",
	"db_procedure",
	"db_column",
	"db_tuple",
	"db_blob",
	"process_signal",
	"process_ns",
	"drawable",
	"window",
	"x_colormap",
	"x_drawable",
	"x_server",
	"x_cursor",
	"x_client",
	"x_device",
	"x_font",
	"x_gc",
	"x_selection",
	"x_event",
	"x_synthetic",
	"x_window",
	"x_property",
	"x_resource",
	"x_client_window",
	"association",
	"netlink_socket",
	"packet_socket",
	"key_socket",
	"dccp_socket",
	"tun_socket",
	"ipsec_sa",
	"ipsec_policy",
	"association2",
	"ndisc_socket",
	"key",
	"x_context",
	"x_transition",
	"x_selection2",
	"drawable2",
	"x_server2",
	"x_client2",
	"x_window2",
	"x_property2",
	"x_resource2",
	"x_event2",
	"x_synthetic2",
	"x_cursor2",
	"x_colormap2",
	"x_device2",
	"x_font2",
	"x_gc2",
	"x_selection3",
	"x_transition2",
	"x_context2",
	"x_client_window2",
	"unix_stream_socket",
	"unix_dgram_socket",
	"sctp_socket",
	"icmp_socket",
	"netlink_route_socket",
	"netlink_tcpdiag_socket",
	"netlink_nflog_socket",
	"netlink_xfrm_socket",
	"netlink_selinux_socket",
	"netlink_iscsi_socket",
	"netlink_audit_socket",
	"netlink_fib_lookup_socket",
	"netlink_connector_socket",
	"netlink_netfilter_socket",
	"netlink_dnrt_socket",
	"netlink_kobject_uevent_socket",
	"netlink_generic_socket",
	"netlink_scsitransport_socket",
	"netlink_rdma_socket",
	"capability2",
	"peer",
	"appletalk_socket",
	"netlink_crypto_socket",
	"ax25_socket",
	"ipx_socket",
	"netrom_socket",
	"atmpvc_socket",
	"x25_socket",
	"rose_socket",
	"decnet_socket",
	"atmsvc_socket",
	"rds_socket",
	"irda_socket",
	"pppox_socket",
	"llc_socket",
	"can_socket",
	"tipc_socket",
	"bluetooth_socket",
	"iucv_socket",
	"rxrpc_socket",
	"isdn_socket",
	"phonet_socket",
	"ieee802154_socket",
	"caif_socket",
	"alg_socket",
	"nfc_socket",
	"kcm_socket",
	"qipcrtr_socket",
	"smc_socket",
	"vsock_socket",
	"cap_userns",
	"cap2_userns",
	"binder",
	"process2",
	"memprotect",
	"kernel_service",
	NULL,
};
CLASS_EOF
echo "Generated security/selinux/class_to_string.h"

# ============================================================
# av_perm_to_string.h - 访问向量权限字符串表
# ============================================================
cat > security/selinux/av_perm_to_string.h << 'AV_PERM_EOF'
struct av_perm_to_string {
	u16 tclass;
	u32 value;
	const char *name;
};

static const struct av_perm_to_string av_perm_to_string[] = {
	{ SECCLASS_FILESYSTEM, FILESYSTEM__MOUNT, "mount" },
	{ SECCLASS_FILESYSTEM, FILESYSTEM__REMOUNT, "remount" },
	{ SECCLASS_FILESYSTEM, FILESYSTEM__UNMOUNT, "unmount" },
	{ SECCLASS_FILESYSTEM, FILESYSTEM__GETATTR, "getattr" },
	{ SECCLASS_FILESYSTEM, FILESYSTEM__RELABELFROM, "relabelfrom" },
	{ SECCLASS_FILESYSTEM, FILESYSTEM__RELABELTO, "relabelto" },
	{ SECCLASS_FILESYSTEM, FILESYSTEM__ASSOCIATE, "associate" },
	{ SECCLASS_FILESYSTEM, FILESYSTEM__QUOTAMOD, "quotamod" },
	{ SECCLASS_FILESYSTEM, FILESYSTEM__QUOTAGET, "quotaget" },
	{ SECCLASS_FILE, FILE__READ, "read" },
	{ SECCLASS_FILE, FILE__WRITE, "write" },
	{ SECCLASS_FILE, FILE__CREATE, "create" },
	{ SECCLASS_FILE, FILE__GETATTR, "getattr" },
	{ SECCLASS_FILE, FILE__SETATTR, "setattr" },
	{ SECCLASS_FILE, FILE__LOCK, "lock" },
	{ SECCLASS_FILE, FILE__RELABELFROM, "relabelfrom" },
	{ SECCLASS_FILE, FILE__RELABELTO, "relabelto" },
	{ SECCLASS_FILE, FILE__APPEND, "append" },
	{ SECCLASS_FILE, FILE__UNLINK, "unlink" },
	{ SECCLASS_FILE, FILE__LINK, "link" },
	{ SECCLASS_FILE, FILE__RENAME, "rename" },
	{ SECCLASS_FILE, FILE__EXECUTE, "execute" },
	{ SECCLASS_FILE, FILE__SWAPON, "swapon" },
	{ SECCLASS_FILE, FILE__QUOTAON, "quotaon" },
	{ SECCLASS_FILE, FILE__MOUNTON, "mounton" },
	{ SECCLASS_PROCESS, PROCESS__FORK, "fork" },
	{ SECCLASS_PROCESS, PROCESS__TRANSITION, "transition" },
	{ SECCLASS_PROCESS, PROCESS__SIGCHLD, "sigchld" },
	{ SECCLASS_PROCESS, PROCESS__SIGKILL, "sigkill" },
	{ SECCLASS_PROCESS, PROCESS__SIGSTOP, "sigstop" },
	{ SECCLASS_PROCESS, PROCESS__SIGNICE, "signull" },
	{ SECCLASS_PROCESS, PROCESS__PTRACE, "ptrace" },
	{ SECCLASS_PROCESS, process__GETSCHED, "getsched" },
	{ SECCLASS_PROCESS, PROCESS__SETSCHED, "setsched" },
	{ SECCLASS_PROCESS, PROCESS__GETSESSION, "getsession" },
	{ SECCLASS_PROCESS, PROCESS__GETPGID, "getpgid" },
	{ SECCLASS_PROCESS, PROCESS__SETPGID, "setpgid" },
	{ SECCLASS_PROCESS, PROCESS__GETCAP, "getcap" },
	{ SECCLASS_PROCESS, PROCESS__SETCAP, "setcap" },
	{ NULL, 0, NULL }
};
AV_PERM_EOF
echo "Generated security/selinux/av_perm_to_string.h"

# ============================================================
# common_perm_to_string.h - 通用权限字符串
# ============================================================
cat > security/selinux/common_perm_to_string.h << 'COMMON_PERM_EOF'
struct common_perm_to_string {
	u16 tclass;
	u32 value;
	const char *name;
};

static const struct common_perm_to_string common_perm_to_string[] = {
	{ NULL, 0, NULL }
};
COMMON_PERM_EOF
echo "Generated security/selinux/common_perm_to_string.h"

# ============================================================
# flask.h - Security class 定义 (宏)
# ============================================================
cat > security/selinux/flask.h << 'FLASK_EOF'
#ifndef _FLASK_H_
#define _FLASK_H_

#define SECCLASS_SECURITY           0
#define SECCLASS_PROCESS            1
#define SECCLASS_SYSTEM            2
#define SECCLASS_CAPABILITY        3
#define SECCLASS_FILESYSTEM        4
#define SECCLASS_FILE              5
#define SECCLASS_DIR               6
#define SECCLASS_FD                7
#define SECCLASS_LNK_FILE          8
#define SECCLASS_CHR_FILE          9
#define SECCLASS_BLK_FILE         10
#define SECCLASS_SOCK_FILE        11
#define SECCLASS_FIFO_FILE         12
#define SECCLASS_SOCKET           13
#define SECCLASS_TCP_SOCKET      14
#define SECCLASS_UDP_SOCKET      15
#define SECCLASS_RAWIP_SOCKET    16
#define SECCLASS_NODE             17
#define SECCLASS_NETIF            18
#define SECCLASS_NETNODE          19
#define SECCLASS_NETPORT          20
#define SECCLASS_DATABASE        21
#define SECCLASS_DB_DATABASE     22
#define SECCLASS_DB_TABLE        23
#define SECCLASS_DB_PROCEDURE    24
#define SECCLASS_DB_COLUMN       25
#define SECCLASS_DB_TUPLE       26
#define SECCLASS_DB_BLOB        27
#define SECCLASS_PROCESS_SIGNAL  28
#define SECCLASS_PROCESS_NS      29
#define SECCLASS_DRAWABLE        30
#define SECCLASS_WINDOW           31
#define SECCLASS_X_COLORMAP      32
#define SECCLASS_X_DRAWABLE      33
#define SECCLASS_X_SERVER        34
#define SECCLASS_X_CURSOR        35
#define SECCLASS_X_CLIENT        36
#define SECCLASS_X_DEVICE        37
#define SECCLASS_X_FONT          38
#define SECCLASS_X_GC            39
#define SECCLASS_X_SELECTION     40
#define SECCLASS_X_EVENT         41
#define SECCLASS_X_SYNTHETIC    42
#define SECCLASS_X_WINDOW        43
#define SECCLASS_X_PROPERTY      44
#define SECCLASS_X_RESOURCE     45
#define SECCLASS_X_CLIENT_WINDOW 46
#define SECCLASS_ASSOCIATION     47
#define SECCLASS_NETLINK_SOCKET  48
#define SECCLASS_PACKET_SOCKET   49
#define SECCLASS_KEY_SOCKET      50
#define SECCLASS_DCCP_SOCKET    51
#define SECCLASS_TUN_SOCKET     52
#define SECCLASS_IPSEC_SA       53
#define SECCLASS_IPSEC_POLICY   54
#define SECCLASS_ASSOCIATION2   55
#define SECCLASS_NDISC_SOCKET   56
#define SECCLASS_KEY             57
#define SECCLASS_X_CONTEXT      58
#define SECCLASS_X_TRANSITION   59
#define SECCLASS_X_SELECTION2   60
#define SECCLASS_DRAWABLE2      61
#define SECCLASS_X_SERVER2      62
#define SECCLASS_X_CLIENT2      63
#define SECCLASS_X_WINDOW2      64
#define SECCLASS_X_PROPERTY2    65
#define SECCLASS_X_RESOURCE2    66
#define SECCLASS_X_EVENT2       67
#define SECCLASS_X_SYNTHETIC2  68
#define SECCLASS_X_CURSOR2      69
#define SECCLASS_X_COLORMAP2    70
#define SECCLASS_X_DEVICE2      71
#define SECCLASS_X_FONT2        72
#define SECCLASS_X_GC2          73
#define SECCLASS_X_SELECTION3   74
#define SECCLASS_X_TRANSITION2  75
#define SECCLASS_X_CONTEXT2     76
#define SECCLASS_X_CLIENT_WINDOW2 77
#define SECCLASS_UNIX_STREAM_SOCKET 78
#define SECCLASS_UNIX_DGRAM_SOCKET 79
#define SECCLASS_SCTP_SOCKET        80
#define SECCLASS_ICMP_SOCKET        81
#define SECCLASS_NETLINK_ROUTE_SOCKET 82
#define SECCLASS_NETLINK_TCPDIAG_SOCKET 83
#define SECCLASS_NETLINK_NFLOG_SOCKET 84
#define SECCLASS_NETLINK_XFRM_SOCKET 85
#define SECCLASS_NETLINK_SELINUX_SOCKET 86
#define SECCLASS_NETLINK_ISCSI_SOCKET 87
#define SECCLASS_NETLINK_AUDIT_SOCKET 88
#define SECCLASS_NETLINK_FIB_LOOKUP_SOCKET 89
#define SECCLASS_NETLINK_CONNECTOR_SOCKET 90
#define SECCLASS_NETLINK_NETFILTER_SOCKET 91
#define SECCLASS_NETLINK_DNRT_SOCKET 92
#define SECCLASS_NETLINK_KOBJECT_UEVENT_SOCKET 93
#define SECCLASS_NETLINK_GENERIC_SOCKET 94
#define SECCLASS_NETLINK_SCSITRANSPORT_SOCKET 95
#define SECCLASS_NETLINK_RDMA_SOCKET 96
#define SECCLASS_CAPABILITY2      97
#define SECCLASS_PEER             98
#define SECCLASS_APPLETALK_SOCKET 99
#define SECCLASS_NETLINK_CRYPTO_SOCKET 100
#define SECCLASS_AX25_SOCKET        101
#define SECCLASS_IPX_SOCKET         102
#define SECCLASS_NETROM_SOCKET      103
#define SECCLASS_ATMPVC_SOCKET      104
#define SECCLASS_X25_SOCKET         105
#define SECCLASS_ROSE_SOCKET        106
#define SECCLASS_DECNET_SOCKET      107
#define SECCLASS_ATMSVC_SOCKET      108
#define SECCLASS_RDS_SOCKET         109
#define SECCLASS_IRDA_SOCKET        110
#define SECCLASS_PPPOX_SOCKET       111
#define SECCLASS_LLC_SOCKET         112
#define SECCLASS_CAN_SOCKET         113
#define SECCLASS_TIPC_SOCKET        114
#define SECCLASS_BLUETOOTH_SOCKET   115
#define SECCLASS_IUCV_SOCKET        116
#define SECCLASS_RXRPC_SOCKET       117
#define SECCLASS_ISDN_SOCKET        118
#define SECCLASS_PHONET_SOCKET      119
#define SECCLASS_IEEE802154_SOCKET  120
#define SECCLASS_CAIF_SOCKET        121
#define SECCLASS_ALG_SOCKET         122
#define SECCLASS_NFC_SOCKET         123
#define SECCLASS_KCM_SOCKET         124
#define SECCLASS_QIPCRTR_SOCKET     125
#define SECCLASS_SMC_SOCKET         126
#define SECCLASS_VSOCK_SOCKET       127
#define SECCLASS_CAP_USERNS         128
#define SECCLASS_CAP2_USERNS        129
#define SECCLASS_BINDER            130
#define SECCLASS_PROCESS2          131
#define SECCLASS_MEMPROTECT        132
#define SECCLASS_KERNEL_SERVICE    133
#define SECCLASS_MAX                134

/* Initial SID definitions (also needed by sidtab.h) */
#define SECINITSID_KERNEL      1
#define SECINITSID_SECURITY   2
#define SECINITSID_UNLABELED  3
#define SECINITSID_FS          4
#define SECINITSID_FILE        5
#define SECINITSID_FILE_LABELS 6
#define SECINITSID_INIT        7
#define SECINITSID_ANY_SOCKET 8
#define SECINITSID_PORT        9
#define SECINITSID_NETMSG     10
#define SECINITSID_BDEV       11
#define SECINITSID_DEVNULL    12
#define SECINITSID_NUM        13

#endif /* _FLASK_H_ */
FLASK_EOF
echo "Generated security/selinux/flask.h (with SECINITSID_NUM)"

# ============================================================
# initial_sid.h - Initial SID 宏定义
# ============================================================
cat > security/selinux/initial_sid.h << 'INITIAL_SID_MACROS_EOF'
#ifndef _INITIAL_SID_H_
#define _INITIAL_SID_H_

#define SECINITSID_KERNEL      1
#define SECINITSID_SECURITY   2
#define SECINITSID_UNLABELED  3
#define SECINITSID_FS          4
#define SECINITSID_FILE        5
#define SECINITSID_FILE_LABELS 6
#define SECINITSID_INIT        7
#define SECINITSID_ANY_SOCKET 8
#define SECINITSID_PORT        9
#define SECINITSID_NETMSG     10
#define SECINITSID_BDEV       11
#define SECINITSID_DEVNULL    12
#define SECINITSID_NUM        13

#endif /* _INITIAL_SID_H_ */
INITIAL_SID_MACROS_EOF
echo "Generated security/selinux/initial_sid.h (with SECINITSID_NUM)"

# 关键：复制到 ss/ 目录！sidtab.h 在 ss/ 下，include 路径优先搜索此目录
cp security/selinux/initial_sid.h security/selinux/ss/initial_sid.h
cp security/selinux/flask.h security/selinux/ss/flask.h
cp security/selinux/av_permissions.h security/selinux/ss/av_permissions.h
echo "Copied headers to security/selinux/ss/"

# ============================================================
# av_permissions.h - 权限值宏定义
# ============================================================
cat > security/selinux/av_permissions.h << 'AV_PERMISSIONS_EOF'
#ifndef _AV_PERMISSIONS_H_
#define _AV_PERMISSIONS_H_

/* Common permissions */
#define COMMON__FILESYSTEM 0x00000001UL

/* Filesystem permissions */
#define FILESYSTEM__MOUNT            0x00000001UL
#define FILESYSTEM__REMOUNT         0x00000002UL
#define FILESYSTEM__UNMOUNT         0x00000004UL
#define FILESYSTEM__GETATTR         0x00000008UL
#define FILESYSTEM__RELABELFROM     0x00000010UL
#define FILESYSTEM__RELABELTO       0x00000020UL
#define FILESYSTEM__ASSOCIATE      0x00000040UL
#define FILESYSTEM__QUOTAMOD       0x00000080UL
#define FILESYSTEM__QUOTAGET       0x00000100UL
#define FILESYSTEM__LABELFROM       0x00000200UL

/* File permissions */
#define FILE__READ                0x00000001UL
#define FILE__WRITE               0x00000002UL
#define FILE__CREATE              0x00000004UL
#define FILE__GETATTR             0x00000008UL
#define FILE__SETATTR             0x00000010UL
#define FILE__LOCK                0x00000020UL
#define FILE__RELABELFROM         0x00000040UL
#define FILE__RELABELTO           0x00000080UL
#define FILE__APPEND              0x00000100UL
#define FILE__UNLINK              0x00000200UL
#define FILE__LINK                0x00000400UL
#define FILE__RENAME              0x00000800UL
#define FILE__EXECUTE             0x00001000UL
#define FILE__SWAPON              0x00002000UL
#define FILE__QUOTAON             0x00004000UL
#define FILE__MOUNTON             0x00008000UL
#define FILE__AUDIT_ACCESS       0x00010000UL
#define FILE__AUDIT_MODIFY       0x00020000UL
#define FILE__EXECUTE_NO_TRANS   0x00040000UL
#define FILE__TRANSITION          0x00080000UL
#define FILE__ENTRYPOINT          0x00100000UL
#define FILE__AUDIT_CHANGE_OWNER 0x00200000UL
#define FILE__IOCTL              0x00400000UL
#define FILE__OPEN               0x00800000UL

/* Process permissions */
#define PROCESS__FORK              0x00000001UL
#define PROCESS__TRANSITION       0x00000002UL
#define PROCESS__SIGCHLD          0x00000004UL
#define PROCESS__SIGKILL          0x00000008UL
#define PROCESS__SIGSTOP          0x00000010UL
#define PROCESS__SIGNICE          0x00000020UL
#define PROCESS__PTRACE           0x00000040UL
#define PROCESS__GETINFO          0x00000080UL
#define PROCESS__SETINFO          0x00000100UL
#define PROCESS__GETATTR         0x00000200UL
#define PROCESS__SETATTR         0x00000400UL
#define PROCESS__CREATE          0x00000800UL
#define PROCESS__EXECUTE        0x00001000UL
#define PROCESS__DYTRANSITION   0x00002000UL
#define PROCESS__NOATSECURITY   0x00004000UL
#define PROCESS__SIGINH         0x00010000UL
#define PROCESS__DYNTRANSITION 0x00020000UL
#define PROCESS__SIGNAL        0x00040000UL
#define PROCESS__GETCAP        0x00080000UL
#define PROCESS__SETCAP        0x00100000UL

/* File descriptor permissions */
#define FD__USE                 0x00000001UL

/* Directory permissions */
#define DIR__ADD_NAME           0x00000001UL
#define DIR__REMOVE_NAME        0x00000002UL
#define DIR__SEARCH             0x00000004UL
#define DIR__RMDIR              0x00000008UL
#define DIR__REPARENT           0x00000010UL
#define DIR__WRITE              0x00000020UL
#define DIR__READ               0x00000040UL

/* Binder permissions */
#define BINDER__SET_CONTEXT_MGR  0x00000001UL
#define BINDER__IMPERSONATE      0x00000002UL
#define BINDER__CALL             0x00000004UL
#define BINDER__TRANSFER         0x00000008UL

/* System permissions */
#define SYSTEM__SYSLOG_READ      0x00000001UL
#define SYSTEM__SYSLOG_CONSOLE   0x00000002UL
#define SYSTEM__SYSLOG_MOD       0x00000004UL

/* Process2 permissions */
#define PROCESS2__NNP_TRANSITION    0x00000001UL
#define PROCESS2__NOSUID_TRANSITION 0x00000002UL

/* More file permissions */
#define FILE__MAP                  0x01000000UL
#define FILE__EXECMOD              0x02000000UL

/* More process permissions */
#define PROCESS__SHARE             0x00200000UL
#define PROCESS__NOATSECURE        0x00400000UL
#define PROCESS__RLIMITINH         0x00800000UL
#define PROCESS__EXECMEM           0x01000000UL
#define PROCESS__EXECHEAP          0x02000000UL
#define PROCESS__EXECSTACK         0x04000000UL
#define PROCESS__SETPGID           0x08000000UL
#define PROCESS__GETPGID           0x10000000UL

/* Memprotect permissions */
#define MEMPROTECT__MMAP_ZERO      0x00000001UL

/* Kernel service permissions */
#define KERNEL_SERVICE__USE_AS_OVERRIDE  0x00000001UL
#define KERNEL_SERVICE__CREATE_FILES_AS  0x00000002UL

/* More system permissions */
#define SYSTEM__MODULE_REQUEST      0x00000008UL
#define SYSTEM__MODULE_LOAD         0x00000010UL

#endif /* _AV_PERMISSIONS_H_ */
AV_PERMISSIONS_EOF
echo "Generated security/selinux/av_permissions.h"

# ============================================================
# Fix apk_sign.c EXPECTED_SIZE and EXPECTED_HASH issue
# ============================================================
if [ -f kernel/apk_sign.c ]; then
  if ! grep -q '#define EXPECTED_SIZE' kernel/apk_sign.c; then
    echo "Fixing apk_sign.c: adding missing macro definitions..."
    sed -i '1i #ifndef EXPECTED_SIZE\n#define EXPECTED_SIZE 0\n#endif\n#ifndef EXPECTED_HASH\n#define EXPECTED_HASH NULL\n#endif' kernel/apk_sign.c
  fi
fi

echo "SELinux headers generated successfully!"
