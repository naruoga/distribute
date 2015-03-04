# Aipo Distribute

Aipo の配布用パッケージをビルドするプロジェクトです。

## 必要環境

* Git
* JDK1.8
* Maven3
* Ruby

## 利用方法

### Linux版インストーラ

```target``` フォルダに 32bit版、64bit版の Aipo インストーラがビルドされます。

#### 最新版（master）


```
rake installer:latest
```

#### 安定版（8.0）

```
rake installer:stable
```
