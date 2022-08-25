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
