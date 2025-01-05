# Unraid-7.x-uasp-fix

Modifies the naming scheme for UASP enabled USB drives.

## Disclaimer

I know Unraid doesn't officially support using external USB HDDs for its array, but I'm not really one to follow the rules ;)

Also, I found this post on reddit that acted as the basis of this fix:
[the_dreaded_usb_das_enclsoure_and_none_reporting](https://www.reddit.com/r/unRAID/comments/1fpi8ps/the_dreaded_usb_das_enclsoure_and_none_reporting/)  
Thanks [wlatic](https://www.reddit.com/user/wlatic/)!

- DO THIS AT YOUR OWN RISK -
I AM NOT RESPONSIBLE IF YOU DESTROY YOUR ARRAY AND ALL OF YOUR FILES!

## The Problem

The new version of Unraid (7+) has UASP enabled in the kernel, which might break the naming convention of your USB drives, making your array configuration invalid.

Unraid 6.x
![Unraid6](/assets/unraid6.png)
Unraid 7.x
![Unraid7](/assets/unraid7.png)

### Solutions

There are 2 workarounds:
* Disabling UASP
  * That's a valid solution if you just want to get it working as it was in Unraid 6. 
But you miss out on performance improvements and reduction of processing overhead. 
[What's the Difference Between USB UASP and BOT](https://www.electronicdesign.com/technologies/embedded/article/21800348/whats-the-difference-between-usb-uasp-and-bot)

* Modifying the storage naming logic.
  * It's a slightly more involved and you may need to re-apply the fix everytime you update unraid.
  * You get all of the added benefits of UASP.

For both, you will first need to find the problamatic USB controller ID.

### Finding your USB controller ID

Run this in the terminal of your Unraid server:  

```sh
lsusb -vvt | awk '/Class=Mass Storage, Driver=uas/ {print; getline; print}'
```

Then find the controller ID you are using. 

```sh
|__ Port 001: Dev 004, If 0, Class=Mass Storage, Driver=uas, 10000M
    ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor
|__ Port 002: Dev 005, If 0, Class=Mass Storage, Driver=uas, 10000M
    ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor
|__ Port 003: Dev 006, If 0, Class=Mass Storage, Driver=uas, 10000M
    ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor
|__ Port 004: Dev 007, If 0, Class=Mass Storage, Driver=uas, 10000M
    ID 2109:0715 VIA Labs, Inc. VL817 SATA Adaptor
```

Note the ID values down.  
(In my case it's a Via Labs "2109:0715")  

# Option (1) Disabling UASP in Unraid 7.

Now that you have the [USB controller ID's](#Finding-your-USB-controller-ID), we need to modify the syslinux.cfg file:

Open the syslinux.cfg file in nano

```sh
nano /boot/syslinux/syslinux.cfg
```

Add the following append entry "usb_storage.quirks=xxxx:xxxx:u" to your main Unraid OS menu item.   
(where xxxx:xxxx is your controller ID from earlier) 

For example..  
From this:
```
default menu.c32
menu title Lime Technology, Inc.
prompt 0
timeout 50
label Unraid OS
  menu default
  kernel /bzimage
  append initrd=/bzroot
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
To this:
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
Ctrl-X, Y, ENTER to save.
```
NOTE: DO NOT REMOVE OR EDIT ANY OTHER PART OF THIS FILE!

Reboot your system and now UASP should be disabled.

# Option (2) Modifying udevadm to work with UASP:

## A Quick note about udevadm and .rules files.

Unraid uses ```"udevadm"``` along with a set of rules ```"/lib/udev/rules.d/60-persistent-storage.rules"``` to create the naming scheme for disks.  
Luckily for us, we can "overwrite" the rules by placing a new version in "/etc/udev/rules.d/" while leaving the original in "/lib/udev/rules.d" untouched.  
```Any rules in "/etc/udev/rules.d/" take priority over the ones stored in "/lib/udev/rules.d"```

## Download the neccesary files from Github.

All of the files needed are as follows:

* boot/config/go  <-- Replacemnt go file to re-apply the custom files on boot.
* boot/config/custom_scripts/get_hdd_info.sh <-- Retrieves the disk serial numbers via smrtctl/hdparm
* rules.d/60-persistent-storage.rules <-- Contains the new disk allocation rules
  
You can use the following setup script to automatically install the files:

```sh
wget -qO- "https://raw.githubusercontent.com/chill-uk/unraid-uasp-fix/refs/heads/main/setup.sh" | bash
```

Or you can manually copy the files into the boot folder (keeping the same folder structure as the repo).

Now we need to modify the "/boot/config/rules.d/60-persistent-storage.rules" file to add our USB controller ID.

```bash
nano /boot/config/rules.d/60-persistent-storage.rules
```

Go to line 62 and change the ATTRS{idProduct}=="xxxx", ATTRS{idVendor}=="xxxx" values to the ones of your USB Controller  
[Finding your USB controller ID's](#Finding-your-USB-controller-ID)

For example, my entry is as follows:

```
# Override for VIA Labs 2109:0715
KERNEL=="sd*[!0-9]|sr*", ENV{ID_SERIAL}!="?*", ATTRS{idProduct}=="0715", ATTRS{idVendor}=="2109", SUBSYSTEMS=="usb", IMPORT{program}="/usr/local/bin/get_hdd_info.sh $devnode", ENV{ID_BUS}="usb"
```

```
Ctrl-X, Y, ENTER to save.
```

## Testing

We can test that it's all working by running the follwing commands in the terminal:

```sh
udevadm control --reload-rules
udevadm trigger
cat /var/log/syslog | grep "/dev/sd*"
```

You should get something like the following output:

```
DevNode: /dev/sdd, Name: TOSHIBA_MG08ACA16TE_XXXXXXX4FVGG
DevNode: /dev/sda, Name: TOSHIBA_MG08ACA16TE_XXXXXXXMF57H
DevNode: /dev/sdb, Name: TOSHIBA_MG08ACA16TE_XXXXXXXDFVGG
DevNode: /dev/sdc, Name: TOSHIBA_MG08ACA16TE_XXXXXXXEF57H
```

And your drives should show up in your array in unraid.  
(You might need to refresh the page)

You won't need to run these commands on every boot, as they are added to your go file and run on boot.

## Bonus: How can I check if UASP is enabled?

You can check to see if UASP is enabled on your version of Unraid by running this in the terminal:  

```sh
cat /usr/src/linux-6.6.66-Unraid/.config | grep USB_UAS
```
If the result is 
```sh
CONFIG_USB_UAS=y
```
Then UASP is enabled.
