# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fog"
  s.version = "1.22.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["geemus (Wesley Beary)"]
  s.date = "2014-04-17"
  s.description = "The Ruby cloud services library. Supports all major cloud providers including AWS, Rackspace, Linode, Blue Box, StormOnDemand, and many others. Full support for most AWS services including EC2, S3, CloudWatch, SimpleDB, ELB, and RDS."
  s.email = "geemus@gmail.com"
  s.executables = ["fog"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["bin/fog", "README.md"]
  s.homepage = "http://github.com/fog/fog"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "fog"
  s.rubygems_version = "2.0.2"
  s.summary = "brings clouds to you"

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fog-core>, [">= 1.21.1", "~> 1.21"])
      s.add_runtime_dependency(%q<fog-json>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.5.11", "~> 1.5"])
      s.add_runtime_dependency(%q<fog-brightbox>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<jekyll>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rbvmomi>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<thor>, [">= 0"])
      s.add_development_dependency(%q<rbovirt>, ["= 0.0.24"])
      s.add_development_dependency(%q<shindo>, ["~> 0.3.4"])
      s.add_development_dependency(%q<fission>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<google-api-client>, [">= 0.6.2", "~> 0.6"])
    else
      s.add_dependency(%q<fog-core>, [">= 1.21.1", "~> 1.21"])
      s.add_dependency(%q<fog-json>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 1.5.11", "~> 1.5"])
      s.add_dependency(%q<fog-brightbox>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<jekyll>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rbvmomi>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<thor>, [">= 0"])
      s.add_dependency(%q<rbovirt>, ["= 0.0.24"])
      s.add_dependency(%q<shindo>, ["~> 0.3.4"])
      s.add_dependency(%q<fission>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<google-api-client>, [">= 0.6.2", "~> 0.6"])
    end
  else
    s.add_dependency(%q<fog-core>, [">= 1.21.1", "~> 1.21"])
    s.add_dependency(%q<fog-json>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 1.5.11", "~> 1.5"])
    s.add_dependency(%q<fog-brightbox>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<jekyll>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rbvmomi>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<thor>, [">= 0"])
    s.add_dependency(%q<rbovirt>, ["= 0.0.24"])
    s.add_dependency(%q<shindo>, ["~> 0.3.4"])
    s.add_dependency(%q<fission>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<google-api-client>, [">= 0.6.2", "~> 0.6"])
  end
end
