# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "jpmobile"
  s.version = "3.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yoji Shidara", "Shin-ichiro OGAWA"]
  s.date = "2012-08-10"
  s.description = "A Rails plugin for Japanese mobile-phones"
  s.email = "dara@shidara.net"
  s.extra_rdoc_files = ["README", "README.rdoc"]
  s.files = ["README", "README.rdoc"]
  s.homepage = "http://jpmobile-rails.org"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A Rails plugin for Japanese mobile-phones"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rails>, ["~> 3.2.8"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 0"])
      s.add_development_dependency(%q<webrat>, [">= 0"])
      s.add_development_dependency(%q<geokit>, [">= 0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_development_dependency(%q<hpricot>, [">= 0"])
      s.add_development_dependency(%q<rails>, [">= 3.2.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.5.1"])
      s.add_development_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_development_dependency(%q<rspec-rails>, [">= 2.6.0"])
      s.add_development_dependency(%q<webrat>, [">= 0.7.2"])
      s.add_development_dependency(%q<geokit>, [">= 1.5.0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
      s.add_development_dependency(%q<hpricot>, [">= 0.8.3"])
      s.add_development_dependency(%q<git>, [">= 1.2.5"])
    else
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rails>, ["~> 3.2.8"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, [">= 0"])
      s.add_dependency(%q<webrat>, [">= 0"])
      s.add_dependency(%q<geokit>, [">= 0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 3.2.0"])
      s.add_dependency(%q<jeweler>, [">= 1.5.1"])
      s.add_dependency(%q<rspec>, [">= 2.6.0"])
      s.add_dependency(%q<rspec-rails>, [">= 2.6.0"])
      s.add_dependency(%q<webrat>, [">= 0.7.2"])
      s.add_dependency(%q<geokit>, [">= 1.5.0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
      s.add_dependency(%q<hpricot>, [">= 0.8.3"])
      s.add_dependency(%q<git>, [">= 1.2.5"])
    end
  else
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rails>, ["~> 3.2.8"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, [">= 0"])
    s.add_dependency(%q<webrat>, [">= 0"])
    s.add_dependency(%q<geokit>, [">= 0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 3.2.0"])
    s.add_dependency(%q<jeweler>, [">= 1.5.1"])
    s.add_dependency(%q<rspec>, [">= 2.6.0"])
    s.add_dependency(%q<rspec-rails>, [">= 2.6.0"])
    s.add_dependency(%q<webrat>, [">= 0.7.2"])
    s.add_dependency(%q<geokit>, [">= 1.5.0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 1.3.2"])
    s.add_dependency(%q<hpricot>, [">= 0.8.3"])
    s.add_dependency(%q<git>, [">= 1.2.5"])
  end
end
