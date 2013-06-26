# GSS/fontana サンプルタイトル

## 概要

これはGSS/fontanaのサンプルタイトルのリポジトリです。



## 環境設定

### fontanaのセットアップ

これはfontanaのドキュメントを参照ください。


### 環境変数

```
$ export FONTANA_HOME=/path/to/fontana
```

設定していない場合には、このファイルのディレクトリの親ディレクトリに、fontana というディレクトリがあることを期待して動作します。


## テスト方法


### サーバの状態を初期状態から作り直す

GSS/fontanaを初期状態にした上で、ローカルで作業中のブランチと同じ名前のoriginのブランチのHEADをデプロイします。

```
$ rake deploy:reset
```


### サーバの起動

```
$ rake server:launch_server_daemons
```

### テストの実行

```
$ rake spec
```


### サーバの停止

```
$ rake server:shutdown_server_daemons
```






### サーバの状態を最新にする

GSS/fontanaに、ローカルで作業中のブランチと同じ名前のoriginのブランチのHEADをデプロイします。

```
$ rake deploy:reset
```

rake deploy:resetと違って初期状態に戻しません。







### サーバの実行時ディレクトリのapp/scripts を更新する

```
$ rake source:update_scripts
```



