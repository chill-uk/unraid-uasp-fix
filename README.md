# Unraid-7.x-uasp-fix
Modifies the naming scheme for UASP enabled usb drives

Disclaimer:
I know Unraid doesn't officially support using external USB HDD's for it's array, but I'm not really one to follow the rules ;)

The problem:
The new version of Unraid (7+) has UASP enabled in the kernel, which breaks the naming convention of USB drives from Unraid 6.

Hint!:
You can check to see if UASP is enabled on your version of Unraid by running this in the terminal:
cat /usr/src/linux-6.6.66-Unraid/.config | grep USB_UAS
If the result is "CONFIG_USB_UAS=y", then UASP is enabled.

Why don't I just disable UASP in Unraid 7 and get my disks back?
That's a valid solution if you just want to get it working as it was in Unraid 6. 
But you miss out on performance improvements and reduction of processing overhead. (See the following link)
https://www.electronicdesign.com/technologies/embedded/article/21800348/whats-the-difference-between-usb-uasp-and-bot

Understanding the problem:

Let's take a look at how my disk setup was named in Unraid 6:

├── by-id
│   ├── ata-Samsung_SSD_870_QVO_2TB_XXXXXXXR810022M -> ../../sdf
│   ├── ata-Samsung_SSD_870_QVO_2TB_XXXXXXXR810022M-part1 -> ../../sdf1
│   ├── ata-TOSHIBA_MG08ACA16TE_XXXXXXX4FVGG -> ../../sde
│   ├── ata-TOSHIBA_MG08ACA16TE_XXXXXXX4FVGG-part1 -> ../../sde1
│   ├── ata-TOSHIBA_MG08ACA16TE_XXXXXXXEF57H -> ../../sdd
│   ├── ata-TOSHIBA_MG08ACA16TE_XXXXXXXEF57H-part1 -> ../../sdd1
│   ├── ata-TOSHIBA_MG08ACA16TE_XXXXXXXMF57H -> ../../sdb
│   ├── ata-TOSHIBA_MG08ACA16TE_XXXXXXXMF57H-part1 -> ../../sdb1
│   ├── ata-TOSHIBA_MG08ACA16TE_XXXXXXXDFVGG -> ../../sdc
│   ├── ata-TOSHIBA_MG08ACA16TE_XXXXXXXDFVGG-part1 -> ../../sdc1

Looks normal, right.

And this is how it looks in Unraid 7:

├── by-id
│   ├── ata-Samsung_SSD_870_QVO_2TB_XXXXXXXR810022M -> ../../sdf
│   ├── ata-Samsung_SSD_870_QVO_2TB_XXXXXXXR810022M-part1 -> ../../sdf1
│   ├── usb-TOSHIBA_MG08ACA16TE_0000000000000001-0:0 -> ../../sda
│   ├── usb-TOSHIBA_MG08ACA16TE_0000000000000001-0:0-part1 -> ../../sda1
│   ├── usb-TOSHIBA_MG08ACA16TE_0000000000000002-0:0 -> ../../sdb
│   ├── usb-TOSHIBA_MG08ACA16TE_0000000000000002-0:0-part1 -> ../../sdb1
│   ├── usb-TOSHIBA_MG08ACA16TE_0000000000000003-0:0 -> ../../sdc
│   ├── usb-TOSHIBA_MG08ACA16TE_0000000000000003-0:0-part1 -> ../../sdc1
│   ├── usb-TOSHIBA_MG08ACA16TE_0000000000000004-0:0 -> ../../sdd
│   ├── usb-TOSHIBA_MG08ACA16TE_0000000000000004-0:0-part1 -> ../../sdd1

Hmm..slight issue with the naming of my disks.
My HDD's are reporting their SCSI identifier instead of their serial number, so unraid can't find the right disks to allocate to my array.

Let's go down the rabbit hole and see how Unraid allocates the naming scheme of the disks.

Unraid uses "udevadm" with a set of rules "/lib/udev/rules.d/60-persistent-storage.rules" to create the naming scheme.
Luckily for us, we can "overwrite" the rules by placing a new version in "/etc/udev/rules.d/" while leaving the original untouched.





