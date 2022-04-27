## Install DVWA in Debian-based Distros

### Pre-requirements:

```bash
sudo apt update -y && sudo apt upgrade -y
```

- Install requirements:

  ```bash
  sudo apt-get -y install apache2 mariadb-server php php-mysqli php-gd libapache2-mod-php
  ```

- Setup MariaDB:

  ```bash
  sudo systemctl enable --now mariadb
  sudo mysql_secure_installation
  ```
  
  Enter, then `y`, press `y` again, now setup the root password of MariaDB. After setting up the password, press `y` to all questions.
  
- Setup `dvwa` user for DVWA:

  ```bash
  mysql -u root -p
  ```
  
  - Enter the password you set above, then:
  
    ```mysql
    create database dvwa;
    ```
  
    ```mysql
    create user dvwa@localhost identified by 'p@ssw0rd';
    ```
    
    ```mysql 
    grant all on dvwa.* to dvwa@localhost;
    ```
    
    ```mysql 
    flush privileges;
    ```
    
    ```mysql 
    exit;
    ```
    
    ![ảnh](https://user-images.githubusercontent.com/82533607/165560662-ae7685ca-561d-4886-bc9f-1b0cdb93c380.png)

- Download DVWA from [this link](https://github.com/digininja/DVWA/archive/master.zip)

- Time to setup:

  ```bash
  sudo unzip ~/Downloads/DVWA-master.zip -d /var/www/html/
  sudo mv /var/www/html/DVWA-master/ /var/www/html/dvwa
  sudo mv /var/www/html/dvwa/config/config.inc.php.dist /var/www/html/dvwa/config/config.inc.php
  sudo sed -i 's,allow_url_include = Off,allow_url_include = On,g' /etc/php/<php_version>/apache2/php.ini
  sudo systemctl enable --now apache2
  ```
  
  - Go to `http://localhost/dvwa/setup.php`, press on `Create / Reset database` button, if ok, it will auto redirect to login page:

  ![ảnh](https://user-images.githubusercontent.com/82533607/165562045-f7847933-44ac-44fd-9db4-90f957e12480.png)

  - Default credential: `admin/password`
