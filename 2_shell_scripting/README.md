# Output
```
devops/2_shell_scripting main ? ✗ sudo chmod u+x sysinfo.sh 

devops/2_shell_scripting main ? ❯ ./sysinfo.sh
Enter a directory name: testing   
===== System Information =====
Date: Fri Sep  4 09:13:35 PM IST 2026
Hostname: omarchy
Username: adam

===== Disk Usage =====
Filesystem               1K-blocks     Used Available Use% Mounted on
dev                        7878804        0   7878804   0% /dev
run                        7964508     1976   7962532   1% /run
efivarfs                       268      256         8  98% /sys/firmware/efi/efivars
/dev/mapper/omarchy_root 266319872 34850576 230179664  14% /
tmpfs                      7964508   159584   7804924   3% /dev/shm
none                          1024        0      1024   0% /run/credentials/systemd-journald.service
none                          1024        0      1024   0% /run/credentials/systemd-resolved.service
/dev/mapper/omarchy_root 266319872 34850576 230179664  14% /home
/dev/mapper/omarchy_root 266319872 34850576 230179664  14% /var/cache/pacman/pkg
tmpfs                      7964512    50684   7913828   1% /tmp
/dev/mapper/omarchy_root 266319872 34850576 230179664  14% /var/log
/dev/nvme0n1p4             2093048   168200   1924848   9% /boot
tmpfs                      1592900    19788   1573112   2% /run/user/1000

===== Running Processes =====
    PID TTY          TIME CMD
 132776 pts/3    00:00:00 bash
 144267 pts/3    00:00:00 sysinfo.sh
 144393 pts/3    00:00:00 ps

Running processes have been saved to testing/processes.txt
```

