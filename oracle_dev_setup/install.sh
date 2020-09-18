#!/bin/bash 

# 実行するとサイレントインストールが始まります。

ORACLE_PASSWWORD=password

# oracle
mkdir /xe_logs 
yum -y localinstall package/oracle-database-xe-18c-1.0-1.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-18c.conf
(echo $ORACLE_PASSWWORD; echo $ORACLE_PASSWWORD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1

# java
yum -y localinstall package/jdk-11.0.8_linux-x64_bin.rpm

# skdmanからgradleをインストール
su - vagrant -c 'curl -s "https://get.sdkman.io" | bash'
su - vagrant -c 'echo source $HOME/.sdkman/bin/sdkman-init.sh >> $HOME/.bash_profile'
su - vagrant -c "sdk install gradle"

# instanceの接続先の設定
su - vagrant -c 'echo export ORACLE_SID=XE >> $HOME/.bash_profile'
# su - vagrant -c "echo export ORAENV_ASK=NO >> .bash_profile"
# su - vagrant -c "source /opt/oracle/product/18c/dbhomeXE/bin/oraenv"

# oracleインストール先の設定
su - vagrant -c 'echo　# config ORACLE_HOME >> $HOME/.bash_profile'
su - vagrant -c 'echo export ORACLE_BASE=/opt/oracle >> $HOME/.bash_profile'
su - vagrant -c 'echo export ORACLE_HOME=$ORACLE_BASE/product/18c/dbhomeXE >> $HOME/.bash_profile'
su - vagrant -c 'echo export PATH=$PATH:$ORACLE_BASE/product/18c/dbhomeXE/bin >> $HOME/.bash_profile'
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


# golangからoracleに接続するための設定
su - vagrant -c 'mkdir $HOME/lib'
su - vagrant -c 'cat << END > $HOME/lib/oci8.pc
prefixdir=$ORACLE_HOME
libdir=\${prefixdir}/lib
includedir=\${prefixdir}/rdbms/public
Name: OCI
Description: Oracle database driver
Version: 18c
Libs: -L\${libdir} -lclntsh
Cflags: -I\${includedir}
END
'

# golang,phpは共有ライブラリのコンパイルが必要なため下のようにする必要がある。
su - vagrant -c 'echo "# oracle connect for golang,php"'
su - vagrant -c 'echo export PKG_CONFIG_PATH=$HOME/lib >> $HOME/.bash_profile'
su - vagrant -c 'echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib >> $HOME/.bash_profile'
su - vagrant -c 'echo "" >> $HOME/.bash_profile'

yum -y install systemtap-sdt-devel
su - vagrant -c 'echo "# oracle connect for php"'
su - vagrant -c 'echo export PHP_DTRACE=yes >> $HOME/.bash_profile'
su - vagrant -c 'echo "" >> $HOME/.bash_profile'

# vagrantユーザーにsrcディレクトリを作成し、
# ソースコードをダウンロードしてビルドする。
su - vagrant << END
mkdir \$HOME/src
cd \$HOME/src
yumdownloader --source php
source_rpm=\$(ls -1 | grep php-7)
source_name=\$(echo \$source_rpm | sed 's/\.src\.rpm//')
rpm2cpio \$source_rpm > \${source_name}.cpio
cpio -i *.xz < \${source_name}.cpio
source_xz=\$(ls -1 | grep php-7 | grep xz)
tar xf \$source_xz
source_dir=\$(ls -d */ | grep php-7)
cd \$source_dir/ext/oci8
phpize
./configure --with-oci8=shared,\$ORACLE_HOME
make
END
# ビルドした物をインストール
bash -c "cd `ls -d /home/vagrant/src/*/`ext/oci8 && make install"

# extensionをphp.iniに追加してoci8を有効にする。
echo ";this module is needed to connect to oracle" >> /etc/php.ini
echo extension=oci8.so >> /etc/php.ini
echo "" >> /etc/php.ini
