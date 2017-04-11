require 'simplecov'
require 'coveralls'

SimpleCov.start do
  add_filter 'carry_out/test'
end

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
])

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'carry_out'

require 'minitest/autorun'
