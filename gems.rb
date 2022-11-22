# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in utopia.gemspec
gemspec
gem "pry"
group :maintenance, optional: true do
	gem "bake-bundler"
	gem "bake-modernize"
	
	gem "utopia-project"
end
