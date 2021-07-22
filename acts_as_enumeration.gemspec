# frozen_string_literal: true

require 'English'

lib = File.expand_path('lib', __dir__)
require File.dirname(__FILE__) + '/lib/active_record/acts/enumeration'
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = 'acts_as_enumeration'
  spec.version = ActiveRecord::Acts::Enumeration::VERSION
  spec.authors = ['Paul McKibbin']
  spec.email = ['pmckibbin@gmail.com']

  spec.description = 'Active Record extender to make a database column enumerable and queryable'
  spec.summary = 'enumerable values from database columns'
  spec.homepage = 'http://blackrat.org'
  spec.license = 'MIT'

  spec.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activerecord', '~> 6.1'
  spec.add_development_dependency 'bundler', '~> 2.2.24'
  spec.add_development_dependency 'minitest', '~> 5.14'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'sqlite3', '~> 1.4'
end
