module IELex
end

require 'nokogiri'
require 'lrucache'
require 'cld'
require 'json'

require 'singleton'
require 'open-uri'
require 'pp'

[
  'version',
  'ielex_class',
  'scraper',
  'semantic_field',
].each do |file|
  require File.dirname(__FILE__) + "/ielex/#{file}.rb"
end
