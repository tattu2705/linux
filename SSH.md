Use SSH key to connect to remote server:

- Generate SSH Key pair in local machine:

```console
user@localhost:$ ssh-keygen -t rsa -b 4096 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa): ./remote-server-key
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/user/remote-server-key
Your public key has been saved in /home/user/remote-server-key.pub
The key fingerprint is:
SHA256: <random string> user@localhost
The key's randomart image is:
+---[RSA 4096]----+
|   .  . .+%O==+=+|
|         **Bo +=B|
|         ==   E.+|
|        o o+ . +.|
|        S+. + + *|
|       ... o + oo|
|          . o    |
|                 |
|                 |
+----[SHA256]-----+
```

- Send `remote-server-key.pub` to `user@remote-server:~/.ssh/` by `scp` or anything fucking thing.

```console
user@localhost:$ scp remote-server-key.pub user@remote-server:~/.ssh 
The authenticity of host 'remote-server' can't be established.
ECDSA key fingerprint is SHA256:<a random string>.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'remote-server' (ECDSA) to the list of known hosts.
user@remote-server's password: 
remote-server-key.pub                                                                                                       100%  740     1.2MB/s   00:00
```

- Try to connect to server by normal SSH.
