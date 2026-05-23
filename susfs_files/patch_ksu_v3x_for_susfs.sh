#!/bin/bash
# Manual SUSFS integration for KernelSU v3.x
# Usage: run from kernel tree root after setup.sh, before make
set -e

KSU_SRC="KernelSU/kernel"
echo "[+] SUSFS integration for KernelSU v3.x - starting..."

# ---- 1. PATCH Kconfig ----
echo "[+] Adding SUSFS Kconfig menu..."
KCONFIG="$KSU_SRC/Kconfig"
if ! grep -q "KSU_SUSFS" "$KCONFIG" 2>/dev/null; then
cat >> "$KCONFIG" << 'EOF'

menu "KernelSU - SUSFS"
config KSU_SUSFS
    bool "KernelSU addon - SUSFS"
    depends on KSU
    default y

config KSU_SUSFS_SUS_PATH
    bool "Enable to hide suspicious path"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SUS_MOUNT
    bool "Enable to hide suspicious mounts"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SUS_KSTAT
    bool "Enable to spoof suspicious kstat"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SUS_MAPS
    bool "Enable to spoof suspicious maps"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_TRY_UMOUNT
    bool "Enable to use ksu's try_umount"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_SPOOF_UNAME
    bool "Enable to spoof uname"
    depends on KSU_SUSFS
    default y

config KSU_SUSFS_ENABLE_LOG
    bool "Enable logging susfs log to kernel"
    depends on KSU_SUSFS
    default y
endmenu
EOF
fi
echo "  Kconfig done."

# ---- 2. PATCH Makefile ----
echo "[+] Adding SUSFS ccflags to Makefile..."
MAKEFILE="$KSU_SRC/Makefile"
if ! grep -q "KSU_SUSFS" "$MAKEFILE" 2>/dev/null; then
cat >> "$MAKEFILE" << 'EOF'

ifeq ($(shell test -e $(srctree)/fs/susfs.c; echo $$?),0)
ifdef CONFIG_KSU_SUSFS
ccflags-y += -DKSU_SUSFS
endif
ifdef CONFIG_KSU_SUSFS_SUS_PATH
ccflags-y += -DKSU_SUSFS_SUS_PATH
endif
ifdef CONFIG_KSU_SUSFS_SUS_MOUNT
ccflags-y += -DKSU_SUSFS_SUS_MOUNT
endif
ifdef CONFIG_KSU_SUSFS_SUS_KSTAT
ccflags-y += -DKSU_SUSFS_SUS_KSTAT
endif
ifdef CONFIG_KSU_SUSFS_SUS_MAPS
ccflags-y += -DKSU_SUSFS_SUS_MAPS
endif
ifdef CONFIG_KSU_SUSFS_TRY_UMOUNT
ccflags-y += -DKSU_SUSFS_TRY_UMOUNT
endif
ifdef CONFIG_KSU_SUSFS_SPOOF_UNAME
ccflags-y += -DKSU_SUSFS_SPOOF_UNAME
endif
ifdef CONFIG_KSU_SUSFS_ENABLE_LOG
ccflags-y += -DKSU_SUSFS_ENABLE_LOG
endif
endif
EOF
fi
echo "  Makefile done."

# ---- 3. Create kernel_compat files ----
echo "[+] Creating kernel_compat.c and kernel_compat.h..."
if [ ! -f "$KSU_SRC/kernel_compat.c" ]; then
cat > "$KSU_SRC/kernel_compat.c" << 'EOF'
#include <linux/version.h>
#include <linux/uaccess.h>
int ksu_access_ok(const void *addr, unsigned long size) {
#if LINUX_VERSION_CODE < KERNEL_VERSION(5,0,0)
    return access_ok(VERIFY_READ, addr, size);
#else
    return access_ok(addr, size);
#endif
}
EOF
fi

if [ ! -f "$KSU_SRC/kernel_compat.h" ]; then
cat > "$KSU_SRC/kernel_compat.h" << 'EOF'
#ifndef _KSU_KERNEL_COMPAT_H
#define _KSU_KERNEL_COMPAT_H
extern int ksu_access_ok(const void *addr, unsigned long size);
#endif
EOF
fi

# Add kernel_compat.o to Kbuild
KBUILD="$KSU_SRC/Kbuild"
if [ -f "$KBUILD" ] && ! grep -q "kernel_compat" "$KBUILD" 2>/dev/null; then
    sed -i '/^ksu-objs/ s/$/ kernel_compat.o/' "$KBUILD"
elif [ ! -f "$KBUILD" ]; then
    echo "ksu-objs += kernel_compat.o" >> "$MAKEFILE"
fi
echo "  kernel_compat done."

# ---- 4. Patch core/init.c - add susfs_init() ----
echo "[+] Adding susfs_init() to core/init.c..."
INITC="$KSU_SRC/core/init.c"
if [ -f "$INITC" ] && ! grep -q "susfs_init" "$INITC" 2>/dev/null; then
    sed -i '/^#include "throne_tracker.h"/a #ifdef CONFIG_KSU_SUSFS\n#include <linux/susfs.h>\n#endif' "$INITC"
    sed -i '/^	ksu_core_init();/i #ifdef CONFIG_KSU_SUSFS\n\tsusfs_init();\n#endif' "$INITC"
fi
echo "  init.c done."

# ---- 5. Patch hook/setuid_hook.c - add susfs_try_umount() ----
echo "[+] Adding susfs_try_umount() to hook/setuid_hook.c..."
SETUID="$KSU_SRC/hook/setuid_hook.c"
if [ -f "$SETUID" ] && ! grep -q "susfs.h" "$SETUID" 2>/dev/null; then
    sed -i '1s|^|#ifdef CONFIG_KSU_SUSFS\n#include <linux/susfs.h>\n#endif\n|' "$SETUID"
    # Insert susfs_try_umount before ksu_handle_umount
    sed -i '/ksu_handle_umount(old_uid, new_uid);/i #ifdef CONFIG_KSU_SUSFS_TRY_UMOUNT\n\tsusfs_try_umount(old_uid);\n#endif' "$SETUID"
fi
echo "  setuid_hook.c done."

# ---- 6. Patch selinux/rules.c ----
echo "[+] Adding SELinux unmount rule..."
RULES="$KSU_SRC/selinux/rules.c"
if [ -f "$RULES" ] && ! grep -q "CONFIG_KSU_SUSFS" "$RULES" 2>/dev/null; then
    sed -i '/rcu_read_unlock();/i #ifdef CONFIG_KSU_SUSFS\n\tksu_allow(db, "zygote", "labeledfs", "filesystem", "unmount");\n#endif' "$RULES"
fi
echo "  selinux/rules.c done."

# ---- 7. Create susfs syscall hook (replaces old ksu_handle_prctl for v3.x) ----
echo "[+] Creating SUSFS syscall prctl handler..."
SUSFS_HOOK="$KSU_SRC/hook/susfs_cmd.c"
if [ ! -f "$SUSFS_HOOK" ]; then
cat > "$SUSFS_HOOK" << 'EOF'
// SUSFS command handler via KernelSU v3.x syscall hook mechanism
// This replaces the old ksu_handle_prctl approach for KernelSU v3.x
#include <linux/susfs.h>
#include <linux/prctl.h>
#include <linux/version.h>
#include <linux/uaccess.h>
#include <linux/syscalls.h>
#include "hook/syscall_hook.h"
#include "kernel_compat.h"
#include "klog.h"

#ifdef CONFIG_KSU_SUSFS

static int susfs_handle_prctl_cmd(int option, unsigned long arg2,
                                  unsigned long arg3, unsigned long arg5)
{
	if (current_uid().val != 0)
		return 0;

	int error = 0;

#ifdef CONFIG_KSU_SUSFS_SUS_PATH
	if (option == CMD_SUSFS_ADD_SUS_PATH) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_sus_path))) {
			pr_err("susfs: CMD_SUSFS_ADD_SUS_PATH -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_ADD_SUS_PATH -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_add_sus_path((struct st_susfs_sus_path __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

#ifdef CONFIG_KSU_SUSFS_SUS_MOUNT
	if (option == CMD_SUSFS_ADD_SUS_MOUNT) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_sus_mount))) {
			pr_err("susfs: CMD_SUSFS_ADD_SUS_MOUNT -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_ADD_SUS_MOUNT -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_add_sus_mount((struct st_susfs_sus_mount __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

#ifdef CONFIG_KSU_SUSFS_SUS_KSTAT
	if (option == CMD_SUSFS_ADD_SUS_KSTAT || option == CMD_SUSFS_ADD_SUS_KSTAT_STATICALLY) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_sus_kstat))) {
			pr_err("susfs: CMD_SUSFS_*_SUS_KSTAT -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_*_SUS_KSTAT -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_add_sus_kstat((struct st_susfs_sus_kstat __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
	if (option == CMD_SUSFS_UPDATE_SUS_KSTAT) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_sus_kstat))) {
			pr_err("susfs: CMD_SUSFS_UPDATE_SUS_KSTAT -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_UPDATE_SUS_KSTAT -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_update_sus_kstat((struct st_susfs_sus_kstat __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

#ifdef CONFIG_KSU_SUSFS_SUS_MAPS
	if (option == CMD_SUSFS_ADD_SUS_MAPS || option == CMD_SUSFS_ADD_SUS_MAPS_STATICALLY) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_sus_maps))) {
			pr_err("susfs: CMD_SUSFS_*_SUS_MAPS -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_*_SUS_MAPS -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_add_sus_maps((struct st_susfs_sus_maps __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
	if (option == CMD_SUSFS_UPDATE_SUS_MAPS) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_sus_maps))) {
			pr_err("susfs: CMD_SUSFS_UPDATE_SUS_MAPS -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_UPDATE_SUS_MAPS -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_update_sus_maps((struct st_susfs_sus_maps __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

#ifdef CONFIG_KSU_SUSFS_SPOOF_UNAME
	if (option == CMD_SUSFS_SET_UNAME) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_uname))) {
			pr_err("susfs: CMD_SUSFS_SET_UNAME -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_SET_UNAME -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_set_uname((struct st_susfs_uname __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

#ifdef CONFIG_KSU_SUSFS_TRY_UMOUNT
	if (option == CMD_SUSFS_ADD_TRY_UMOUNT) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_try_umount))) {
			pr_err("susfs: CMD_SUSFS_ADD_TRY_UMOUNT -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_ADD_TRY_UMOUNT -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_add_try_umount((struct st_susfs_try_umount __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

#ifdef CONFIG_KSU_SUSFS_SUS_PROC_FD_LINK
	if (option == CMD_SUSFS_ADD_SUS_PROC_FD_LINK) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_sus_proc_fd_link))) {
			pr_err("susfs: CMD_SUSFS_ADD_SUS_PROC_FD_LINK -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_ADD_SUS_PROC_FD_LINK -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_add_sus_proc_fd_link((struct st_susfs_sus_proc_fd_link __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

#ifdef CONFIG_KSU_SUSFS_SUS_MEMFD
	if (option == CMD_SUSFS_ADD_SUS_MEMFD) {
		if (!ksu_access_ok((void __user *)arg3, sizeof(struct st_susfs_sus_memfd))) {
			pr_err("susfs: CMD_SUSFS_ADD_SUS_MEMFD -> arg3 not accessible\n");
			return 0;
		}
		if (!ksu_access_ok((void __user *)arg5, sizeof(error))) {
			pr_err("susfs: CMD_SUSFS_ADD_SUS_MEMFD -> arg5 not accessible\n");
			return 0;
		}
		error = susfs_add_sus_memfd((struct st_susfs_sus_memfd __user *)arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

#ifdef CONFIG_KSU_SUSFS_ENABLE_LOG
	if (option == CMD_SUSFS_ENABLE_LOG) {
		if (arg3 != 0 && arg3 != 1) {
			pr_err("susfs: CMD_SUSFS_ENABLE_LOG -> arg3 can only be 0 or 1\n");
			return 0;
		}
		susfs_set_log(arg3);
		copy_to_user((void __user *)arg5, &error, sizeof(error));
		return 1;
	}
#endif

	return 0;
}

#ifdef CONFIG_KSU_SUSFS
#include <asm/ptrace.h>
// Architecture-specific register extraction for prctl syscall
// prctl(int option, unsigned long arg2, unsigned long arg3, ...)
static long susfs_prctl_dispatcher(int nr, const struct pt_regs *regs)
{
	if (nr != __NR_prctl)
		return 0; // Not our syscall, pass through

#ifdef __arm64__
	int option = regs->regs[0];
	unsigned long arg2 = regs->regs[1];
	unsigned long arg3 = regs->regs[2];
	unsigned long arg5 = regs->regs[4];
#elif defined(__arm__)
	int option = regs->ARM_r0;
	unsigned long arg2 = regs->ARM_r1;
	unsigned long arg3 = regs->ARM_r2;
	unsigned long arg5 = regs->ARM_r4;
#else
	int option = (int)regs->di;
	unsigned long arg2 = regs->si;
	unsigned long arg3 = regs->dx;
	unsigned long arg5 = regs->r8;
#endif

	if (susfs_handle_prctl_cmd(option, arg2, arg3, arg5))
		return 0; // SUSFS handled it

	return 0;
}
#endif // CONFIG_KSU_SUSFS

int __init susfs_hook_init(void)
{
#ifdef CONFIG_KSU_SUSFS
	int ret = ksu_register_syscall_hook(__NR_prctl, susfs_prctl_dispatcher);
	if (ret)
		pr_err("susfs: failed to register prctl hook: %d\n", ret);
	else
		pr_info("susfs: prctl hook registered\n");
	return ret;
#else
	return 0;
#endif
}

void __exit susfs_hook_exit(void)
{
#ifdef CONFIG_KSU_SUSFS
	ksu_unregister_syscall_hook(__NR_prctl);
#endif
}
EOF
fi

# Add susfs_cmd.o to Kbuild
if [ -f "$KBUILD" ] && ! grep -q "susfs_cmd" "$KBUILD" 2>/dev/null; then
    sed -i '/^ksu-objs/ s/$/ susfs_cmd.o/' "$KBUILD"
elif [ ! -f "$KBUILD" ]; then
    echo "ksu-objs += susfs_cmd.o" >> "$MAKEFILE"
fi
echo "  susfs_cmd.c created."

# ---- 8. Add susfs_hook_init() to core/init.c ----
if [ -f "$INITC" ] && ! grep -q "susfs_hook_init" "$INITC" 2>/dev/null; then
    sed -i '/^	ksu_core_init();/a #ifdef CONFIG_KSU_SUSFS\n\tsusfs_hook_init();\n#endif' "$INITC"
fi

echo "[+] SUSFS integration for KernelSU v3.x - COMPLETED"
