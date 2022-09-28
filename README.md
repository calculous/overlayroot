# overlayroot

mounts an overlay filesystem over the root filesystem

I use this for my Raspberry Pi, but it should work on any Debian or derivative.

The root file system on the sd-card is mounted read-only on /overlay/lower, and / is a
read-write copy on write overlay.

## How to install:
Setup should work for Raspbian, Armbian and Ubuntu (x86/arm) releases.
```bash
git clone https://github.com/Gronis/overlayroot.git
cd overlayroot
sudo bash -c "cat `pwd`/.bashrc >> /root/.bashrc"
cat .bashrc >> ~/.bashrc
sudo cp 40-ram-filesystem /etc/update-motd.d/
sudo ./enableoverlayroot
sudo reboot
```
If not, check further down how to do the steps manually.

## How to use:

After rebooting, the root filesystem should be an overlay. This is indicated with
in the message of the day when loggin in:
```
NOTE:
  This system is running overlayroot to protect the sd card.
  All changes to / are stored in ram and reset after boot.
  use rootwork script to disable until reboot.

  Use disableoverlayroot to completly disable even after
  reboot. Remember to enable again with enableoverlayroot.
```

If it's on tmpfs any changes made will be lost after a reboot. If you want to upgrade
packages, for example, run `rootwork`, the prompt should prepend a warning sign
indicating / is unprotected.
```bash
[⚠️ ] :#
```

You're now making changes to the sdcard, and changes will be permanent.

The /run directory is problematic to umount, so atm `rootwork` --rbind mounts it
on the sd-card root file system, /overlay/lower, and it isn't umounted like /boot 
/proc /sys and /dev are.

After you've finished working on the sd-card run `exit`. `rootwork` tries to clean up 
by umounting all the mounts it mounted and remount /overlay/lower read-only, but 
often it can't due to an open file or something else causing the filesystem to be busy.
It's probably a good idea to reboot now for 2 reasons:
 
- leaving /overlay/lower read-write could cause file corruption on power loss. 
- to test it still boots ok after the changes you've just made.

If you want to disable overlay root even after boot. Run `disableoverlayroot`
when you are doing `rootwork`. After rebooting the message of the day will
look like this instead:
```
WARNING:
  This system's sd card is not protected. Run enableoverlayroot
  to enable protection after next reboot.
```

## Manual install: Raspbian

It uses initramfs. Stock Raspbian doesn't use one so step one would be to get initramfs working. 
Something like:

```bash
sudo mkinitramfs -o /boot/init.gz
```

Add to /boot/config.txt
```bash
initramfs init.gz
```

Test the initramfs works by rebooting. It should boot as normal.

Add the following line to /etc/initramfs-tools/modules
```
overlay
```

Copy the following files
- hooks-overlay to /etc/initramfs-tools/hooks/
- init-bottom-overlay to /etc/initramfs-tools/scripts/init-bottom/

install busybox
```bash
sudo apt-get install busybox
```

then rerun

```bash
sudo mkinitramfs -o /boot/init.gz
```
Now skip down to [all distributions](#all-distributions) to finish the installation.

## Manual install: Armbian and Ubuntu

Add the following line to /etc/initramfs-tools/modules
```
overlay
```

Copy the following files
- hooks-overlay to /etc/initramfs-tools/hooks/
- init-bottom-overlay to /etc/initramfs-tools/scripts/init-bottom/

install busybox-static
```bash
sudo apt-get install busybox-static
```

then run

```bash
sudo update-initramfs -k $(uname -r) -u
```


## Caveats

Whenever the kernel is updated, for Raspbian you need to rerun 

```bash
sudo mkinitramfs -o /boot/init.gz
```

and for Armbian and Ubuntu

```bash
sudo update-initramfs -k $(uname -r) -u
```

TODO: see if there's a hook to automatically run `sudo mkinitramfs -o /boot/init.gz` 
on kernel install

