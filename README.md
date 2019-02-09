# Issues

* 2014/05/17、Firefoxでアルバムの写真アップロード（Uploadify(flash)を使って）が422エラー。Photo#createメソッドに対策記事などメモってる
* 下記削除。ファイルが存在するだけでRailsAdminでエラーになっていたので。これ何のためなんだっけ？必要ないのか？
```
mutter_sweeper.rb
nice_sweeper.rb
update_history_sweeper.rb
```


# よく使うコマンド

## unicorn再起動
$ cat tmp/unicorn.pid | xargs kill -USR2

### (こっちじゃないと反映されないことがあるが・・。capistranoの影響？)
$ cd (Rails.root)
$ cat tmp/unicorn.adan.pid | xargs kill -QUIT
$ bundle exec unicorn -E production -c /usr/local/site/adan/current/config/unicorn.conf.rb -D


## cron
todo 詳細追記して〜
create_ranking_total.sh


## sidekiq
[todo] capistranoで再起動できるようにしたい
[todo] デーモン化は？
```
$ bundle exec sidekiq -C config/sidekiq.yml -e production
```

### (dev)
bundle exec sidekiq -C config/sidekiq.yml

## redis
```
sudo /etc/init.d/redis start
(mac)
redis-server
```

## crontab update
bundle exec whenever -i


## Nginx再起動
rootで
$ nginx -s reload


# Updates
* [2014/05/11] Rails4に。configなどの内容もちゃんと合わせた

# Knowhow
- ruby-gmailを使用してGmailにIMAPで接続し、メール検索や取得などの操作を行う[6b15bcd23cafd96ba10a67a2a26e996d629bf7c3]
  - ref: ruby-gmailを使ってRubyからGmailのメールを受信して本文を取得 - Shoken OpenSource Society http://shoken.hatenablog.com/entry/20120401/p1
  - 以前はruby-gmailではなくtmailのgemを使っていた。tmailが汎用的だが処理が煩雑って感じ
  - ガラケーからMutterに画像を投稿するために使用していたので、2019/01/07に処理を削除
- Mutterの追加をActionCable（Websocket）でサーバーPUSH通知している
  - git show a7aa70b0de49d5a0eea3eb07387330fb645e40c3

# Ruby version
- ruby 2.5
- rails 5.2

# System dependencies
- Twitter bootstrap 4
- colorboxは、サムネイル画像のリンクからリンク先の大きな画像を取得してモーダルで表示するというbootstrapでは実現できない機能を持つので使っていきたい
- メール送信のSMTPにGmailの個人アカウントを使用
  - TODO: サーバーにpostfixが動いているかもしれないので不要かも
- Google Maps API: メンバーの住所の地図機能
  - 使っているのは多分「Maps JavaScript API」のみ。月の無料枠内で収まるはず。
  - https://cloud.google.com/maps-platform/
    - コンソールの「IAMと管理」の「割り当て」から使用量が確認できる

# Configuration

# Database creation

# Database initialization

# How to run the test suite

# Services (job queues, cache servers, search engines, etc.)

# Deployment instructions

