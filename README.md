# Aipo Distribute

Aipoの配布用パッケージをビルドするプロジェクトです。

* [公式サイト](http://www.aipo.com/)  
* [ダウンロード](http://free.aipo.com/)
* [ドキュメント](http://doc.aipo.com/)  
* [コミュニティ](http://user.aipo.com/)  

## 必要環境

* Git
* JDK1.8
* Maven3
* Ruby

### Mac 環境

Mac 環境でビルドする場合、GNU tar が必要となります。

```
brew install gnu-tar
```

~/.bash_profile

``` 
export PATH=/usr/local/opt/gnu-tar/libexec/gnubin:$PATH
```

## 利用方法

### Linux版インストーラ

```target``` フォルダに 32bit版、64bit版の Aipo インストーラがビルドされます。

#### 最新版（master）


```
rake installer:latest
```

#### 安定版（8.0.1）

```
rake installer:stable
```

### Linux版アップデータ

```target``` フォルダに 32bit版、64bit版の Aipo アップデータがビルドされます。

#### 7.0.2 to 8.0.1

```
rake updater:7020to8010
```

#### 8.0 to 8.0.1

```
rake updater:8000to8010
```

## ライセンス

[AGPLv3](http://ja.wikipedia.org/wiki/Affero_General_Public_License)

