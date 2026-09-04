# 1. Soft Link & Hard Link

```
```
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
```
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

