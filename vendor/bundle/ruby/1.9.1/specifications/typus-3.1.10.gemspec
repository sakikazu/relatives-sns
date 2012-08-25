# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "typus"
  s.version = "3.1.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Francesc Esplugas"]
  s.date = "2012-03-27"
  s.description = "Ruby on Rails Admin Panel (Engine) to allow trusted users edit structured content."
  s.email = ["support@typuscmf.com"]
  s.homepage = "http://www.typuscmf.com/"
  s.require_paths = ["lib"]
  s.rubyforge_project = "typus"
  s.rubygems_version = "1.8.24"
  s.summary = "Effortless backend interface for Ruby on Rails applications. (Admin scaffold generator)"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bcrypt-ruby>, ["~> 3.0.0"])
      s.add_runtime_dependency(%q<jquery-rails>, [">= 0"])
      s.add_runtime_dependency(%q<rails>, [">= 3.1.3"])
    else
      s.add_dependency(%q<bcrypt-ruby>, ["~> 3.0.0"])
      s.add_dependency(%q<jquery-rails>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 3.1.3"])
    end
  else
    s.add_dependency(%q<bcrypt-ruby>, ["~> 3.0.0"])
    s.add_dependency(%q<jquery-rails>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 3.1.3"])
  end
end
