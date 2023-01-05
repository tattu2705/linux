## Allow directory listing all sub-dirs inside a path:

Example:

```
/var/www/html/
            ├── index.php
            └── upload/
                ├── Sub-1/
                │   
                ├── Sub-2/
                |
                └── ...other subs... 
```
To allow directory for all sub-dirs `Sub-1`, `Sub-2`, ..., `Sub-n` of `upload/`, add this in Apache's config file:

- Not allow dir-listing in `upload/`:

```
<Directory "/var/www/html/upload">
    Options -Indexes
</Directory>
```

- Allow dir-listing inside all `upload/`'s subs:

```
<DirectoryMatch  /var/www/html/upload/(.)*/>
        Options +Indexes
</DirectoryMatch>
```

- Save file, then `restart` Apache service.


Now, if we access to `/upload/`, we'll receive 403 error:

![image](https://user-images.githubusercontent.com/82533607/210752770-2877f7d4-e421-4249-bc45-655554c3ee8d.png)

But if we access to `/upload/Sub-1/`, we will see `Sub-1`'s list files:

![image](https://user-images.githubusercontent.com/82533607/210753554-d55c94f1-b7d1-4f40-a481-d9b840a3a363.png)

