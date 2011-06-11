#!/bin/sh

db='adan'
user='root'
password='saki0745'

# バックアップファイルを何日分残しておくか
period=7
# バックアップファイルを保存するディレクトリ
dirpath='/home/sakikazu/bak'

# ファイル名を定義(※ファイル名で日付がわかるようにしておきます))
filename="$db"_`date +%y%m%d`

# mysqldump実行
mysqldump --opt --user=$user --password=$password $db > $dirpath/$filename.sql

# パーミッション変更
#chmod 700 $dirpath/$filename.sql

# 古いバックアップファイルを削除
oldfile="$db"_`date --date "$period days ago" +%y%m%d`
rm -f $dirpath/$oldfile.sql
