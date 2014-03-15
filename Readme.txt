testtest

2013/09/26、RVM
rvmバージョンアップで、.rvmrcから.ruby-versionに移行したらしいが、.rvmrcがないと適用されないんだが
どうすればいいんだ？



#
# よく使うコマンド
#

bundle exec rake assets:precompile RAILS_ENV=production

# crontab update
bundle exec whenever -i

# unicorn再起動
$ cat tmp/unicorn.pid | xargs kill -USR2


!!! 今（2013/11/06）、これじゃないとUnicorn再起動できない。これでいいんだっけか？
/etc/init.d/unicorn_a-dan restart


# Nginx再起動
rootで
$ nginx -s reload

