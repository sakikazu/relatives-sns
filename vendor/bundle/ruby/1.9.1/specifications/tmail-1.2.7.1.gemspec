# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "tmail"
  s.version = "1.2.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mikel Lindsaar <raasdnil AT gmail.com>"]
  s.date = "2010-01-05"
  s.description = "TMail is a Ruby-based mail handler. It allows you to compose stadards compliant emails in a very Ruby-way."
  s.email = "raasdnil AT gmail.com"
  s.extensions = ["ext/tmailscanner/tmail/extconf.rb"]
  s.extra_rdoc_files = ["README", "CHANGES", "LICENSE", "NOTES", "Rakefile"]
  s.files = ["README", "CHANGES", "LICENSE", "NOTES", "Rakefile", "ext/tmailscanner/tmail/extconf.rb"]
  s.homepage = "http://tmail.rubyforge.org"
  s.rdoc_options = ["--inline-source", "--title", "TMail", "--main", "README"]
  s.require_paths = ["lib", "ext/tmailscanner"]
  s.rubyforge_project = "tmail"
  s.rubygems_version = "1.8.24"
  s.summary = "Ruby Mail Handler"

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
