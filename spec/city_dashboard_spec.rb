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

  describe 'Yelp information' do
    it 'HAPPY: should ' do
      resp = CityDashboard::YelpApi.new(YELP_TOKEN).business('yelp-san-francisco')
      _(resp['name']).must_equal CORRECT['name']
      _(resp['location']['city']).must_equal CORRECT['location']['city']
    end
    it 'SAD: should raise exception when unauthorized' do
      proc do
        CityDashboard::YelpApi.new('bad_token').search('dinner', 'SF')
      end.must_raise CityDashboard::Errors::Unauthorized
    end
  end
end
