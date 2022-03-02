## DBS: DB Server settings & remote access

> You need to setup mysql before following this instruction.

![image](https://user-images.githubusercontent.com/82533607/156400416-deb3e2fc-4ac3-4d70-87a3-8415d76dbd64.png)

### Requirements

Set up 2 host-only network adapter `vmnet2` and `vmnet3` in VMWare (Edit -> Virtual Network Editor), for example, my settings:

![image](https://user-images.githubusercontent.com/82533607/156380971-70a68209-563e-41fd-99a9-a02ad2224485.png)

* In GreenSQL's server, use 2 adapter `vmnet2` and `vmnet3`:

![image](https://user-images.githubusercontent.com/82533607/156381563-933c713f-8eb4-4f11-9b4b-5cf90d143ef9.png)

> We will use `vmnet2` address for clients to remote access, `vmnet3` to connect to DB Server.

* In DB Server, use `vmnet3` only:

![image](https://user-images.githubusercontent.com/82533607/156382047-9367090d-0035-4c41-bd40-ba1c9ceb366e.png)

* Note down those IP address.

### Set up DB server for remote access

- Access to `root` account of mysql on DB Server

```bash 
mysql -u root -p
```

- Create an user for remote access:

```bash 
create user 'username'@'%' identified by 'password';
grant all privileges on *.* to 'username'@'%';
flush privileges;
```

![image](https://user-images.githubusercontent.com/82533607/156383883-ec0d52da-5f90-40d6-ab6e-daaa44430558.png)

> Enter `quit` to quit out of mysql console, now, we need to make some changes to `iptables`

- Delete all rules:

```bash
iptables --flush
service iptables save
```

- Add rule to allow port 3306 (default port of MySQL):

```bash 
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
service iptables save
service iptables stop
service iptables start
```

- To check if rule updated:

```bash 
iptables -L
```

![image](https://user-images.githubusercontent.com/82533607/156385263-1f0f7c0f-7f62-41c2-84ae-51cfc18687b8.png)

- Now, come to the GreenSQL Server, test the remote account:

```bash 
mysql -u <username> -p -h <vmnet3_IP_of_DB_Server>
```

![image](https://user-images.githubusercontent.com/82533607/156385909-584b954f-eff4-456c-94d7-005ec850f613.png)

### Set up GreenSQL Proxy:

- Go to GreenSQL's web console, log in. Then move to Databases, in the List of Proxies, choose Settings in `mysql` row:

    - Frontend IP: `vmnet2` IP of GreenSQL Server.

    - Frontend port: 3305

    - Backend server name: hostname of DB Server.

    - Backend IP: `vmnet3` IP of DB Server

    - Backend port: 3306

- Then Submit, restart GreenSQL service:

```bash 
/etc/init.d/greensql stop
/etc/init.d/greensql start
```

- Back to GreenSQL's web console, we will see `mysql` row's status is `Active`:

![image](https://user-images.githubusercontent.com/82533607/156388351-d8dbf3ab-d8d1-48c1-93fb-7aadaf2b3285.png)

- Add `iptables` rule to open port `3305`:

```bash 
iptables --flush
service iptables save
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
service iptables save
service iptables stop
service iptables start
```

### Test remote access to DB Server over GreenSQL's proxy

- In your real (host) machine, `mysql client` should be installed already.

- Now, time to test:

```bash 
mysql -u <username> -p -h <vmnet2_IP_GreenSQL_Server> -P 3305
```

![image](https://user-images.githubusercontent.com/82533607/156391067-2ef7072a-6b46-4f89-9288-5423c33c10a3.png)
