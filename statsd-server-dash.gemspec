# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "statsd-server-dash"
  s.version     = "0.0.1"
  s.authors     = ["mikeycgto"]
  s.email       = ["mikeycgto@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{statsd-server-dash}
  s.description = %q{statsd-server-dash - graphs and stuff. yay.}

  s.rubyforge_project = "statsd-server-dash"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency "sinatra"
  s.add_dependency "sinatra-contrib"
  s.add_dependency "sinatra-redis"

  s.add_dependency "redis"

  s.add_dependency "haml"
  s.add_dependency "yajl-ruby"

  s.add_development_dependency "shotgun"
  s.add_development_dependency "thin"
end
