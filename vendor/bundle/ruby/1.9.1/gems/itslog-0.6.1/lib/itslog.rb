require 'rails'
require 'itslog/railtie'
require 'itslog/configure'
require 'itslog/extension'

module Itslog
  extend self

  def configure(&block)
    Itslog::Configure.configure(&block)
  end
end
