itslog
======

`itslog` is a log formatter designed to aid rails development.

The formatting will prepend all log statements with a colored header and additional information about the statement. The information and structure of the new statements is customizable through configuration.

[timestamp] [rails namespace] [log message], example:

![](http://cdn.lts.cr/files/bf23b77669a77fb444b6/itslog_example1.jpg)

Errors and warnings will also stand out, example:

![](http://cdn.lts.cr/files/bf23b77669a77fb444b6/itslog_example2.jpg)

In addition to more readable logs, you can tail and grep specific parts of your application. example:

    tail -f log/development.log | grep active_record

Use itslog in conjunction with [axe](http://github.com/johmas/axe) for faster access to your logs.

Install
-------

Add to your Gemfile in Rails:

``` ruby
group :development, :test do
  gem 'itslog'
end
```

Configure
-----------

Itslog does not need to be configured unless you want to customize the output structure and color.

Example:

``` ruby
if Rails.env.development? || Rails.env.test?

  Itslog.configure do |config|
    config.namespace_colors = {
      'action_controller' => "\e[32m",
      'active_record'     => "\e[94m",
      'mongo'             => "\e[94m",
      'action_view'       => "\e[36m"
    }
    config.format = "%t [%n]: %m"
    config.message_color = "\e[37m"
    config.timestamp_format = "%Y-%b-%d %H:%M:%S %z"
  end

end
```

Configure format by building a string anyway you'd like and using the following variables:

    %t (timestamp)
    %n (namespace)
    %m (log message)

Configure time format using a strftime format string. [foragoodstrftime](http://www.foragoodstrftime.com/) is a nice reference.

I don't recommend coloring by severity because it's not very useful. To color by severity instead of the default of namespace:

``` ruby
if Rails.env.development? || Rails.env.test?

  Itslog.configure do |config|
    config.color_by :severity
    # debug, info, warning, error, fatal, unknown
    config.severity_colors = ["\e[36m","\e[32m","\e[33m","\e[31m","\e[31m","\e[37m"]
  end

end
```

Place the configuration in an initializer:

    config/initializers/itslog.rb

Reference
-------------

An example set of ANSI colors:

    \e[30m grey
    \e[31m red
    \e[32m green
    \e[33m yellow
    \e[34m purple
    \e[35m pink
    \e[36m cyan
    \e[37m white

    \e[90m light grey
    \e[91m light red
    \e[92m light green
    \e[93m light yellow
    \e[94m light purple
    \e[95m light pink
    \e[96m light cyan

All additional information can be found in this video: [The Log Song](http://nicktoons.nick.com/videos/clip/stimpys-big-day-log-song-1.html)

Contact
-----------

Please message me through github if you have any feature requests or issues. Thank you for all your feedback so far.
