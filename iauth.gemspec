# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Eric Zhang"]
  gem.email         = ["i@qinix.com"]
  gem.description   = %q{Authenticate with BUAA's ihome.}
  gem.summary   = %q{Authenticate with BUAA's ihome.}
  gem.homepage      = "https://github.com/qinix/iauth"

  gem.add_runtime_dependency     'httparty'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "iauth"
  gem.require_paths = ["lib"]
  gem.version       = '1.0.0'
end
