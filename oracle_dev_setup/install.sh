#!/bin/bash 

# 実行するとサイレントインストールが始まります。

ORACLE_PASSWWORD=password

# oracle
mkdir /xe_logs 
yum -y localinstall package/oracle-database-xe-18c-1.0-1.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
(echo $ORACLE_PASSWWORD; echo $ORACLE_PASSWWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1

# java
yum -y localinstall package/jdk-11.0.8_linux-x64_bin.rpm

# instanceの接続先の設定
su - vagrant -c "echo export ORACLE_SID=XE >> .bash_profile"
# su - vagrant -c "echo export ORAENV_ASK=NO >> .bash_profile"
# su - vagrant -c "source /opt/oracle/product/18c/dbhomeXE/bin/oraenv"

# oracleインストール先の設定
su - vagrant -c "echo　# config ORACLE_HOME >> .bash_profile"
su - vagrant -c 'echo export ORACLE_BASE=/opt/oracle >> .bash_profile'
su - vagrant -c 'echo export ORACLE_HOME=$ORACLE_BASE/product/18c/dbhomeXE >> .bash_profile'
su - vagrant -c 'echo export PATH=$PATH:$ORACLE_BASE/product/18c/dbhomeXE/bin >> .bash_profile'
su - vagrant -c "echo '' >> .bash_profile"

# sqlplusの文字コードの設定
su - vagrant -c "echo # sqlplus decoding >> .bash_profile"
su - vagrant -c "echo export NLS_LANG=Japanese_Japan.AL32UTF8 >> .bash_profile"
su - vagrant -c "echo '' >> .bash_profile"

# Oracle Databasesがシステム起動時に動くように自動化
systemctl daemon-reload
systemctl enable oracle-xe-18c

# oracle Databaseを起動。
systemctl start oracle-xe-18c

# Oracle Database EM Expressをvagrantの外(host側)から実行できる様にする。
su - vagrant -c "echo 'EXEC DBMS_XDB.SETLISTENERLOCALACCESS(FALSE);' | sqlplus system/$ORACLE_PASSWWORD"

# test用table作成
su - vagrant -c "sqlplus system/$ORACLE_PASSWWORD << END
CREATE TABLE test_table (
    id NUMBER GENERATED ALWAYS AS IDENTITY
    ,first_name VARCHAR2(30)
    ,second_name VARCHAR2(30)
    );
COMMIT;
"

# oracleにデータをimportする場合はoracle_data_loadから実行
