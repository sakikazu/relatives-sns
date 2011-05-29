# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

module ::ADanRails3 ## Railsアプリケーションのモジュール（Rails.root.join("/config/application.rb")で定義されてるモジュール)
  class Application
    include Rake::DSL
  end
end
module ::RakeFileUtils
  extend Rake::FileUtilsExt
end

ADanRails3::Application.load_tasks
