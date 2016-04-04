# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
require File.dirname(__FILE__) + '/lib/active_record/acts/enumeration'
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = 'acts_as_enumeration'
  spec.version = ActiveRecord::Acts::Enumeration::VERSION
  spec.authors = ['Paul McKibbin']
  spec.email = ['pmckibbin@gmail.com']

  spec.description = %q(Active Record extender to enable the selection of a database column and have all of it's values enumerable)
  spec.summary = %q(enumerable values from database columns)
  spec.homepage = "http://blackrat.org"
  spec.license = "MIT"

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
