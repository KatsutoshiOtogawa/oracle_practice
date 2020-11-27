yum update -y

# 一般作業ようユーザー
general="general"
general_password="Yeek1eyhjfg@rOg4vjgz"
# 管理者用ユーザー
admin="admin"
admin_password="vtljcxncmmkLa8p~1jLi"

# サーバー用のGUI環境インストール
yum groupinstall "Server with GUI"

# GUI ログインをONにする。
systemctl set-default graphical.target

# 日本語用キーマップの設定
# systemctl の再起動により反映される。
localectl set-keymap --no-convert jp
localectl set-x11-keymap jp

# gnomeがキーボードレイアウトを上書きしないように設定
echo setxkbmap -layout jp >> /etc/X11/xinit/xinitrc

# chrome remote-desktopを設定
yum install -y chrome-remote-desktop

# 開発環境にするのでインストール
# yum -y groupinstall base "Development tools"

# 一般ユーザーの作成.
useradd $general
# vagrantユーザーのgroupに入れる。
useradd $admin -G vagrant

# 最初のログイン時のみ有効なパスワードを設定しておく。
echo  << END | chpasswd
$general:$general_password
$admin:$admin_password
END

# 初回ログイン時にパスワードの変更を求める。
passwd -e $general
passwd -e $admin

# install need to use ssl certificate 
yum install -y openssl
openssl genrsa 2048 > server.key

yum install -y expect
pip3 install pexpect

# create csr
python3 << END
import pexpect

# If you create self signed ssl certificate, all variable can be blank. 
country = ""
province = ""
locality_city = ""
organization_name = ""
organizational_unit_name = ""
common_name = ""
email_address = ""

# optional variable
challenge_password = ""
opional_company = ""

shell_cmd = "openssl req -new -key server.key > server.csr"
prc = pexpect.spawn('/bin/bash', ['-c', shell_cmd])

prc.expect("Country Name")
prc.sendline(country)

prc.expect("State or Province Name")
prc.sendline(province)

prc.expect("Locality Name")
prc.sendline(locality_city)

prc.expect("Organization Name")
prc.sendline(organization_name)

prc.expect("Organizational Unit Name")
prc.sendline(organizational_unit_name)

prc.expect("Common Name")
prc.sendline(common_name)

prc.expect("Email Address")
prc.sendline(email_address)

prc.expect("A challenge password")
prc.sendline(challenge_password)

prc.expect("An optional company name")
prc.sendline(opional_company)

prc.expect( pexpect.EOF )
END

# sign ssl server certificate.
# this command is useing development environment only!
openssl x509 -req -days 3650 -signkey server.key < server.csr > server.crt

# oracle managerにssl証明書をインストール


# vagrant
# LANG=C xdg-user-dirs-gtk-update

# 日本語ロケールを追加しておく。追加しないとエラー。
localedef -f UTF-8 -i ja_JP ja_JP

# 検索の単純化のためmlocateをインストール
yum install -y mlocate

# webサーバーインストール
yum install -y nginx

# SELinux,firewalldの初期状態の確認
echo SELinux status is ...
getenforce
echo firewalld status is ...
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --list-all

# hostosからguestosの通信で指定のポートを開けておく。
firewall-cmd --add-port=1521/tcp --zone=public --permanent
firewall-cmd --add-port=5500/tcp --zone=public --permanent
firewall-cmd --add-service=http --zone=public --permanent
firewall-cmd --add-service=https --zone=public --permanent

# リバースプロキシの設定方法https://gobuffalo.io/en/docs/deploy/proxy
# nginxのリバースプロキシを使う場合に必要なselinuxの設定
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_relay on

# test用テーブルデータ放り込み用ライブラリ
yum install -y python3-pip
pip3 install names

# python環境
pip3 install pipenv

# gradleインストール
wget https://services.gradle.org/distributions/gradle-6.6.1-bin.zip
yum install -y unzip
unzip gradle-6.6.1-bin.zip
mv gradle-6.6.1 /usr/local/gradle
rm gradle-6.6.1-bin.zip
su - vagrant -c 'echo export PATH=/usr/local/gradle/bin:$PATH >> $HOME/.bash_profile'

# golang環境
# 開発者用のレポジトリがあるのでそれを使う
yum-config-manager --enable ol7_developer_golang112
yum install -y golang
su - vagrant -c 'echo export GOPATH=$HOME/.go >> $HOME/.bash_profile'

# rust環境
# rhel系はyumだと古いRustが入るのでfedoraのepelレポジトリを使う。近いミラーを選ぶこと。
# レポジトリの公開鍵をダウンロードしてインストール
wget https://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/RPM-GPG-KEY-EPEL-7Server
rpm --import RPM-GPG-KEY-EPEL-7Server
rm RPM-GPG-KEY-EPEL-7Server
yum-config-manager --add-repo https://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/7Server/x86_64
yum install -y rust cargo
# 競合するため、Rustインストール後は無効化
yum-config-manager --disable ftp.jaist.ac.jp_pub_Linux_Fedora_epel_7Server_x86_64 > /dev/null

# rlang環境
yum-config-manager --enable ol7_developer_EPEL
yum install -y R

# scala環境
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
yum install -y sbt

# php環境
yum install -y oracle-php-release-el7
yum install -y php
# yum -y install php php-oci8-19c としてインストールすると、
# PHP Warning:  PHP Startup: Unable to load dynamic library 'oci8.so' (tried: /usr/lib64/php/modules/oci8.so (libclntsh.so.19.1: cannot open shared object file: No such file or directory), /usr/lib64/php/modules/oci8.so.so (/usr/lib64/php/modules/oci8.so.so: cannot open shared object file: No such file or directory)) in Unknown on line 0
# PHP Warning:  PHP Startup: Unable to load dynamic library 'pdo_oci.so' (tried: /usr/lib64/php/modules/pdo_oci.so (libclntsh.so.19.1: cannot open shared object file: No such file or directory), /usr/lib64/php/modules/pdo_oci.so.so (/usr/lib64/php/modules/pdo_oci.so.so: cannot open shared object file: No such file or directory)) in Unknown on line 0
# libclntsh.so.19.1がないからエラーになるが最新のものをインストールしても、libclntsh.so.18.1のため、利用できず、コンパイルが必要。
# php oci8コンパイルのためのツールをインストール
yum install -y php-devel php-pear

# oracle linuxではOracle databaseインストール前に入っているので不要
# curl -o oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
# yum -y localinstall oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
