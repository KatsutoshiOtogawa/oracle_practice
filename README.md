# oracle_practice
自分用メモ。初心者向けの内容です。oracle検証用の環境構築。

# 前提条件
Javaのダウンロード時にOracleのサイトへのログインが求められるので、 \
もしoracleのアカウントを作っていなかったら、 \
無料で作れるので作っておいてください。 \

# 免責事項
ここにある内容についての私音川勝俊は責任をおいません。 \
Oracle Java, Oracle Database Express Editionは20200915日 \
現在は個人利用、学習用途に限り無償となっていますが、今後変わる可能性もあるため、 \
必ずOracleのライセンス規約に目を通してからインストールしてください。

# 使い方
## 準備
Oracleのサイトから \
rpm,Linuxと書かれているパッケージをダウンロードして、プロジェクトにある \ oracle_dev_setup/packageにファイルをおいてください。 \
[Oracle Database Express](https://www.oracle.com/database/technologies/xe-downloads.html) \
[Java 11(LTS)](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) \
## OSインストール
プロジェクト配下で下記のコマンドを実行してOSのインストールを行ってください。
```
vagrant up
```

## Oracle,Javaインストール
OSのインストールが終わったら、
```
vagrant reload
```
を実行して、vagrantとホスト側OSとのファイル共有を有効にします。
次に
```
vagrant ssh
sudo su
```
として管理者権限でvagrantに入り、下記のコマンドを実行してください。
```
cd /vagrant_oracle_dev_setup
sudo bash install.sh > log.txt 2>&1
```
仮想環境に無償版のoracle　Database Express Edition,Oracle Javaが \
インストールされます。

下記のコマンドを実行して、環境変数を反映させます。
```
source ~/.bash_profile
```

# oracleへの接続確認

vagrantユーザーで下のコマンドを実行してください。
```
lsnrctl status
```
XEインスタンスの構成が表示されることが確認されるはずです。

# sqlplusに接続してみる
下記のコマンドを実行するとsystemユーザーでログインできます。 \
sqlplusから抜けるときはquitと実行してください。 \
```
sqlplus system/password
```
# test_data放り込み
vagrantユーザーで以下のコマンドを実行してください。 \
test_tableにデータがインポートされます。
```
cd /home/vagrant/oracle_data_load
test_table.sh
```

# java からoracleを参照
下記のサイトからojdbc8-full.tar.gzファイルをダウンロード、解凍して \
中のjarファイルをプロジェクト配下のtestconnection/jarフォルダに入れてください。
[Oracle jdbcドライバ](https://www.oracle.com/database/technologies/appdev/jdbc-ucp-183-downloads.html)

vagrantユーザーで下記のコマンドを実行してください。
```
cd /home/vagrant/testconnection
gradle run
```

# これから先
vagrantでoracleのポートをホスト側のポートに紐づけてあるので、 \
ホスト側のosからも接続することができます。 \
下記のファイルをホスト側でインストールすると接続できるようになるので試してみてください。 ＼
sqlplusとBasic Packageをダウンロード \
[Oracle Instance Client](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html)
# refference
[oracleドキュメント](https://docs.oracle.com/cd/E96517_01/xeinl/index.html?xd_co_f=9ac774b5-e809-4f8f-af78-817d43ef4782)

[Javaドキュメント](https://www.oracle.com/java/technologies/javase-jdk11-doc-downloads.html)

[Oracle Linux Vagrant](https://yum.oracle.com/boxes/)

[JavaからOracleへの接続](https://www.oracle.com/jp/database/technologies/develop-java-apps-using-jdbc.html)

