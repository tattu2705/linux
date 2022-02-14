#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[34m'
YELLOW='\033[1;33m'
ERR_FILE='greensql_errors.log'
ERR_LOG='>/dev/null 2>>'${ERR_FILE}
GREEN_DIR='greensql-fw-1.3.0'

yum_install() {
	echo -e ${YELLOW}[+]: ${BLUE}Fixing yum...
	wget https://raw.githubusercontent.com/phucdc-noob/Linux/main/CentOS-Base.repo -O /etc/yum.repo.d/CentOS-Base.repo ${ERR_LOG}
	yum clean all ${ERR_LOG}
	yum update -y  ${ERR_LOG}
}

install_requirements() {
	echo -e ${YELLOW}[+]: ${BLUE}Installing requirements...
 	yum install -y flex bison rpm-build postgresql-devel pcre-devel gcc gcc-c++ libevent-devel mysql-devel libevent mysql pcre postgresql-libs ${ERR_LOG}
	
	echo -e ${YELLOW}[+]: ${BLUE}Setting up MYSQL...
	chkconfig mysqld on ${ERR_LOG}
	service mysqld start ${ERR_LOG}
	mysql_secure_installation
}

install_greensql() {
	echo -e ${YELLOW}[+]: ${BLUE}Installing GreenSQL:
	wget https://github.com/phucdc-noob/Linux/raw/main/greensql-fw1.3.0.tar.gz ${ERR_LOG}
	tar -xf greensql-fw1.3.0.tar.gz ${ERR_LOG}
	make -C ${GREEN_DIR} ${ERR_LOG}
	make install -C ${GREEN_DIR} ${ERR_LOG}
	${GREEN_DIR}/build.sh ${ERR_LOG}
	mkdir /usr/share/doc/greensql-fw/ ${ERR_LOG}
	cp ${GREEN_DIR}/docs/* /usr/share/doc/greensql-fw/ ${ERR_LOG}
	mkdir /usr/share/greensql-fw/ ${ERR_LOG}
	cp ${GREEN_DIR}/greensql-console/config.php /usr/share/greensql-fw/ ${ERR_LOG}
	${GREEN_DIR}/scripts/setup_user.sh ${ERR_LOG}
	${GREEN_DIR}/scripts/setup_conf.sh ${ERR_LOG}
	${GREEN_DIR}/scripts/setup_log.sh ${ERR_LOG}
	${GREEN_DIR}/scripts/setup_binary.sh ${ERR_LOG}
	${GREEN_DIR}/scripts/greensql-create-db.sh 2>> ${ERR_FILE}
	/etc/init.d/greensql start
	
	echo ##############################################
	echo ${GREEN}Your log at /var/log/greensql.log:
	cat /var/log/greensql.log
}

## MAIN ##

# Check if run with sudo (root) permission
if [ "$(id -u)" != "0" ]; then
    echo
    echo "Please run this script as root"
    echo
    exit 1
fi


# Create new log file
if [ -f "$ERR_FILE" ]; then
    rm -f $ERR_FILE
fi

yum_install &&
install_requirements &&
install_greensql
