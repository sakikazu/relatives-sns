require 'active_record'
require 'active_support'
require 'test/unit'
require 'timecop'
require 'redgreen'
require 'itslog'

ActiveRecord::Base.establish_connection \
  :adapter => 'sqlite3',
  :database => File.dirname(__FILE__) + '/fixtures/itslog.sqlite3'
load File.dirname(__FILE__) + '/fixtures/schema.rb'
load File.dirname(__FILE__) + '/fixtures/article.rb'

Itslog::Railtie.insert

def assert_log(log, msg, severity=0, namespace=nil)
  level = [:debug, :info, :warn, :error, :fatal, :unknown]
  Timecop.freeze(Time.parse('08/16/11 01:01:01'))
  file_name    = File.dirname(__FILE__) + '/fixtures/log.txt'
  File.delete(file_name)
  Rails.logger = ActiveSupport::BufferedLogger.new(file_name)
  Rails.logger.namespace = namespace if namespace.present?
  Rails.logger.send(level[severity], msg)
  assert_equal log, File.read(file_name)
  Timecop.return
end

class Test::Unit::TestCase; end
