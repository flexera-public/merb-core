#!/usr/bin/env gem build
# -*- encoding: utf-8 -*-

# Load this library's version information
require File.expand_path('../lib/merb-core/version', __FILE__)

require 'date'

Gem::Specification.new do |gem|
  gem.name        = 'merb-core'
  gem.version     = Merb::VERSION.dup
  gem.date        = Date.today.to_s
  gem.authors     = ['Ezra Zygmuntowicz']
  gem.email       = 'ez@engineyard.com'
  gem.homepage    = 'http://merbivore.com/'
  gem.description = 'Merb. Pocket rocket web framework.'
  gem.summary     = 'Merb plugin that provides caching (page, action, fragment, object)'

  gem.require_paths = ['lib']
  gem.files = Dir[
    'CHANGELOG',
    'CONTRIBUTORS',
    'LICENSE*',
    'PUBLIC_CHANGELOG',
    'README*',
    'Rakefile',
    'TODO*',
    '{bin,lib,spec,spec10,docs}/**/*',
  ] & `git ls-files -z`.split("\0")

    # Runtime dependencies
    gem.add_dependency 'extlib',     '>= 0.9.13'
    gem.add_dependency 'erubis',     '>= 2.6.2'
    gem.add_dependency 'rake'
    gem.add_dependency 'rack'
    gem.add_dependency 'mime-types', '>= 1.16' # supports ruby-1.9
    gem.add_dependency 'bundler'

  # Development dependencies
  gem.add_development_dependency 'rspec',  '>= 2.5'
  gem.add_development_dependency 'webrat', '>= 0.7'
  gem.add_development_dependency 'memcache-client', '>= 1.8.5' # for session specs
  gem.add_development_dependency 'yard', '>= 0.6'

  # Executable files
  gem.executables  = 'merb'

    # Requirements
    gem.requirements << 'Install the json gem to get faster json parsing.'
    gem.post_install_message = %q{
(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)

                     (::)   U P G R A D I N G    (::)

Thank you for installing merb-core 1.1.3

The planned route for upgrading from merb 1.1.x to 1.2 will involve
changes which may break existing merb apps.  Fear not, fixes for
apps broken by 1.2 should be trivial. Please be sure to read
http://wiki.github.com/merb/merb/release-120 for the details
regarding usage of the upcoming 1.2 release.

(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)
}
    
end
