#!/bin/bash 
set -e
# 実行するとサイレントインストールが始まります。

ORACLE_PASSWORD=xkhxnv08WOuhbgtdwpq

# you want to use pluggable database. you insert data this database.
PDB_INSTANCE=XEPDB1

# oracle linuxではOracle databaseインストール前に入っているので不要
# curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
# yum -y localinstall oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm

# oracle
mkdir /xe_logs 
yum -y localinstall package/oracle-database-xe-*-*.*-*.x86_64.rpm > /xe_logs/XEsilentinstall.log 2>&1
sed -i 's/LISTENER_PORT=/LISTENER_PORT=1521/' /etc/sysconfig/oracle-xe-18c.conf
(echo $ORACLE_PASSWORD; echo $ORACLE_PASSWORD;) | /etc/init.d/oracle-xe-* configure >> /xe_logs/XEsilentinstall.log 2>&1


echo '# set oracle environment variable'  >> ~/.bash_profile
echo 'export ORACLE_SID=XE'  >> ~/.bash_profile
echo 'export ORAENV_ASK=NO'  >> ~/.bash_profile
echo 'export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE' >> ~/.bash_profile
echo 'export ORACLE_BASE=/opt/oracle' >> ~/.bash_profile
echo export PATH=\$PATH:\$ORACLE_HOME/bin >> ~/.bash_profile
echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> ~/.bash_profile
echo '' >> ~/.bash_profile

# sqlplusの文字コードの設定
echo '# sqlplus decoding' >> ~/.bash_profile
echo 'export NLS_LANG=Japanese_Japan.AL32UTF8' >> ~/.bash_profile
echo '' >> ~/.bash_profile

# reload bash environment.
source ~/.bash_profile

#  you want to connect oracleDB, use XEPDB1 pragabble
cat << END >> $ORACLE_HOME/network/admin/tnsnames.ora

${PDB_INSTANCE} =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${PDB_INSTANCE})
    )
  )

END

mkdir /home/oracle
chmod 700 /home/oracle
chown oracle /home/oracle

# oracle
su - oracle -c 'echo "# set oracle environment variable"  >> ~/.bash_profile'
su - oracle -c 'echo export ORACLE_SID=XE >> ~/.bash_profile'
su - oracle -c 'echo export ORAENV_ASK=NO >> ~/.bash_profile'
su - oracle -c 'echo export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE >> ~/.bash_profile'
su - oracle -c 'echo export ORACLE_BASE=/opt/oracle  >> ~/.bash_profile'
su - oracle -c 'echo export PATH=\$PATH:\$ORACLE_HOME/bin >> ~/.bash_profile'
su - oracle -c 'echo export ORACLE_PASSWORD=$ORACLE_PASSWORD >> ~/.bash_profile'
su - oracle -c 'echo "" >> ~/.bash_profile'

# sqlplusの文字コードの設定
su - oracle -c 'echo "# sqlplus decoding" >> ~/.bash_profile'
su - oracle -c 'echo export NLS_LANG=Japanese_Japan.AL32UTF8 >> ~/.bash_profile'
su - oracle -c 'echo "" >> ~/.bash_profile'

# vagrant 
su - vagrant -c 'echo "# set oracle environment variable"  >> ~/.bash_profile'
su - vagrant -c 'echo export ORACLE_SID=XE >> ~/.bash_profile'
su - vagrant -c 'echo export ORAENV_ASK=NO >> ~/.bash_profile'
su - vagrant -c 'echo export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE >> ~/.bash_profile'
su - vagrant -c 'echo export ORACLE_BASE=/opt/oracle  >> ~/.bash_profile'
su - vagrant -c 'echo export PATH=\$PATH:\$ORACLE_HOME/bin >> ~/.bash_profile'
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

# if you have oracle_java, install that,but you dont have that, install openjdk-11.
if ls -1 /vagrant_oracle_dev_setup/package/jdk-*.*.*_linux-x64_bin.rpm > /dev/null; then
  yum -y localinstall package/jdk-*.*.*_linux-x64_bin.rpm
fi

# Oracle Databasesがシステム起動時に動くように自動化
systemctl daemon-reload
systemctl enable oracle-*-*

# oracle Databaseを起動。
systemctl start oracle-*-*

# if you have oracle r machine lerning
if ls -1 /vagrant_oracle_dev_setup/package/ore-server-linux-x86-64-*.*.* > /dev/null; then
  
  # enable extprocy is called OML4R module only.
  echo SET EXTPROC_DLLS=ONLY:$ORACLE_HOME/lib/ore.so >> $ORACLE_HOME/hs/admin/extproc.ora

  # enable extproc trace.
  echo SET TRACE_LEVEL=ON >> $ORACLE_HOME/hs/admin/extproc.ora

  # reload settings.
  systemctl restart oracle-*-*

  mv $ORACLE_HOME/R/library/ORE $ORACLE_HOME/R/library/ORE.orig
  mv $ORACLE_HOME/R/library/OREbase $ORACLE_HOME/R/library/OREbase.orig
  mv $ORACLE_HOME/R/library/OREcommon $ORACLE_HOME/R/library/OREcommon.orig
  mv $ORACLE_HOME/R/library/OREdm $ORACLE_HOME/R/library/OREdm.orig
  mv $ORACLE_HOME/R/library/OREdplyr $ORACLE_HOME/R/library/OREdplyr.orig
  mv $ORACLE_HOME/R/library/OREeda $ORACLE_HOME/R/library/OREeda.orig
  mv $ORACLE_HOME/R/library/OREembed $ORACLE_HOME/R/library/OREembed.orig
  mv $ORACLE_HOME/R/library/OREgraphics $ORACLE_HOME/R/library/OREgraphics.orig
  mv $ORACLE_HOME/R/library/OREmodels $ORACLE_HOME/R/library/OREmodels.orig
  mv $ORACLE_HOME/R/library/OREpredict $ORACLE_HOME/R/library/OREpredict.orig
  mv $ORACLE_HOME/R/library/OREserver $ORACLE_HOME/R/library/OREserver.orig
  mv $ORACLE_HOME/R/library/OREstats $ORACLE_HOME/R/library/OREstats.orig
  mv $ORACLE_HOME/R/library/ORExml $ORACLE_HOME/R/library/ORExml.orig

  unzip package/ore-server-linux-x86-64-*.*.* -d package/

  # need to install ORE-server and can use usually user.
  chmod 755 /opt/oracle/product/18c/dbhomeXE/bin/ORE

  ORE CMD INSTALL package/server/ORE_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREbase_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREcommon_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREdm_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREdplyr_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREeda_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREembed_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREgraphics_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREmodels_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREpredict_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREserver_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/OREstats_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  ORE CMD INSTALL package/server/ORExml_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz
  
  sqlplus system/$ORACLE_PASSWORD@XE << END
  ALTER SESSION SET container=XEPDB1;
  ALTER PROFILE DEFAULT LIMIT PASSWORD_VERIFY_FUNCTION NULL;
  @$ORACLE_HOME/R/server/rqcfg.sql SYSAUX TEMP $ORACLE_HOME /usr/lib64/R

  -- argument variable define example.
  -- DEFINE permtbl = SYSAUX
  -- DEFINE temptbl = TEMP
  -- DEFINE orahome = $ORACLE_HOME
  -- DEFINE rhome = /usr/lib64/R
END

  # install ROracle library
  if ls -1 /vagrant_oracle_dev_setup/package/ore-supporting-linux-x86-64-*.*.* > /dev/null; then

    yum -y install cairo-devel 
    yum -y install libpng-devel

    unzip package/ore-supporting-linux-x86-64-*.*.* -d package/

    R CMD INSTALL package/supporting/Cairo_*.*-*_R_x86_64-unknown-linux-gnu.tar.gz  
    R CMD INSTALL package/supporting/DBI_*.*-*_R_x86_64-unknown-linux-gnu.tar.gz  
    R CMD INSTALL package/supporting/ROracle_*.*-*_R_x86_64-unknown-linux-gnu.tar.gz  
    R CMD INSTALL package/supporting/arules_*.*-*_R_x86_64-unknown-linux-gnu.tar.gz  
    R CMD INSTALL package/supporting/png_*.*-*_R_x86_64-unknown-linux-gnu.tar.gz  
    R CMD INSTALL package/supporting/randomForest_*.*-*_R_x86_64-unknown-linux-gnu.tar.gz  
    R CMD INSTALL package/supporting/statmod_*.*.*_R_x86_64-unknown-linux-gnu.tar.gz  

  fi
#   # install additionnal library for using ORE.
#   R --no-save << END
#   # deceide library load.
#   options(repos="https://cran.ism.ac.jp/")
#   install.packages("png", dependencies = TRUE)
#   install.packages("DBI", dependencies = TRUE)
#   install.packages("ROracle", dependencies = TRUE)
  
# END

# ore.connect("OML_USER", password="OML_USERpsw", conn_string="", all=TRUE)

  # 接続確認
  R --no-save << END
  ore.connect("system", password="$ORACLE_PASSWORD", conn_string="XEPDB1", all=TRUE)
  ore.is.connected()
END
fi

user=general
user_password="tfrkBi1qzxIkwg0ohpb"
# 右のようにlocalhost以外は禁止されているデフォルトではsqlplus system@"dbhost.example/XE"
sqlplus system/$ORACLE_PASSWORD@XE << END
-- show spfile location.
SHOW PARAMETER spfile;
-- show initialization parameters
SELECT name,value FROM v$parameters

SELECT version,instance_name,status,logins FROM v\$instance;
SELECT name,open_mode,cdb FROM v$database;

-- show user info.
SELECT username, account_status,default_tablespace FROM DBA_USERS;

-- XDBをvagrantの外(host側)から実行できる様にする。
EXEC DBMS_XDB.SETLISTENERLOCALACCESS(FALSE);

-- CONNECT PDB FOR CREATE USER AND CREATE
ALTER SESSION SET container = XEPDB1;

-- CREATE USER
CREATE USER $user
  IDENTIFIED BY $user_password
  -- DEFAULT TABLESPACE USER01
  -- TEMPORARY TABLESPACE temp
  -- QUOTA 50M ON USER01
  -- PROFILE default
;

-- add grant to create sesssion.
GRANT CREATE SESSION TO $user;
-- force changing password!
ALTER USER $user PASSWORD EXPIRE;
END

# create os authentication user.
sqlplus system/$ORACLE_PASSWORD@XE << END
ALTER SESSION SET container = XEPDB1;
CREATE USER ops\$vagrant IDENTIFIED EXTERNALLY;
GRANT pdb_dba TO ops\$vagrant;
-- GRANT CREATE SESSION TO ops\$vagrant;
-- 
ALTER SESSION SET container = CDB\$ROOT;
CREATE PLUGGABLE DATABASE vagrant ADMIN USER ops\$vagrant
IDENTIFIED BY "ops\$vagrant"
DEFAULT TABLESPACE vagrant_tbs
FILE_NAME_CONVERT=(
  '/opt/oracle/oradata/XE/pdbseed/'
  ,'/opt/oracle/oradata/XE/vagrant/'
)
;
END


# sqlplus pdbadmin/$ORACLE_PASSWORD@${PDB_INSTANCE} << END
# -- 
# ALTER SESSION SET container = CDB\$ROOT;
# CREATE PLUGGABLE DATABASE vagrant ADMIN USER ops\$vagrant
# IDENTIFIED BY "ops\$vagrant"
# DEFAULT TABLESPACE vagrant_tbs
# FILE_NAME_CONVERT=(
#   '/opt/oracle/oradata/XE/pdbseed/'
#   ,'/opt/oracle/oradata/XE/vagrant/'
# )
# ;
# END


TEST_DB=TEST_DB
TEST_DB_PASSWORD=9qwgntynuuxjgegv4ZG

sqlplus system/$ORACLE_PASSWORD@XE << END
CREATE PLUGGABLE DATABASE ${TEST_DB} ADMIN USER ${TEST_DB}
IDENTIFIED BY "${TEST_DB_PASSWORD}"
DEFAULT TABLESPACE test_tbs
-- なぜか動かない。XE の仕様かも。
-- DATAFILE /opt/oracle/oradata/XE/test_db/users01.dbf
-- SIZE 10M AUTOEXTEND ON
-- create from pdbseed directory
FILE_NAME_CONVERT=(
  '/opt/oracle/oradata/XE/pdbseed/'
  ,'/opt/oracle/oradata/XE/test_db/'
)
;

-- OPEN DATABASE

END

#  you want to connect oracleDB, use XEPDB1 pragabble
cat << END >> $ORACLE_HOME/network/admin/tnsnames.ora

${TEST_DB} =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${TEST_DB})
    )
  )

END

# copy tnsnames.ora to host OS
cp $ORACLE_HOME/network/admin/tnsnames.ora ./

# copy tnsnames.ora to guest os user
cp /opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora /home/vagrant/
chown vagrant:vagrant /home/vagrant/tnsnames.ora
# set TNS_ADMIN. this environment is used by sqlplus for searching tnsnames.ora.
su - vagrant -c 'echo "# set tnsnames.ora location." >> ~/bash_profile' 
su - vagrant -c 'echo export TNS_ADMIN=\$HOME >> ~/bash_profile'
su - vagrant -c 'echo "" >> ~/bash_profile'

# create sample from github
# you want to know this script detail, go to https://github.com/oracle/db-sample-schemas.git
# you select branch version the same with oracle database version.
ORACLE_VERSION=18c

git clone https://github.com/oracle/db-sample-schemas.git -b v${ORACLE_VERSION}
cd db-sample-schemas/
perl -p -i.bak -e 's#__SUB__CWD__#'$(pwd)'#g' *.sql */*.sql */*.dat 
sqlplus system/${ORACLE_PASSWORD}@${PDB_INSTANCE} @mksample $ORACLE_PASSWORD syspw hrpw oepw pmpw ixpw shpw bipw users temp $HOME/dbsamples.log $PDB_INSTANCE
cd ../


# you dont use production vironment.
# https://github.com/oracle/oracle-db-tools/tree/master/ords

sqlplus system/${ORACLE_PASSWORD}@${PDB_INSTANCE} << EOF
BEGIN
 ORDS.ENABLE_SCHEMA(p_enabled => TRUE,
                   p_schema => 'HR',
                   p_url_mapping_type => 'BASE_PATH',
                   p_url_mapping_pattern => 'hr',
                   p_auto_rest_auth => FALSE);

 commit; 
END;
EOF

# test用table作成
sqlplus system/$ORACLE_PASSWORD@${PDB_INSTANCE} << END
CREATE TABLE test_table (
    id NUMBER GENERATED ALWAYS AS IDENTITY
    ,first_name VARCHAR2(30)
    ,second_name VARCHAR2(30)
    );
COMMIT;
END

# golang,phpは共有ライブラリのコンパイルが必要なため下のようにする必要がある。
echo '# oracle connect for golang,php' >> ~/.bash_profile
echo export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$ORACLE_HOME/lib >> ~/.bash_profile
echo '' >> ~/.bash_profile

# libclntsh.soをinstantclientと同じディレクトリに持ってくる。
ln -s $ORACLE_HOME/lib/libclntsh.so $ORACLE_HOME

yum -y install systemtap-sdt-devel

echo '# oracle connect for php' >> ~/.bash_profile
echo 'export PHP_DTRACE=yes' >> ~/.bash_profile
echo '' >> ~/.bash_profile

source ~/.bash_profile

# phpは手動で作業。ソースコードをダウンロードしてビルドする。
mkdir /usr/local/src/php_oci8
cd /usr/local/src/php_oci8
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
./configure --with-oci8=shared,instantclient,$ORACLE_HOME
make
make install 

cd $source_dir/ext/pdo_oci
phpize
./configure --with-pdo_oci=shared,instantclient,$ORACLE_HOME
make
make install 

# extensionをphp.iniに追加してoci8を有効にする。
echo "" >> /etc/php.ini
echo ";this module is needed to connect to oracle" >> /etc/php.ini
echo extension=oci8.so >> /etc/php.ini
echo "" >> /etc/php.ini

# library  

# cp ~/lib/oci8.pc /usr/local/lib/
echo '# set pkg_config_path for compiling library' >> ~/.bash_profile
echo export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:/usr/local/lib >> ~/.bash_profile
echo "" >> >> ~/.bash_profile

su - vagrant 'echo "# set pkg_config_path for compiling library" >> ~/.bash_profile'
su - vagrant 'echo export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:/usr/local/lib >> ~/.bash_profile'
su - vagrant 'echo "" >> ~/.bash_profile'

# golangからoracleに接続するための設定
# mkdir ~/lib
cat << END >  /usr/local/lib/oci8.pc
prefixdir=$ORACLE_HOME
libdir=\${prefixdir}/lib
includedir=\${prefixdir}/rdbms/public
Name: OCI
Description: Oracle database driver
Version: 18c
Libs: -L\${libdir} -lclntsh
Cflags: -I\${includedir}
END

# ファイルリスト更新
updatedb