#!/bin/bash
# Generate SELinux headers for KernelSU

KERNEL_TREE=$1

if [ -z "$KERNEL_TREE" ]; then
  echo "Usage: $0 <kernel_tree_path>"
  exit 1
fi

cd "$KERNEL_TREE" || exit 1

mkdir -p security/selinux/include

# 1. Generate flask.h - Security class definitions
if [ ! -f security/selinux/include/flask.h ]; then
  echo "Generating flask.h..."
  cat > security/selinux/include/flask.h << 'EOF'
#ifndef _FLASK_H_
#define _FLASK_H_

/* Auto-generated SELinux flask.h for KernelSU */
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
#define SECCLASS_MAX            78

#endif /* _FLASK_H_ */
EOF
fi

# 2. Generate av_permissions.h - Access vector permissions
if [ ! -f security/selinux/include/av_permissions.h ]; then
  echo "Generating av_permissions.h..."
  cat > security/selinux/include/av_permissions.h << 'EOF'
#ifndef _AV_PERMISSIONS_H_
#define _AV_PERMISSIONS_H_

/* Auto-generated SELinux av_permissions.h for KernelSU */

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
#define FILE__AUDIT_CHANGE_OWNER 0x00200000UL
#define FILE__AUDIT_CHANGE_OWNER 0x00200000UL

/* Process permissions */
#define PROCESS__FORK              0x00000001UL
#define PROCESS__SIGCHLD          0x00000002UL
#define PROCESS__SIGKILL          0x00000004UL
#define PROCESS__SIGSTOP          0x00000008UL
#define PROCESS__SIGNICE          0x00000010UL
#define PROCESS__SIGCHLD          0x00000020UL
#define PROCESS__PTRACE           0x00000040UL
#define PROCESS__GETINFO          0x00000080UL
#define PROCESS__SETINFO          0x00000100UL
#define PROCESS__GETATTR         0x00000200UL
#define PROCESS__SETATTR         0x00000400UL
#define PROCESS__CREATE          0x00000800UL
#define PROCESS__EXECUTE        0x00001000UL
#define PROCESS__TRANSITION     0x00002000UL
#define PROCESS__DYTRANSITION   0x00004000UL
#define PROCESS__NOATSECURITY   0x00008000UL
#define PROCESS__SIGINH         0x00010000UL
#define PROCESS__DYNTRANSITION 0x00020000UL

#endif /* _AV_PERMISSIONS_H_ */
EOF
fi

# 3. Generate initial_sid.h - Initial SID definitions (needed by sidtab.h)
if [ ! -f security/selinux/include/initial_sid.h ]; then
  echo "Generating initial_sid.h..."
  cat > security/selinux/include/initial_sid.h << 'EOF'
#ifndef _INITIAL_SID_H_
#define _INITIAL_SID_H_

/* Auto-generated SELinux initial SID definitions for KernelSU */
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
EOF
fi

# Also create initial_sid_to_string.h (some kernels may need it)
if [ ! -f security/selinux/include/initial_sid_to_string.h ]; then
  echo "Generating initial_sid_to_string.h..."
  cat > security/selinux/include/initial_sid_to_string.h << 'EOF'
#ifndef _INITIAL_SID_TO_STRING_H_
#define _INITIAL_SID_TO_STRING_H_

/* Auto-generated */
#include "initial_sid.h"

#endif /* _INITIAL_SID_TO_STRING_H_ */
EOF
fi

# 4. Generate other required headers
for f in av_perm_to_string.h class_to_string.h common_perm_to_string.h; do
  if [ ! -f "security/selinux/include/$f" ]; then
    echo "Creating $f..."
    echo "/* Auto-generated */" > "security/selinux/include/$f"
  fi
done

echo "SELinux headers generated successfully"
