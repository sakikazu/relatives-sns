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
$ cat /tmp/unicorn.adan.pid  | xargs kill -QUIT
$ bundle exec unicorn -E production -c config/unicorn.conf.rb -D


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

