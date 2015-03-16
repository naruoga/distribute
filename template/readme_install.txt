////////////////////////////////////////////////////////////////////

  【 Aipo {AIPO_VERSION_SHORT} インストール手順】

  【 Version 】{AIPO_VERSION_SHORT}

  【 Last Update 】2015/03/16
    Copyright(C) Aimluck,Inc. All Rights Reserved.

////////////////////////////////////////////////////////////////////


Aipo のインストール手順をご案内いたします。
また、Aipo のインストール先を「/usr/local/aipo」としてご説明いたします。
（※）Aipo をインストールするにはハードディスク空き容量が 500MB 必要となります。

（１）Aipo のインストールに必要なパッケージをインストールします。

# yum install gcc nmap lsof unzip readline-devel zlib-devel

（２）ファイル「{DIST_DIRNAME}.tar.gz」を解凍し、解凍されたディレクトリに移動します。

# tar -xvzf {DIST_DIRNAME}.tar.gz
# cd {DIST_DIRNAME}

（３）インストール先を指定して、インストール用スクリプトを実行します。
なお、インストール先を省略した場合は「/usr/local/aipo」にインストールされます。

# sh {SCRIPT} /usr/local/aipo

=============================================
Aipo のインストールが完了しました。

と表示されましたら、インストール完了です。

・Aipo の起動

# /usr/local/aipo/bin/startup.sh

Aipo が起動しましたら、
Webブラウザからアクセスするための URL がコンソールに表示されます（ 「 http://????? 」 の部分です）。
Webブラウザでこのアドレスへアクセスすると、Aipo を使うことができます。

（※）ファイアウォールをご使用になられている場合、Aipo に接続できない事がございます。
Aipo に接続できなかった場合には、お使いのファイアウォールの設定をご確認ください。

・Aipo の停止

# /usr/local/aipo/bin/shutdown.sh

・Aipo のバックアップ

Aipo 起動中に以下のスクリプトで、Aipo のバックアップをとることができます。

# /usr/local/aipo/bin/backup.sh

・Aipo のリストア

Aipo 起動中に以下のスクリプトで、Aipo をバックアップからリストアすることができます。

# /usr/local/aipo/bin/restore.sh

