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

# SUID

