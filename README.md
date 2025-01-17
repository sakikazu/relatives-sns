AdanHP
====

宮崎県の田舎にあるA団に集った者たちのSNS

## TODO
* 動画エンコードについてまとめる（下にsidekiqの項目はある）
* 本番環境で log/production.log が出力されず、 log/unicorn.log にまとめられているが、原因不明なので無視する

## Updates
* 2023/02: grapeとそれによるAPIを削除した
    * スマホアプリは稼働してないのと、Rails6にした際に、本番環境でエラーが出たため

## Features
* クローズドSNS
* Twitterライクなつぶやき投稿、ActionCableによるPUSH更新対応
* アルバム機能。動画エンコード、複数画像ファイルアップロード
* イイネの集計ランキング
* 掲示板
* 日記
* 年表
* メンバーの管理、Google Mapsで住所、家系図機能
* レスポンシブデザインによるスマホView対応
* turbolinksによる高速表示
* capistranoによるデプロイ
* 管理画面

## スクリーンキャプチャ
### TOPページ
<img width="1106" alt="2023-02-19_AdanHPキャプチャ（Github用）" src="https://user-images.githubusercontent.com/745130/219922609-9b153640-2759-4e42-b74a-183806c32dd9.png">


## System dependencies

### Ruby version
* ruby 2.7
* rails 6.1

### ライブラリ
* Twitter bootstrap 4
* colorboxは、サムネイル画像のリンクからリンク先の大きな画像を取得してモーダルで表示機能と、スライドショー機能のために使っている。できれば自作して使わないようにしたい
* Font Awesome: https://fontawesome.com/v4.7.0/icons/#
* テンプレートエンジン: slim
* altCSS: scss

### ミドルウェア
* Redis, sidekiq: 動画エンコードをジョブキューで行っている
    * ActionCableでは本番でもRedisを使わずasync設定（Rubyのスレッドで処理かな？）にしている

### サービス
* メール送信: Gmail
* Google Maps API: メンバーの住所の地図機能
    * 使っているのは多分「Maps JavaScript API」のみ。月の無料枠内で収まるはず。
    * https://cloud.google.com/maps-platform/
        * コンソールの「IAMと管理」の「割り当て」から使用量が確認できる

## Knowhow
* つぶやき（Mutter）投稿時にActionCable（Websocket）でサーバーPUSHすることでレンダリングしている
    * git show a7aa70b0de49d5a0eea3eb07387330fb645e40c3
* ffmpegを使用して動画エンコード、サムネイル用画像の切り出しを行っている
* 各所にCSS flexboxを用いてレイアウト
* Ajaxによるファイルアップロード（プログレスバー付き）
* turbolinksを意識したJSの記述方法（ソース参照）
* スマホでのUIを意識したViewにしている（特にトップページ、アルバム機能）
* ruby-gmailを使用してGmailにIMAPで接続し、メール検索や取得などの操作を行う[6b15bcd23cafd96ba10a67a2a26e996d629bf7c3]
    * ref: ruby-gmailを使ってRubyからGmailのメールを受信して本文を取得 * Shoken OpenSource Society http://shoken.hatenablog.com/entry/20120401/p1
    * 以前はruby-gmailではなくtmailのgemを使っていた。tmailが汎用的だが処理が煩雑って感じ
    * ガラケーからMutterに画像を投稿するために使用していたので、2019/01/07に処理を削除


## heroku
https://a-dan.herokuapp.com/

### test login
| email            | password  |
| ---------------- | --------- |
| test@example.com | password  |

```
$ git push heroku master
$ heroku run rake db:migrate
$ heroku open
# 必要なら
$ heroku restart
# エラー時はlog --tailで調査
$ heroku logs --tail
```


## Deployment instructions
* config/deploy.rbに記載されているlinked_files, linkded_dirsに意識すればOK

## Backup
サーバー側のcronでDBのdumpを行い、
ローカルPCのcronでDB dumpとアップロードファイルをローカルPC内部に保存している


## Issues

* 基本的には、TODOはEvernoteに記載している。あとソース上にも。
* 下記削除。ファイルが存在するだけでRailsAdminでエラーになっていたので。これ何のためなんだっけ？必要ないのか？
```
mutter_sweeper.rb
nice_sweeper.rb
update_history_sweeper.rb
```

### データ移行失敗
2014/6/17に行ったデータ移行で、それ以前の画像ありのMutterデータがこの日のcreated_atになってしまってるものがある。
Mutterの画像あり検索で最後の方を見れば確認できる。
（詳細は未調査）

### プログラムの問題

#### PhotoとMovieはMediaモデルとしてまとめたかった
理由はアルバムでの表示など、両者をまとめて扱いたいケースが多い。まとめたとしても、typeによってディレクトリがわかれていれば特に弊害は思いつかない

### 本番サーバー（さくらVPS）
* 2019/02、capistranoデプロイ時、bundleやrubyなど実行ファイルが見つからないエラーが出てしまった。HMの時には出ないのに。なので、無理やり/usr/binにそのシンボリックリンクを作成して、動くようにしている。本質的な解決をしたい。


## よく使うコマンド

### unicorn再起動
```
# 本番サーバーのRVMの問題か、unicorn:restartでは再起動できない場合がある
$ cap production unicorn:stop
$ cap production unicorn:start
```

### cron
```
TODO なにこれ？詳細追記して〜
create_ranking_total.sh
```

### sidekiq
* capistranoで起動するのを断念。 see: Capifile

```
* production
$ cap production sidekiq:restart

* dev
$ bundle exec sidekiq
```

### メール
* 開発環境でメール送受信
```
$ mailcatcher
```

### redis
```
sudo /etc/init.d/redis start
(mac)
redis-server
```

### crontab update
bundle exec whenever -i

### Nginx再起動
rootユーザーで
$ nginx -s reload


## OTHER

### bitbucket's README.md
https://bitbucket.org/tutorials/markdowndemo/src/master/

### エラー処理
* エラー時はexception_notificationによって、sakikazuのGmailにExceptionメールが送信される
* Exceptionメールが正しく動作しているかの確認は、「ActionController::InvalidAuthenticityToken」を出すのが手軽

