# frozen_string_literal: false

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/yelp_info.rb'

CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
YELP_TOKEN = CONFIG['yelp_token']
CORRECT = YAML.safe_load(File.read('spec/fixtures/yelp_results.yml'))

CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
CASSETTE_FILE = 'yelp_api'.freeze
