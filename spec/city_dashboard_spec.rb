# frozen_string_literal: false

require_relative 'spec_helper.rb'

describe 'Test City Dashboard' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<YELP_TOKEN>') { YELP_TOKEN }
    c.filter_sensitive_data('<YELP_TOKEN_ESC>') { CGI.escape(YELP_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end
end
