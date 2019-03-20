# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#
set :output, {:error => 'log/cron-error.log', :standard => 'log/cron.log'}

# every 1.minutes do
every 1.day, at: '2:00 am' do
  command "cd /usr/local/site/a-dan_v4; lib/create_ranking_total.sh"

  # モデルのメソッドを呼び出す形式は、RVMの影響でgemが読み込めなかった
  # runner "Ranking.create_total"
end
