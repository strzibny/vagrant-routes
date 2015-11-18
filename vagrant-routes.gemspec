Gem::Specification.new do |spec|
  spec.name          = 'vagrant-routes'
  spec.version       = '0.0.4'
  spec.homepage      = 'https://github.com/strzibny/vagrant-routes'
  spec.summary       = 'Access OpenShift routes on the host'

  spec.authors       = ['Josef Strzibny']
  spec.email         = ['strzibny@strzibny.name']

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
