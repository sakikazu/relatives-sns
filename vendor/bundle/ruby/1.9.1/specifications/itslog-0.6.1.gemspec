# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "itslog"
  s.version = "0.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Thomas Marino"]
  s.date = "2011-09-29"
  s.description = "\n    `itslog` is a log formatter designed to aid rails 3 development.\n  "
  s.email = "writejm@gmail.com"
  s.homepage = "http://github.com/johnnytommy/itslog"
  s.require_paths = ["lib"]
  s.rubyforge_project = "itslog"
  s.rubygems_version = "1.8.24"
  s.summary = "itslog makes logs more useful for rails 3 development."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
