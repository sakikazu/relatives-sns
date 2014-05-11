#
# Updates
#
* [2014/05/11] Rails4に。configなどの内容もちゃんと合わせた

#
# よく使うコマンド
#

# crontab update
bundle exec whenever -i

# unicorn再起動
$ cat tmp/unicorn.pid | xargs kill -USR2


# Nginx再起動
rootで
$ nginx -s reload

