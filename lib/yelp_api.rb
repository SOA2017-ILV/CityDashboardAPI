# frozen_string_literal: false

require 'json'
require 'http'
require 'yaml'

module CityDashboard
  module Errors
    # Not allowed to access resource
    Unauthorized = Class.new(StandardError)
    # Requested resource not found
    NotFound = Class.new(StandardError)
  end

  # Library for Yelp Web API
  class YelpApi
    DEFAULT_SEARCH_LIMIT = 5
    # Encapsulates API response success and errors
    class Response
      HTTP_ERROR = {
        401 => Errors::Unauthorized,
        404 => Errors::NotFound
      }.freeze

      def initialize(response)
        @response = response
      end

      def successful?
        HTTP_ERROR.keys.include?(@response.code) ? false : true
      end

      def response_or_error
        successful? ? @response : raise(HTTP_ERROR[@response.code])
      end
    end

    def initialize(token)
      @yelp_token = token
    end

    # Make a request to the Fusion search endpoint.
    # term - search term used to find businesses
    # location - what geographic location the search should happen
    #
    # Examples
    #
    #   search('burrito', 'san francisco')
    #   # => {
    #          'total': 1000000,
    #          'businesses': [
    #            'name': 'El Farolito'
    #            ...
    #          ]
    #        }
    #
    #   search('sea food', 'Seattle')
    #   # => {
    #          'total': 1432,
    #          'businesses': [
    #            'name': 'Taylor Shellfish Farms'
    #            ...
    #          ]
    #        }
    #
    # Returns a parsed json object of the request
    def search(term, location, search_limit = DEFAULT_SEARCH_LIMIT)
      params = {
        term: term,
        location: location,
        limit: search_limit
      }

      search_url = YelpApi.path('/v3/businesses/search')
      call_yelp_url(search_url, params).parse
    end

    # Look up a business by a given business id.
    #
    # business_id - a string business id
    #
    # Examples
    #
    #   business('yelp-san-francisco')
    #   # => {
    #          'name': 'Yelp',
    #          'id': 'yelp-san-francisco'
    #          ...
    #        }
    #
    # Returns a parsed json object of the request
    def business(business_id)
      business_url = YelpApi.path("/v3/businesses/#{business_id}")
      call_yelp_url(business_url).parse
    end

    def self.path(path)
      'https://api.yelp.com' + path
    end

    private

    def call_yelp_url(url, params = nil)
      auth = "Bearer #{@yelp_token}"
      # resp = HTTP.headers('Authorization' => auth).get(url, params: params)
      resp = HTTP.auth(auth).get(url, params: params)
      Response.new(resp).response_or_error
    end
  end
end
