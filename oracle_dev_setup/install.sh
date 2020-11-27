#!/bin/bash 

# 実行するとサイレントインストールが始まります。

ORACLE_PASSWWORD=xkhxnv08WOuhbgtdwpq

# oracle
mkdir /xe_logs 
yum -y localinstall package/oracle-database-xe-18c-1.0-1.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-18c.conf
(echo $ORACLE_PASSWWORD; echo $ORACLE_PASSWWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1


echo '# set oracle environment variable'  >> ~/.bash_profile
echo 'export ORACLE_SID=XE'  >> ~/.bash_profile
echo 'export ORAENV_ASK=NO'  >> ~/.bash_profile
echo 'export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE' >> ~/.bash_profile
echo 'export ORACLE_BASE=/opt/oracle  >> ~/.bash_profile' >> ~/.bash_profile
echo 'export PATH=$PATH:$ORACLE_HOME/bin' >> ~/.bash_profile
echo '' >> ~/.bash_profile

# reload bash environment.
source ~/.bash_profile

# vagrant 
su - vagrant -c 'echo "# set oracle environment variable"  >> ~/.bash_profile'
su - vagrant -c 'echo export ORACLE_SID=XE >> ~/.bash_profile'
su - vagrant -c 'echo export ORAENV_ASK=NO >> ~/.bash_profile'
su - vagrant -c 'echo export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE >> ~/.bash_profile'
su - vagrant -c 'echo export ORACLE_BASE=/opt/oracle  >> ~/.bash_profile'
su - vagrant -c 'echo "export PATH=$PATH:$ORACLE_HOME/bin" >> ~/.bash_profile'
su - vagrant -c 'echo "" >> ~/.bash_profile'

# sqlplusの文字コードの設定
su - vagrant -c 'echo "# sqlplus decoding" >> ~/.bash_profile'
su - vagrant -c 'echo export NLS_LANG=Japanese_Japan.AL32UTF8 >> ~/.bash_profile'
su - vagrant -c 'echo "" >> ~/.bash_profile'

# python3 << END
# import pexpect, sys
# ORACLE_HOME = "/opt/oracle/product/18c/dbhomeXE"

# shell_cmd = "/opt/oracle/product/18c/dbhomeXE/bin/oraenv"
# prc = pexpect.spawn('/bin/bash', ['-c', shell_cmd])
# # prc = pexpect.spawn('source', [shell_cmd])
# # prc.logfile_read = sys.stdout

# prc.expect('ORACLE_HOME = \[\]')
# prc.sendline(ORACLE_HOME)

# prc.expect( pexpect.EOF )

# END

# java
yum -y localinstall package/jdk-11.0.8_linux-x64_bin.rpm

# Oracle Databasesがシステム起動時に動くように自動化
systemctl daemon-reload
systemctl enable oracle-xe-18c

# oracle Databaseを起動。
systemctl start oracle-xe-18c

user=general
user_password="tfrkBi1qzxIkwg0ohpb"
# 右のようにlocalhost以外は禁止されているデフォルトではsqlplus system@"dbhost.example/XE"
sqlplus system/$ORACLE_PASSWORD@localhost/XE << END
// Oracle Database EM Expressをvagrantの外(host側)から実行できる様にする。
EXEC DBMS_XDB.SETLISTENERLOCALACCESS(FALSE);

// CONNECT PDB FOR CREATE USER AND CREATE
ALTER SESSION SET container = XEPDB1;
// CREATE USER
CREATE USER $user
  IDENTIFIED BY $user_password
  // DEFAULT TABLESPACE USER01
  // TEMPORARY TABLESPACE temp
  // QUOTA 50M ON USER01
  // PROFILE default
;
// force changing password!
ALTER USER $user PASSWORD EXPIRE;
END

# test用table作成
sqlplus system/$ORACLE_PASSWORD@localhost/XE << END
CREATE TABLE test_table (
    id NUMBER GENERATED ALWAYS AS IDENTITY
    ,first_name VARCHAR2(30)
    ,second_name VARCHAR2(30)
    );
COMMIT;
END

# oracleにデータをimportする場合はoracle_data_loadから実行


# # golangからoracleに接続するための設定
# su - vagrant -c 'mkdir $HOME/lib'
# su - vagrant -c 'cat << END > $HOME/lib/oci8.pc
# prefixdir=$ORACLE_HOME
# libdir=\${prefixdir}/lib
# includedir=\${prefixdir}/rdbms/public
# Name: OCI
# Description: Oracle database driver
# Version: 18c
# Libs: -L\${libdir} -lclntsh
# Cflags: -I\${includedir}
# END
# '

# golangからoracleに接続するための設定
mkdir ~/lib
echo '
prefixdir=$ORACLE_HOME
libdir=\${prefixdir}/lib
includedir=\${prefixdir}/rdbms/public
Name: OCI
Description: Oracle database driver
Version: 18c
Libs: -L\${libdir} -lclntsh
Cflags: -I\${includedir}
' > ~/lib/oci8.pc


# golang,phpは共有ライブラリのコンパイルが必要なため下のようにする必要がある。
echo '# oracle connect for golang,php' >> ~/.bash_profile
echo 'export PKG_CONFIG_PATH=$HOME/lib' >> ~/.bash_profile
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib' >> ~/.bash_profile
echo '' >> ~/.bash_profile

yum -y install systemtap-sdt-devel

echo '# oracle connect for php' >> ~/.bash_profile
echo 'export PHP_DTRACE=yes' >> ~/.bash_profile
echo '' >> ~/.bash_profile

source ~/.bash_profile

# vagrantユーザーにsrcディレクトリを作成し、
# ソースコードをダウンロードしてビルドする。

mkdir ~/src
cd ~/src
yumdownloader --source php
source_rpm=$(ls -1 | grep php-7)
source_name=$(echo $source_rpm | sed 's/\.src\.rpm//')
rpm2cpio $source_rpm > ${source_name}.cpio
cpio -i *.xz < ${source_name}.cpio
source_xz=$(ls -1 | grep php-7 | grep xz)
tar xf $source_xz
source_dir=$(ls -d */ | grep php-7)
cd $source_dir/ext/oci8
phpize
./configure --with-oci8=shared,$ORACLE_HOME
make

# ビルドした物をインストール
bash -c "cd `ls -d /home/vagrant/src/*/`ext/oci8 && make install"

# extensionをphp.iniに追加してoci8を有効にする。
echo "" >> /etc/php.ini
echo ";this module is needed to connect to oracle" >> /etc/php.ini
echo extension=oci8.so >> /etc/php.ini
echo "" >> /etc/php.ini
