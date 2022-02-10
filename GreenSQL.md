> Install on CentOS 6.10

### 1. Fix yum repo when CentOS 6 is f**king End-of-Life:

Get the Base repo file:

```bash
wget https://phucdc-noob.github.io/CentOS-Base.repo -O /etc/yum.repo.d/CentOS-Base.repo
```

Clean yum and update:

```bash
yum clean all; yum update -y
```

### 2. Install requirements:

```bash
yum install -y flex bison rpm-build postgresql-devel pcre-devel gcc gcc-c++ libevent-devel mysql-devel libevent mysql pcre postgresql-libs
```

### 3. Configure MySQL

Turn on `mysqld` and start service:

```bash
chkconfig mysqld on
```

```bash
service mysql start
```

Start `mysql_secure_installation`, set up MySQL's root password:

```bash
mysql_secure_installation
```

> Note MySQL's root password you set in this step!

### 4. Install greensql-fw:

Download the tar file:

```bash
wget https://phucdc-noob.github.io/greensql-fw1.3.0.tar.gz
```

Extract it:

```bash
tar -xvzf greensql-fw1.3.0.tar.gz
```

Go to the extracted folder:

```bash
cd greensql-fw-1.3.0 
```

Compile the source:

```bash
make
```

```bash
make install
```

Start build file:

```bash
./build.sh
```

Hmm, idk wtf is going on, but we need to create some folder then move files to those folders ourselves:

```bash
mkdir /usr/share/doc/greensql-fw/
cp docs/* /usr/share/doc/greensql-fw/
mkdir /usr/share/greensql-fw/
cp greensql-console/config.php /usr/share/greensql-fw/
```

Run the final scripts:

- Setup user, config, log and bins for greensql:

```bash
cd scripts/
./setup_user.sh
./setup_conf.sh
./setup_log.sh
./setup_binary.sh
```

- Setup script for DB:

```bash
./greensql-create-db.sh
```

- Start greensql:

```bash
/etc/init.d/greensql start
```

- Check the log to see if we got some errors:

```bash
tail -f /var/log/greensql.log
```

> If output have only 1 line that have "Application started", bravo ~~~
> If there are some errors happens? Search yourself 
