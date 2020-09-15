#!/bin/bash 

# 実行するとサイレントインストールが始まります。

ORACLE_PASSWWORD=password

# oracle
mkdir /xe_logs
yum -y localinstall package/oracle-database-xe–18c-1.0-1.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
(echo $ORACLE_PASSWWORD; echo $ORACLE_PASSWWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1

# oracle instance client basic package
yum -y localinstall oracle-instantclient19.8-basic-19.8.0.0.0-1.x86_64.rpm

# sqlplus
yum -y localinstall oracle-instantclient19.8-sqlplus-19.8.0.0.0-1.x86_64.rpm

# java
yum -y localinstall package/jdk-11.0.8_linux-x64_bin.rpm

su - vagrant -c "echo export ORACLE_SID=XE >> .bash_profile"
su - vagrant -c "echo export ORAENV_ASK=NO >> .bash_profile" 
# su - vagrant -c ". /opt/oracle/product/18c/dbhomeXE/bin/oraenv"

# vagrantの外から