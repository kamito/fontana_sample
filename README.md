# GSS/fontana サンプルタイトル

## 概要

このリポジトリはGSS/fontanaのサンプルタイトルのリポジトリです。



## 環境設定

### clone

* 以下のどちらかでgithubからリポジトリの取得
    * `git clone https://github.com/groovenauts/fontana_sample.git`
    * `git clone git@github.com:groovenauts/fontana_sample.git`

* 作られたディレクトリに移動
    * `cd fontana_sample`

* (必要に応じて)デフォルトブランチがmasterになっているので、developを使用するようにcheckout
    * `git checkout develop`


### fontana_sampleのセットアップ

* 必要なgemのインストール
    * `$ bundle install`

* rbenvを使っていたら
    * `$ rbenv rehash`


## 動作確認

### ローカルでテストの実行

```
$ expott FONTANA_REPO_URL=<非公開のリポジトリのURL>
$ export SYNC_DIRECTLY=true
$ rake
```

#### 補足1

このコマンドだけでfontanaのセットアップを行い、適切にマイグレーションを実行した上で、サーバを起動し、テストを実行、サーバの停止を行います。

#### 補足2 FONTANA_REPO_URLについて

一度fontanaのセットアップが行われれば、vendor/fontanaに設定は記録されているので、環境変数FONTANA_REPO_URLを毎回設定する必要はありません。



## 開発作業

設定ファイルやAppSeedファイル、ストアドスクリプトとそのテストを記述しながらテストを実行したり、起動している運営ツールを操作することを想定しています。


### 使用可能なrakeタスクの一覧

`$ rake -T` あるいは `$ rake -A -T` でrakeタスクの一覧を表示することができます。

**基本的にここで表示されるもの以外のコマンドを使う必要はありません！**


### テスト駆動開発の流れ

0. 環境変数を設定する
    * `$ expott FONTANA_REPO_URL=<非公開のリポジトリのURL>`
    * `$ export SYNC_DIRECTLY=true`
1. サーバを起動する
    * `$ rake servers:start`
2. テストを記述する
3. テストを実行する
    * `$ rake spec`
4. 失敗することを確認する
5. 実装を編集する
6. テストを実行する
    * `$ rake spec`
7. 失敗したら5に戻る
8. パスしたら、gitにコミットする
9. サーバを終了する
    * `$ rake servers:stop`


#### AppSeedファイルや設定ファイルを変更した場合

```
$ rake deploy:sync:update
```


#### サーバの再起動

調子が悪かったら再起動してみてください

```
$ rake servers:restart
```


#### fontanaを再インストール

とにかく何かおかしいという場合、一度fontanaをインストールし直すとよいこともあるかもしれません。

その際には一度サーバを停止するコマンドも忘れずに実行してください。

```
$ rake servers:stop
```

以下のコマンドでvendor/fontanaをクリアしてインストールが行われます。

```
$ rake vendor:fontana:reset
```

インストールを行う際に、「一時的にfontanaのdevelopブランチを使ってください」ということを言われることがあるかもしれません。
その場合は環境変数FONTANA_BRANCHにブランチ名を設定してください。

```
$ export FONTANA_BRANCH=develop
$ rake vendor:fontana:reset
```



## リポジトリにpushした後のテスト

ある程度機能を作ってリポジトリにpushした後は、念のため、ローカルのソースコードではなく、リポジトリのコードを使って、テストを行なってください。

### １コマンドで実行する場合

```
$ unset SYNC_DIRECTLY
$ rake servers:stop
$ rake
```

これによって、リポジトリからソースコードによってサーバが起動して、テストが実行されます。


### 何回もテストを実行する場合

```
$ unset SYNC_DIRECTLY
$ rake servers:stop
$ rake deploy:scm:update
$ rake servers:start
$ rake spec
```

`rake deploy:scm:update` はリポジトリからソースを取得してAppSeedの登録とマイグレーションを行いますが、
`rake deploy:scm:reset` は初期化やセットアップを実行してから `rake deploy:scm:update`を実行します。

必要に応じて使い分けてください。



## 今後の機能追加の予定

* ローカル以外の環境で動くサーバに接続するテスト
