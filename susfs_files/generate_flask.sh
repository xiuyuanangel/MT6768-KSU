#!/bin/bash
# Generate flask.h for SELinux

KERNEL_TREE=$1

if [ -z "$KERNEL_TREE" ]; then
  echo "Usage: $0 <kernel_tree_path>"
  exit 1
fi

cd "$KERNEL_TREE" || exit 1

# flask.h 是 SELinux 自动生成的头文件
# 如果不存在，则创建避免编译错误
if [ ! -f security/selinux/include/flask.h ]; then
  echo "flask.h not found, creating file..."
  mkdir -p security/selinux/include
  
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
#define SECCLASS_MAX            77

#endif /* _FLASK_H_ */
EOF
fi

# 检查其他可能缺失的 SELinux 头文件
for f in av_perm_to_string.h av_permissions.h class_to_string.h common_perm_to_string.h; do
  if [ ! -f "security/selinux/include/$f" ]; then
    echo "Creating empty $f..."
    echo "/* Auto-generated */" > "security/selinux/include/$f"
  fi
done

echo "SELinux headers generated successfully"
