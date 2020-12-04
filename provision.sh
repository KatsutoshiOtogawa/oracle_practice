dnf update -y

# 一般作業ようユーザー
general="general"
general_password="Yeek1eyhjfg@rOg4vjgz"
# 管理者用ユーザー
admin="admin"
admin_password="vtljcxncmmkLa8p~1jLi"

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
# dnf install -y python3-pip
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
wget -O /etc/yum.repos.d/microsoft-prod.repo https://packages.microsoft.com/config/fedora/33/prod.repo

# dotnet-sdk-5.0はまだない。
dnf -y install dotnet-sdk-5.0

# rust環境

dnf install -y rust cargo

# rlang環境
dnf -y install R

R --no-save << END
options(repos="https://cran.ism.ac.jp/")
install.packages("renv")
END

# scala環境
curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
dnf install -y sbt

# php環境
# yum install -y oracle-php-release-el7
# yum install -y php
# # yum -y install php php-oci8-19c としてインストールすると、
# # PHP Warning:  PHP Startup: Unable to load dynamic library 'oci8.so' (tried: /usr/lib64/php/modules/oci8.so (libclntsh.so.19.1: cannot open shared object file: No such file or directory), /usr/lib64/php/modules/oci8.so.so (/usr/lib64/php/modules/oci8.so.so: cannot open shared object file: No such file or directory)) in Unknown on line 0
# # PHP Warning:  PHP Startup: Unable to load dynamic library 'pdo_oci.so' (tried: /usr/lib64/php/modules/pdo_oci.so (libclntsh.so.19.1: cannot open shared object file: No such file or directory), /usr/lib64/php/modules/pdo_oci.so.so (/usr/lib64/php/modules/pdo_oci.so.so: cannot open shared object file: No such file or directory)) in Unknown on line 0
# # libclntsh.so.19.1がないからエラーになるが最新のものをインストールしても、libclntsh.so.18.1のため、利用できず、コンパイルが必要。
# # php oci8コンパイルのためのツールをインストール
# yum install -y php-devel php-pear


# # https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# yum install -y composer

# ファイルリスト更新
updatedb