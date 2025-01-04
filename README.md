# Unraid-7.x-uasp-fix

Modifies the naming scheme for UASP enabled USB drives.

## Disclaimer

I know Unraid doesn't officially support using external USB HDDs for its array, but I'm not really one to follow the rules ;)

## The Problem

The new version of Unraid (7+) has UASP enabled in the kernel, which breaks the naming convention of USB drives from Unraid 6, so you can't start your array.

Unraid 6.x
![Unraid6](/assets/unraid6.png)
Unraid 7.x
![Unraid7](/assets/unraid7.png)

## How can I check if UASP is enabled?

You can check to see if UASP is enabled on your version of Unraid by running this in the terminal:
```sh
cat /usr/src/linux-6.6.66-Unraid/.config | grep USB_UAS
```
If the result is 
```sh
CONFIG_USB_UAS=y
```
Then UASP is enabled.

## Why don't I just disable UASP in Unraid 7 and get my disks back?
That's a valid solution if you just want to get it working as it was in Unraid 6. 
But you miss out on performance improvements and reduction of processing overhead. 
[What's the Difference Between USB UASP and BOT](https://www.electronicdesign.com/technologies/embedded/article/21800348/whats-the-difference-between-usb-uasp-and-bot)

If you really want to disable UASP, run the lsudb command:

```sh
lsusb -tvv
```

Then find the controller ID you are using. (In my case it's Via Labs 2109:0715)
```sh
...
Bus 002.Port 001: Dev 001, Class=root_hub, Driver=xhci_hcd/10p, 10000M
    ID 1d6b:0003 Linux Foundation 3.0 root hub
    /sys/bus/usb/devices/usb2  /dev/bus/usb/002/001
    |__ Port 006: Dev 002, If 0, Class=Hub, Driver=hub/4p, 10000M
        ID 2109:8822 VIA Labs, Inc. 
        /sys/bus/usb/devices/2-6  /dev/bus/usb/002/002
        |__ Port 001: Dev 004, If 0, Class=Mass Storage, Driver=uas, 10000M
            ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor
            /sys/bus/usb/devices/2-6.1  /dev/bus/usb/002/004
        |__ Port 002: Dev 005, If 0, Class=Mass Storage, Driver=uas, 10000M
            ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor
            /sys/bus/usb/devices/2-6.2  /dev/bus/usb/002/005
        |__ Port 003: Dev 006, If 0, Class=Mass Storage, Driver=uas, 10000M
            ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor
            /sys/bus/usb/devices/2-6.3  /dev/bus/usb/002/006
        |__ Port 004: Dev 007, If 0, Class=Mass Storage, Driver=uas, 10000M
            ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor
            /sys/bus/usb/devices/2-6.4  /dev/bus/usb/002/007
...
```

Then edit your syslinux.cfg file:
```sh
nano /boot/syslinux/syslinux.cfg
```
Add the following append entry "usb_storage.quirks=xxxx:xxxx:u" to your main Unraid OS menu item.   
(where xxxx:xxxx was your controller ID from earlier) 

```
default menu.c32
menu title Lime Technology, Inc.
prompt 0
timeout 50
label Unraid OS
  menu default
  kernel /bzimage
  append initrd=/bzroot usb_storage.quirks=2109:0715:u
label Unraid OS GUI Mode
  kernel /bzimage
  append initrd=/bzroot,/bzroot-gui
label Unraid OS Safe Mode (no plugins, no GUI)
  kernel /bzimage
  append initrd=/bzroot unraidsafemode
label Unraid OS GUI Safe Mode (no plugins)
  kernel /bzimage
  append initrd=/bzroot,/bzroot-gui unraidsafemode
label Memtest86+
  kernel /memtest
```
```
Ctrl-X, Y to save.
```
Reboot your system and now UASP should be disabled.

## Understanding the problem:

Let's take a look at how my disk setup was named in Unraid 6:
```sh
tree /dev/disk/
...
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
...
```
Looks normal, right.

And this is how it looks in Unraid 7:
```sh
tree /dev/disk/
...
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
...
```
Hmm..slight issue with the naming of my disks.  
My HDD's are reporting their SCSI identifier instead of their serial number, so unraid can't find the right disks to allocate to my array.

## Let's go down the rabbit hole and see how Unraid allocates the naming scheme of the disks.

Unraid uses "udevadm" along with a set of rules "/lib/udev/rules.d/60-persistent-storage.rules" to create the naming scheme.  
Luckily for us, we can "overwrite" the rules by placing a new version in "/etc/udev/rules.d/" while leaving the original untouched.





