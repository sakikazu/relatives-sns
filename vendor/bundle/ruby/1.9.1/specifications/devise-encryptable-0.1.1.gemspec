# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "devise-encryptable"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Carlos Antonio da Silva", "Jos\u{e9} Valim", "Rodrigo Flores"]
  s.date = "2012-05-09"
  s.description = "Encryption solution for salted-encryptors on Devise"
  s.email = "contact@plataformatec.com.br"
  s.homepage = "http://github.com/plataformatec/devise_encryptable"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Encryption solution for salted-encryptors on Devise"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<devise>, [">= 2.1.0.rc"])
    else
      s.add_dependency(%q<devise>, [">= 2.1.0.rc"])
    end
  else
    s.add_dependency(%q<devise>, [">= 2.1.0.rc"])
  end
end
