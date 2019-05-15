lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'xoggl/version'

Gem::Specification.new do |spec|
  spec.name = 'xoggl'
  spec.version = Xoggl::VERSION
  spec.authors = ['Filippo Liverani']
  spec.email = ['filippo.liverani@xpeppers.com']
  spec.summary = 'Simple Toggl cli'
  spec.homepage = 'https://github.com/xpeppers/xoggl'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split("\n") - ['.gitignore', '.travis.yml']
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.requirements << 'A Toggl account (https://toggl.com/)'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-mocks'

  spec.add_dependency 'togglv8'
  spec.add_dependency 'awesome_print'
  spec.add_dependency 'holidays'
  spec.add_dependency 'gli'
end
