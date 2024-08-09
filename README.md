# NTFS / NTFS3 Read-Write file system support
Windows OS native file system (NTFS) support up to NTFS version 3.1.

This driver is the original driver from Kernel Sources and made in form of DKMS to be build on systems that are not shipped yet with NTFS3 driver, like Debian.

Because each major Kernel release could happend to have API/ABI change, I need to add the driver for that specific major release in a different directory.
A driver from a previous or later kernel version most of the time can't be compiled to a newer specific Kernel version.

In case the DKMS doesn't include a specific A.B version of Kernel driver, just create a folder under ntfs3/ named A.B (Major and Minor version of the Kernel) and add from Kernel sources
the driver found under linux-A.B.C/fs/ntfs3.

My mission is to keep this driver updated with latest versions of NTFS3 until the distributions are compiling them by default.
