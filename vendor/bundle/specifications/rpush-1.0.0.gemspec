# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rpush"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ian Leitch"]
  s.date = "2014-02-09"
  s.description = "Professional grade APNs and GCM for Ruby"
  s.email = ["port001@gmail.com"]
  s.executables = ["rpush"]
  s.files = ["bin/rpush"]
  s.homepage = "https://github.com/rpush/rpush"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.2"
  s.summary = "Professional grade APNs and GCM for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_runtime_dependency(%q<net-http-persistent>, [">= 0"])
    else
      s.add_dependency(%q<multi_json>, ["~> 1.0"])
      s.add_dependency(%q<net-http-persistent>, [">= 0"])
    end
  else
    s.add_dependency(%q<multi_json>, ["~> 1.0"])
    s.add_dependency(%q<net-http-persistent>, [">= 0"])
  end
end
