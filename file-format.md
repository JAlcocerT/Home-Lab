# Filesystem Guide for Docker & Home-Labs

This document explains the differences between filesystem formats, specifically why **ExFAT** caused issues with Nextcloud and which formats are better for a Linux-based home-lab.

## The ExFAT "Permission Problem"

ExFAT (Extended File Allocation Table) was created for SD cards and USB drives. 

While it's great for moving files between Windows, Mac, and Linux, it lacks the core "metadata" that Linux depends on.

### Why Nextcloud failed on ExFAT:

1.  **No Symlinks**: Linux uses symlinks as "short-cuts" for its internal code libraries. ExFAT cannot store these, so the `rsync` command in the official Nextcloud image crashes.
2.  **No Linux Permissions**: Linux uses `rwxr-xr-x` to handle security. ExFAT just sees "a file." When Docker tries to `chown` (change owner) to `www-data`, ExFAT ignores it, causing an "Operation not permitted" error.
3.  **No Hardlinks**: Many Docker imaging tools (like `docker build`) depend on hardlinks for efficiency, which ExFAT doesn't support.

---

## Filesystem Comparison

| Format | Best For | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Ext4** | **Linux System Drive** | Standard, fast, stable, supports local Linux permissions/symlinks. | Not readable by Windows without special software. |
| **ExFAT** | **USB Sticks / SD Cards** | Works everywhere (Win/Mac/Linux). Simple. | **Poor for Docker.** No permissions, no symlinks, high risk of corruption on power loss. |
| **Btrfs** | **Advanced Storage** | Snapshots (back up in seconds), easy to expand disks. | Slightly more complex to manage than Ext4. |
| **ZFS** | **Professional NAS (TrueNAS)** | Maximum data safety (Check-summing), extremely powerful. | Requires a lot of RAM; complex to set up. |
| **NTFS** | **Windows Data Drive** | Native to Windows; better than ExFAT for large files. | Linux drivers are slower than Ext4; permission mapping can be tricky in Docker. |

---

## Data Corruption & Reliability

How safe is your data if the power goes out or a disk starts failing?

### 1. The Gold Standard: ZFS & Btrfs
These are **Copy-on-Write (CoW)** filesystems with **Checksums**.
*   **Checksums**: They store a "fingerprint" of every file. If a bit flips (bit rot), the filesystem detects it immediately.
*   **CoW**: They never overwrite data in place. If a power cut happens while writing, the old version remains intact.

### 2. The Reliable Standard: Ext4
Uses a **Journal**.
*   **Journaling**: Before making a change, it writes the intention to a "log." If power fails, it reads the log to repair itself.
*   **Limitation**: It doesn't detect "bit rot" (silent data corruption) like ZFS does.

### 3. The Risky Zone: ExFAT
**No Journaling, No Checksums.**
*   **Corruption Risk**: High. If you pull the USB plug or lose power while writing, the "File Allocation Table" can become inconsistent. This often leads to the folder becoming "RAW" or unreadable.
*   **Recovery**: Very difficult on Linux; usually requires Windows `chkdsk`.

---

### 1. If you are starting fresh:

Format your 1TB/2TB drives as **Ext4**. It is the native language of Linux and Docker. You will never have "Permission denied" or "Symlink failed" errors.

### 2. If you must use ExFAT (because of existing data):

You **must** use images from **LinuxServer.io**. These images use `PUID=1000` and `PGID=1000` to "identity match" your user, bypassing the need for the drive to support Linux-style permission changes.

### 3. How to check your current format:

```bash
lsblk -f
```
Look for the `FSTYPE` column.