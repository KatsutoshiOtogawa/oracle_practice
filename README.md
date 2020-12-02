# oracle_practice
自分用メモ。初心者向けの内容です。oracle検証用の環境構築。

# 前提条件
Javaのダウンロード時にOracleのサイトへのログインが求められるので、 \
もしoracleのアカウントを作っていなかったら、 \
無料で作れるので作っておいてください。

# 免責事項
ここにある内容についての私音川勝俊は責任をおいません。 \
Oracle Java, Oracle Database Express Editionは20200915日 \
現在は個人利用、学習用途に限り無償となっていますが、今後変わる可能性もあるため、 \
必ずOracleのライセンス規約に目を通してからインストールしてください。

# 使い方
## 準備
Oracleのサイトからrpm,Linuxと書かれているパッケージをダウンロードして、
プロジェクトにあるoracle_dev_setup/packageにファイルをおいてください。 \
[Oracle Database Express](https://www.oracle.com/database/technologies/xe-downloads.html) \
[Oracle Enterprize manager](https://www.oracle.com/enterprise-manager/downloads/linux-x86-64-13c-rel4-downloads.html) *XEはEnterpfze Managerもバンドルされているので不要。 \
[OUI installer](https://www.oracle.com/database/technologies/dotnet-odacdev-downloads.html) *dotnetサポート \
[Java 11(LTS)](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html)
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
sqlplusから抜けるときはquitと実行してください。
```
sqlplus system/password
```
# test_data放り込み
vagrantユーザーで以下のコマンドを実行してください。 \
test_tableにデータがインポートされます。
```
cd /home/vagrant/oracle_data_load
bash test_table.sh
```

# java からoracleを参照
下記のサイトからojdbc8-full.tar.gzファイルをダウンロード、解凍して中の \
jarファイルをプロジェクト配下のtestconnection/java/jarフォルダに入れてください。 \
[Oracle jdbcドライバ](https://www.oracle.com/database/technologies/appdev/jdbc-ucp-183-downloads.html)

vagrantユーザーで下記のコマンドを実行してください。 \
javaからoracleに接続してtableの内容を取得できるはずです。
```
cd /home/vagrant/java/testconnection
mvn package
java -cp target/dependency-jars/*:target/classes/ com.sample.App
# you want to execute jar file.
java -jar target/testconnection-1.0-SNAPSHOT.jar
```

# csharpからoracleを参照
dotnet5.0で確認。javaと比べて相性が悪い、ドライバ周りが面倒かと思ったらそうでもなかった。
```
cd /home/vagrant/csharp/testconnection
dotnet restore
dotnet run
```
だけでテストすることができる。


# pythonからoracleを参照
一番簡単。速度が要求されない分析などではこれが一番賢い選択だと思われる。
```
cd /home/vagrant/python3/testconnection
pipenv install
pipenv run python3 main.py
```
だけでテストすることができる。

# golangからoracleを参照
有志の人がライブラリを作っているのでそれを使って接続。 \
golangからclangのライブラリを読んで接続している。 \
そのため、共有ライブラリ、ヘッダーへのパスを通す必要がある。 \
面倒臭かった。 \
Oracleに接続してSQLを操作するためだけにgolangを選択するメリットはないだろう。 \
コードとしてはjavaより簡単でpythonより面倒臭い程度か。 \
もし本番環境でやる場合はoracle_dev_setup/install.shにあるコードを参考に書くと良い。 \
本プロジェクトではコンパイル、extension追加まで自動化してあるので、
```
cd /home/vagrant/golang/testconnection
go install
go run main.go
```
だけでテストすることができる。

# phpからOracleを参照。
golangよりも面倒臭い。 \
phpからoracleに接続するためにoci8をインストールする必要があるが、 \
Oracelのclientのバージョンと、yumで入るociのバージョンが \
違うとコンパイルする必要がある。 \
ネットで一応調べたが、XEを使った例が無く、自分はコンパイルできなかった。 \
もしやり方を知っている人がいたら教えて欲しい。
```
cd /home/vagrant/php/testconnection
php main.php
```
だけでテストすることができる。

# rustからoracleを参照
思ったよりはるかに簡単だった。 \
oracleでSQL使ったバッチ処理ならgolangよりrustの方がいいかもしれない。 \
懸念点としたらrustはgolangに比べて若い言語なため安定していない可能性があること、 \
ライブラリのメジャー番号が1を迎えていないことだ。 \
golangより低いレイヤーよりの処理。golangよりも自由度が高く、C言語の黒魔術的な考え方が応用できる。 \
golangよりも言語としての習得難易度は高い。これらが差別化ポイントか。

# rlangからoracleを参照
検索するとR Oracle Enterpriseがよく出るが、\
別に外部からrlangを使うだけならODBCから普通に接続できる。 \
pythonとの差別化だが、分析においてクエリの結果に対して複雑な加工処理をしない限り、 \
rlangの方が楽だと思われる。 \
面白いのはoracleはR言語に対して積極的であるということ。 \
ubuntuやfedoraに比べて古いパッケージが多いrhel系だが、 \
yum-config-manager --enable ol7_developer_EPELとすると \
R言語はかなり新しいバージョンの物を入れることができる。


# 結論
pythonかJavaですねOracleから接続するなら。 \
次点でcsharp。linuxでのdotnetの可能性を信じるならアリ。意外にもpowershellからoracleの接続が簡単だったりでdotnetの技術はoracleと相性が良い。 \
php,golangは他のプロジェクトでこの言語使っているからという理由で使うにしては環境構築が面倒臭すぎる。


# これから先
vagrantでoracleのポートをホスト側のポートに紐づけてあるので、 \
ホスト側のosからも接続することができます。 \
下記のファイルをホスト側でインストールすると接続できるようになるので試してみてください。 \
sqlplusとBasic Packageをダウンロード \
[Oracle Instance Client](https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html)
[外部から接続できない時。](https://support.oracle.com/knowledge/Oracle%20Database%20Products/2544653_1.html)
# refference
[oracleドキュメント](https://docs.oracle.com/cd/E96517_01/xeinl/index.html?xd_co_f=9ac774b5-e809-4f8f-af78-817d43ef4782)

[oracle Sample scheme](https://docs.oracle.com/cd/E82638_01/comsc/installing-sample-schemas.html#GUID-C0254DAB-F54C-4B20-9B1E-4F9E21781B96)
[Javaドキュメント](https://www.oracle.com/java/technologies/javase-jdk11-doc-downloads.html)

[Oracle Linux Vagrant](https://yum.oracle.com/boxes/)

[JavaからOracleへの接続](https://www.oracle.com/jp/database/technologies/develop-java-apps-using-jdbc.html)

[PythonからOracleへの接続](https://cx-oracle.readthedocs.io/en/latest/index.html)

[GolangからOracleへの接続1](https://medium.com/@utranand/how-to-connect-golang-to-oracle-using-go-oci8-on-mac-os-b9e197fabdbf)

[GolangからOracleへの接続2](https://qiita.com/qt-luigi/items/fbbe6792a77b493a58f9)
[GOlangからOracleへの接続3](https://www.programmersought.com/article/58354720697/)

[phpからOracleへの接続](https://blogs.oracle.com/otnjp/connect-php-7-to-oracle-database-using-oracle-linux-yum-server-ja)
[phpからOracleへの接続2](https://qiita.com/bluemooninc/items/30897680f6f6775dcf68)
[phpからOracleへの接続3](https://qiita.com/bluemooninc/items/30897680f6f6775dcf68)
[phpからOracleへの接続4](https://www.php.net/manual/ja/oci8.installation.php)
[Django Oracle](https://docs.djangoproject.com/en/3.1/ref/databases/#oracle-notes)

[Oracle Sample Schema](https://github.com/oracle/db-sample-schemas)

[Oracle R Enterprise](https://docs.oracle.com/en/database/oracle/r-enterprise/1.5.1/oread/index.html)