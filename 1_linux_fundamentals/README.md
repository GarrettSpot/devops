# 1. Soft Link & Hard Link

```bash
~/practice ❯ echo "Hello World" > original.txt

~/practice ❯ ls -li
inode Permissions Size User Date Modified Name
98615 .rw-r--r--    12 adam  4 Sep 20:06   original.txt

~/practice ❯ ln original.txt hard.txt

~/practice ❯ ls -li
inode Permissions Size User Date Modified Name
98615 .rw-r--r--    12 adam  4 Sep 20:06   hard.txt
98615 .rw-r--r--    12 adam  4 Sep 20:06   original.txt

~/practice ❯ ln -s 
hard.txt      original.txt  

~/practice ❯ ln -s original.txt soft.txt

~/practice ❯ ls -li
inode Permissions Size User Date Modified Name
98615 .rw-r--r--    12 adam  4 Sep 20:06   hard.txt
98615 .rw-r--r--    12 adam  4 Sep 20:06   original.txt
98631 lrwxrwxrwx     - adam  4 Sep 20:06   soft.txt -> original.txt

~/practice ❯ rm original.txt 

~/practice ❯ cat hard.txt 
Hello World

~/practice ❯ cat soft.txt 
cat: soft.txt: No such file or directory
```

# 2 adduser vs useradd

useradd is a low-level Linux command used to create user accounts and provides more control through command-line options, making it useful for scripting and automation. adduser is a higher-level, more user-friendly utility that simplifies user creation by interactively setting up things like the home directory, password, and user information. On Ubuntu/Debian, adduser is commonly preferred for creating regular users, while on Arch-based systems such as Omarchy, useradd is the standard command.

Because I'm using an arch-based OS, I will be demonstrating useradd only:
```bash
~/practice ❯ sudo useradd -m -s /bin/bash testuser

~/practice ❯ sudo passwd testuser
New password: 
Retype new password: 
passwd: password updated successfully

~/practice ❯ is testuser
bash: command not found: is

~/practice ✗ id testuser
uid=1001(testuser) gid=1001(testuser) groups=1001(testuser)

```

# 3. journalctl
```bash

Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: > Warning:          Unsupported maximum keycode>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: >                   X11 cannot support keycodes>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: > Warning:          Virtual modifier Hyper mult>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: >                   Using 0, ignoring 0
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: > Warning:          Virtual modifier ScrollLock>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: >                   Using 0, ignoring 0
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: > Error:            Key <LFSH> added to map for>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: >                   Using Lock, ignoring Shift.
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220771]: Errors from xkbcomp are not fatal to the X serv>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220773]: The XKEYBOARD keymap compiler (xkbcomp) reports:
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220773]: > Warning:          Unsupported maximum keycode>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220773]: >                   X11 cannot support keycodes>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220773]: > Warning:          Virtual modifier Hyper mult>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220773]: >                   Using 0, ignoring 0
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220773]: > Warning:          Virtual modifier ScrollLock>
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220773]: >                   Using 0, ignoring 0
Sep 05 18:35:16 omarchy uwsm_hyprland.desktop[220773]: Errors from xkbcomp are not fatal to the X serv>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: The XKEYBOARD keymap compiler (xkbcomp) reports:
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: > Warning:          Unsupported maximum keycode>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: >                   X11 cannot support keycodes>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: > Warning:          Virtual modifier Hyper mult>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: >                   Using 0, ignoring 0
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: > Warning:          Virtual modifier ScrollLock>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: >                   Using 0, ignoring 0
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: > Error:            Key <LFSH> added to map for>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: >                   Using Lock, ignoring Shift.
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220775]: Errors from xkbcomp are not fatal to the X serv>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220777]: The XKEYBOARD keymap compiler (xkbcomp) reports:
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220777]: > Warning:          Unsupported maximum keycode>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220777]: >                   X11 cannot support keycodes>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220777]: > Warning:          Virtual modifier Hyper mult>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220777]: >                   Using 0, ignoring 0
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220777]: > Warning:          Virtual modifier ScrollLock>
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220777]: >                   Using 0, ignoring 0
Sep 05 18:35:17 omarchy uwsm_hyprland.desktop[220777]: Errors from xkbcomp are not fatal to the X serv>
Sep 05 18:35:19 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:35:19 omarchy bluetoothd[882]: Unable to create object for found device 41:1D:23:1A:18:46
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: The XKEYBOARD keymap compiler (xkbcomp) reports:
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: > Warning:          Unsupported maximum keycode>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: >                   X11 cannot support keycodes>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: > Warning:          Virtual modifier Hyper mult>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: >                   Using 0, ignoring 0
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: > Warning:          Virtual modifier ScrollLock>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: >                   Using 0, ignoring 0
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: > Error:            Key <LFSH> added to map for>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: >                   Using Lock, ignoring Shift.
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220786]: Errors from xkbcomp are not fatal to the X serv>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220788]: The XKEYBOARD keymap compiler (xkbcomp) reports:
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220788]: > Warning:          Unsupported maximum keycode>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220788]: >                   X11 cannot support keycodes>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220788]: > Warning:          Virtual modifier Hyper mult>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220788]: >                   Using 0, ignoring 0
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220788]: > Warning:          Virtual modifier ScrollLock>
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220788]: >                   Using 0, ignoring 0
Sep 05 18:35:21 omarchy uwsm_hyprland.desktop[220788]: Errors from xkbcomp are not fatal to the X serv>
Sep 05 18:35:27 omarchy kernel: [UFW BLOCK] IN=wlp0s20f3 OUT= MAC=33:33:00:00:00:01:f4:1e:57:3d:a6:d6:>

devops/1_linux_fundamentals main  ✗ journalctl -u bluetooth -n 50
Sep 05 18:36:14 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:14 omarchy bluetoothd[882]: Unable to create object for found device 4A:0D:23:1A:18:46
Sep 05 18:36:22 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:22 omarchy bluetoothd[882]: Unable to create object for found device 41:10:23:1A:18:46
Sep 05 18:36:34 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:34 omarchy bluetoothd[882]: Unable to create object for found device 41:11:23:1A:18:46
Sep 05 18:36:35 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:35 omarchy bluetoothd[882]: Unable to create object for found device 00:00:00:00:00:00
Sep 05 18:36:37 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:37 omarchy bluetoothd[882]: Unable to create object for found device 00:00:00:00:00:00
Sep 05 18:36:38 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:38 omarchy bluetoothd[882]: Unable to create object for found device 53:05:23:1A:18:46
Sep 05 18:36:38 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:38 omarchy bluetoothd[882]: Unable to create object for found device 00:00:00:00:00:00
Sep 05 18:36:39 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:39 omarchy bluetoothd[882]: Unable to create object for found device 00:00:00:00:00:00
Sep 05 18:36:40 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:40 omarchy bluetoothd[882]: Unable to create object for found device 00:00:00:00:00:00
Sep 05 18:36:50 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:50 omarchy bluetoothd[882]: Unable to create object for found device 53:12:23:1A:18:46
Sep 05 18:36:53 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:36:53 omarchy bluetoothd[882]: Unable to create object for found device 41:23:23:1A:18:46
Sep 05 18:37:02 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:37:02 omarchy bluetoothd[882]: Unable to create object for found device 4A:23:23:1A:18:46
Sep 05 18:37:14 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:37:14 omarchy bluetoothd[882]: Unable to create object for found device 41:12:23:1A:18:46
Sep 05 18:37:14 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:37:14 omarchy bluetoothd[882]: Unable to create object for found device 53:12:23:1A:18:46
Sep 05 18:37:20 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:37:20 omarchy bluetoothd[882]: Unable to create object for found device 4A:1B:23:1A:18:46
Sep 05 18:37:29 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:37:29 omarchy bluetoothd[882]: Unable to create object for found device 41:0F:23:1A:18:46
Sep 05 18:37:35 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:37:35 omarchy bluetoothd[882]: Unable to create object for found device 4A:1D:23:1A:18:46
Sep 05 18:37:44 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:37:44 omarchy bluetoothd[882]: Unable to create object for found device 41:1C:23:1A:18:46
Sep 05 18:37:50 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:37:50 omarchy bluetoothd[882]: Unable to create object for found device 41:1C:23:1A:18:46
Sep 05 18:38:14 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:38:14 omarchy bluetoothd[882]: Unable to create object for found device 53:00:23:1A:18:46
Sep 05 18:38:37 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:38:37 omarchy bluetoothd[882]: Unable to create object for found device 00:00:00:00:00:00
Sep 05 18:39:00 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:39:00 omarchy bluetoothd[882]: Unable to create object for found device 53:0D:23:1A:18:46
Sep 05 18:39:01 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:39:01 omarchy bluetoothd[882]: Unable to create object for found device 53:22:23:1A:18:46
Sep 05 18:39:25 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:39:25 omarchy bluetoothd[882]: Unable to create object for found device 53:1E:23:1A:18:46
Sep 05 18:39:30 omarchy bluetoothd[882]: src/device.c:device_new() Unable to register device interface>
Sep 05 18:39:30 omarchy bluetoothd[882]: Unable to create object for found device 68:1A:13:C9:18:46
```


