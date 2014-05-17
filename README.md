#
# Updates
#
* [2014/05/11] Rails4に。configなどの内容もちゃんと合わせた

#
# よく使うコマンド
#

* unicorn再起動
$ cat tmp/unicorn.pid | xargs kill -USR2

* unicorn再起動(こっちじゃないと反映されないことがあるが・・。capistranoの影響？)
$ cat /tmp/unicorn.adan.pid  | xargs kill -QUIT
$ bundle exec unicorn -E production -c config/unicorn.conf.rb -D


* [todo] capistranoで再起動できるようにしたい。デーモンにしたい
```
$ bundle exec sidekiq -C config/sidekiq.yml -e production
```

* crontab update
bundle exec whenever -i


* Nginx再起動
rootで
$ nginx -s reload


# Issues

* 2014/05/17、Firefoxでアルバムの写真アップロード（Uploadify(flash)を使って）が422エラー。Photo#createメソッドに対策記事などメモってる


# Require

* redis
```
sudo /etc/init.d/redis start
# mac
redis-server
```

