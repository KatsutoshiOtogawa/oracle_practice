dnf update -y

# 一般作業ようユーザー
general="general"
general_password="Yeek1eyhjfg@rOg4vjgz"
# 管理者用ユーザー
admin="admin"
admin_password="vtljcxncmmkLa8p~1jLi"

# サーバー用のGUI環境インストール
# yum groupinstall "Server with GUI"

# GUI ログインをONにする。
# systemctl set-default graphical.target

# 日本語用キーマップの設定
# systemctl の再起動により反映される。
# localectl set-keymap --no-convert jp
# localectl set-x11-keymap jp

# gnomeがキーボードレイアウトを上書きしないように設定
# echo setxkbmap -layout jp >> /etc/X11/xinit/xinitrc

# chrome remote-desktopを設定
# yum install -y chrome-remote-desktop

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

dnf -y install git

# 初回ログイン時にパスワードの変更を求める。
passwd -e $general
passwd -e $admin

# install need to use ssl certificate 
dnf install -y openssl
openssl genrsa 2048 > server.key

dnf install -y expect
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
# localedef -f UTF-8 -i ja_JP ja_JP

# 検索の単純化のためmlocateをインストール
dnf install -y mlocate

# webサーバーインストール
dnf install -y nginx

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
dnf install -y python3-pip
pip3 install names

# python環境
pip3 install pipenv

# mavenインストール
dnf -y install maven

# golang環境
dnf install -y golang
su - vagrant -c 'echo export GOPATH=$HOME/.go >> $HOME/.bash_profile'

# dotnet environment
rpm --import https://packages.microsoft.com/keys/microsoft.asc
wget -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/rhel/8/prod.repo

dnf -y install dotnet-sdk-5.0

# rust環境
dnf install -y rust cargo

# rlang環境
# dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# ARCH=$( /bin/arch )
# subscription-manager repos --enable "codeready-builder-for-rhel-8-${ARCH}-rpms"

# dnf -y install R

# scala環境
# curl https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo
# dnf install -y sbt

basearch=`uname -m`
# cat << END > /etc/yum.repos.d/ol8-epel.repo 
# [ol8_developer_EPEL]
# name= Oracle Linux $releasever EPEL ($basearch)
# baseurl=https://yum.oracle.com/repo/OracleLinux/OL8/developer/EPEL/$basearch/
# gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
# gpgcheck=1
# enabled=1
# END

# 202010現在ol8_developerにも無い。
# dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
# dnf makecache


# php環境
# oracle対応が楽なphp8系をインストールする。
# official repositoryに出るようになったら、そちらを使う。
# php のコンパイルに必要。
dnf install -y libxml2-devel sqlite-devel

wget https://www.php.net/distributions/php-8.0.0.tar.gz
tar zxvf php-8.*.*.tar.gz -C /usr/local/src
rm php-8.*.*.tar.gz
cd /usr/local/src/php-8.*.*
# build
./configure
make
make install

# install php.ini file.
install -m 640 /usr/local/src/php-8.*.*/php.ini-development /usr/local/lib/php.ini

sed -i 's/;extension=pdo_oci/extension=pdo_oci/' /usr/local/lib/php.ini

echo export PATH=\$PATH:/usr/local/bin >> ~/.bash_profile
su - vagrant -c 'echo export PATH=\$PATH:/usr/local/bin >> ~/.bash_profile'

# yum -y install php php-oci8-19c としてインストールすると、
# PHP Warning:  PHP Startup: Unable to load dynamic library 'oci8.so' (tried: /usr/lib64/php/modules/oci8.so (libclntsh.so.19.1: cannot open shared object file: No such file or directory), /usr/lib64/php/modules/oci8.so.so (/usr/lib64/php/modules/oci8.so.so: cannot open shared object file: No such file or directory)) in Unknown on line 0
# PHP Warning:  PHP Startup: Unable to load dynamic library 'pdo_oci.so' (tried: /usr/lib64/php/modules/pdo_oci.so (libclntsh.so.19.1: cannot open shared object file: No such file or directory), /usr/lib64/php/modules/pdo_oci.so.so (/usr/lib64/php/modules/pdo_oci.so.so: cannot open shared object file: No such file or directory)) in Unknown on line 0
# libclntsh.so.19.1がないからエラーになるが最新のものをインストールしても、libclntsh.so.18.1のため、利用できず、コンパイルが必要。
# php oci8コンパイルのためのツールをインストール
# dnf install -y php-devel php-pear

# dnf install -y composer

# ファイルリスト更新
updatedb
