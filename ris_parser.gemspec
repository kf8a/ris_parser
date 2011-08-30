# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ris_parser/version"

Gem::Specification.new do |s|
  s.name        = "ris_parser"
  s.version     = RisParser::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sven Böhm"]
  s.email       = ["bohms@msu.edu"]
  s.homepage    = ""
  s.summary     = %q{A parser for the RIS bibliography format}
  s.description = %q{parses Refman RIS files. might be useful for importing endnote databases}

  s.add_dependency 'parslet'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'ZenTest'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
