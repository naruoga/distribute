////////////////////////////////////////////////////////////////////

  【 Aipo {AIPO_VERSION_SHORT} アップデート手順】

  【 Version 】{AIPO_VERSION_SHORT}

  【 Last Update 】2015/03/16
    Copyright(C) Aimluck,Inc. All Rights Reserved.

////////////////////////////////////////////////////////////////////


Aipo アップデート手順をご案内いたします。
また、古いバージョンの Aipo のインストール先を「/usr/local/aipo」としてご説明いたします。
（※）Aipo をインストールするにはハードディスク空き容量が 500MB 必要となります。
、
（１）ご利用の Aipo のバージョンを確認します。
このアップデータは以下のバージョンの Aipo に対応しています。ご利用中のバージョンをご確認ください。
{TARGET_VERSION}

（２）Aipo のバックアップを行います。
Aipo が起動している状態で、以下のコマンドを実行して Aipo をバックアップします。

 # cd /usr/local/aipo/bin
 # sh backup_handler.sh

次に、Aipo をインストールしたディレクトリ全体をバックアップします。
バージョンアップ前の Aipo の完全な状態を保存しておくことで、
作業ミスなどによるデータロスのリスクを低減できます。

（３）Aipo のアップデートに必要なパッケージをインストールします。

# yum install gcc nmap lsof unzip readline-devel zlib-devel

（４）ファイル「{DIST_DIRNAME}.tar.gz」を解凍し、解凍されたディレクトリに移動します。

# tar -xvzf {DIST_DIRNAME}.tar.gz
# cd {DIST_DIRNAME}

（５）古いバージョンの Aipo インストール先を指定して、アップデート用スクリプトを実行します。

# sh {SCRIPT} /usr/local/aipo

=============================================
Aipo のアップデートが完了しました。

と表示されましたら、アップデート完了です。

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

