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

* デフォルトブランチがmasterになっているので、developを使用するようにcheckout
    * `git checkout develop`


### fontana_sampleのセットアップ

* 必要なgemのインストール
    * `$ bundle install`

### fontanaのセットアップ

* プロジェクト管理者にどのサーバを使って良いのかを確認してください。

* ローカルで起動する場合
    * これはfontanaのドキュメントを参照ください。

* 別途サーバを起動する場合
    * v0.3.0では未サポートです。


### 環境変数

```
$ export FONTANA_HOME=/path/to/fontana
```

設定していない場合には、このファイルのディレクトリの親ディレクトリに、fontana というディレクトリがあることを期待して動作します。


#### 直接更新の設定

fontanaをローカルで起動している場合、環境変数SYNC_DIRECTLYを設定することで、SCMのリポジトリを経由せずに直接、実行時の作業ディレクトリに変更を反映させることができます。

`$ export SYNC_DIRECTLY=true`



## テスト方法

### テスト実行準備

```
$ bundle exec rake deploy:reset
$ bundle exec rake server:launch_server_daemons
```

### テスト実行

* すべてのテストを実行する場合
    * `$ bundle exec rake spec`

* 一部だけ実行する場合
    * `$ bundle exec rspec spec/ruby_stored_script_spec.rb`


### 変更の反映

* specを変更した場合
    * 実行するファイルを変更しているので、何もしなくても次回実行時には反映されています

* app/seedsのAppSeedファイルを変更した場合
    * SCMリポジトリからサーバに反映させる必要があります
        1. 変更をコミットしてSCMリポジトリに反映
        2. SCMリポジトリからサーバに反映
            * 手動で画面から反映
        3. マイグレーションを実行
        4. (ローカルでfontanaを起動している場合) 再起動

* ストアドスクリプト・フィクスチャを変更した場合
    * 環境変数SYNC_DIRECTLYを設定している場合
        * 何も行う必要ありません
            * 次回テスト実行時に自動的にコピーされます

    * 環境変数SYNC_DIRECTLYを設定してない場合
        * SCMリポジトリからサーバに反映させる必要があります
            1. 変更をコミットしてSCMリポジトリに反映
            2. SCMリポジトリからサーバに反映
                * 手動で画面から反映
            3. マイグレーションを実行
            4. (ローカルでfontanaを起動している場合) 再起動


### テスト終了

```
$ bundle exec rake server:shutdown_server_daemons
```



## よく使用するコマンド


* サーバの状態を初期状態から作り直す
    * `$ rake deploy:reset`
    *GSS/fontanaを初期状態にした上で、ローカルで作業中のブランチと同じ名前のoriginのブランチのHEADをデプロイします。

* サーバの起動
    * `$ rake server:launch_server_daemons`

* テストの実行
    * `$ rake spec`

* サーバの停止
    * `$ rake server:shutdown_server_daemons`

* サーバの状態を最新にする
    * `$ rake deploy:update`
    * GSS/fontanaに、ローカルで作業中のブランチと同じ名前のoriginのブランチのHEADをデプロイします。
    * rake deploy:resetと違って初期状態に戻しません。

* サーバの実行時ディレクトリのapp/scriptsとspec/fixtures を更新する
    * `$ rake sync:client`

