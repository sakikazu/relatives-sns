$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ItslogTest < Test::Unit::TestCase

  def test_default_severity_color
    Itslog::Configure.reset
    assert_log "\n\e[37m01:01:01 \e[37mtest\n", 'test', 0
    assert_log "\n\e[37m01:01:01 \e[37mtest\n", 'test', 1
    assert_log "\n\e[33m01:01:01 \e[37mtest\n", 'test', 2
    assert_log "\n\e[31m01:01:01 \e[37mtest\n", 'test', 3
    assert_log "\n\e[31m01:01:01 \e[37mtest\n", 'test', 4
    assert_log "\n\e[37m01:01:01 \e[37mtest\n", 'test', 5
  end

  def test_custom_severity_color
    Itslog::Configure.reset
    Itslog.configure do |config|
      config.severity_colors = ['red', 'orange', 'yellow', 'green', 'blue', 'indigo']
      config.color_by = :severity
    end
    assert_log "\nred01:01:01 \e[37mtest\n"   , 'test', 0
    assert_log "\norange01:01:01 \e[37mtest\n", 'test', 1
    assert_log "\nyellow01:01:01 \e[37mtest\n", 'test', 2
    assert_log "\ngreen01:01:01 \e[37mtest\n" , 'test', 3
    assert_log "\nblue01:01:01 \e[37mtest\n"  , 'test', 4
    assert_log "\nindigo01:01:01 \e[37mtest\n", 'test', 5
  end

  def test_default_namespaces
    Itslog::Configure.reset
    assert_log "\e[32m01:01:01 action_controller \e[37mtest\n", 'test', 0, 'action_controller'
    assert_log "\e[36m01:01:01 action_view \e[37mtest\n"      , 'test', 0, 'action_view'
    assert_log "\e[94m01:01:01 active_record \e[37mtest\n"    , 'test', 0, 'active_record'
    assert_log "\e[94m01:01:01 mongo \e[37mtest\n"            , 'test', 0, 'mongo'
  end

  def test_custom_namespace_color
    Itslog::Configure.reset
    Itslog.configure do |config|
      config.format = '%n %m'
      config.namespace_colors = {
        'action_controller' => 'red',
        'action_view'       => 'orange',
        'active_record'     => 'yellow',
        'mongo'             => 'green'}
    end
    assert_log "redaction_controller \e[37mtest\n", 'test', 0, 'action_controller'
    assert_log "orangeaction_view \e[37mtest\n"   , 'test', 0, 'action_view'
    assert_log "yellowactive_record \e[37mtest\n" , 'test', 0, 'active_record'
    assert_log "greenmongo \e[37mtest\n"          , 'test', 0, 'mongo'
  end

  def test_custom_format
    Itslog::Configure.reset
    Itslog.configure { |config| config.format = '[%n] %m' }
    assert_log "\n\e[37m[] \e[37mtest\n", 'test', 0
    assert_log "\e[32m[action_controller] \e[37mtest\n", 'test', 0, 'action_controller'
  end

  def test_default_message_color
    Itslog::Configure.reset
    assert_log "\e[32m01:01:01 action_controller \e[37mtest\n", 'test', 0, 'action_controller'
  end

  def test_custom_message_color
    Itslog::Configure.reset
    Itslog.configure do |config|
      config.message_color = 'black'
    end
    assert_log "\e[32m01:01:01 action_controller blacktest\n", 'test', 0, 'action_controller'
  end

  def test_custom_timestamp_format
    Itslog::Configure.reset
    Itslog.configure { |config| config.timestamp_format = '%m-%e-%y %H:%M' }
    assert_log "\n\e[37m08-16-11 01:01 \e[37mtest\n", 'test', 0
  end
end
