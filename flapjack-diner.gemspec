# -*- encoding: utf-8 -*-
require File.expand_path('../lib/flapjack-diner/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Ali Graham']
  gem.email         = ['ali.graham@bulletproof.net']
  gem.summary       = 'Access the API of a Flapjack system monitoring server'
  gem.description   = 'Wraps raw API calls to a Flapjack server API with ' \
                      'friendlier ruby methods.'
  gem.homepage      = 'https://github.com/flapjack/flapjack-diner'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR) -
                      ['Gemfile.lock']
  gem.executables   = gem.files.grep(/^bin\//).map {|f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|spec|features)\//)
  gem.name          = 'flapjack-diner'
  gem.require_paths = ['lib']
  gem.version       = Flapjack::Diner::VERSION

  gem.add_dependency('httparty', '= 0.13.5')
  gem.add_dependency('json', '>= 1.7.7')
end
