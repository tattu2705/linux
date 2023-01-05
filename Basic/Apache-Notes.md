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
