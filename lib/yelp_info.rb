require "json"
require "http"
require 'yaml'
require "optparse"

SECRET_CONFIG = YAML.safe_load(File.read('config/secrets.yml'))

# Constants, do not change these
API_HOST = "https://api.yelp.com".freeze
SEARCH_PATH = "/v3/businesses/search".freeze
BUSINESS_PATH = "/v3/businesses/".freeze
TOKEN_PATH = "/oauth2/token".freeze
GRANT_TYPE = "client_credentials".freeze


DEFAULT_BUSINESS_ID = "yelp-san-francisco"
DEFAULT_TERM = "dinner"
DEFAULT_LOCATION = "San Francisco, CA"
SEARCH_LIMIT = 5

# Returns your access token
def bearer_token
  "Bearer #{SECRET_CONFIG['yelp_token']}"
end


# Make a request to the Fusion search endpoint. Full documentation is online at:
# https://www.yelp.com/developers/documentation/v3/business_search
#
# term - search term used to find businesses
# location - what geographic location the search should happen
#
# Examples
#
#   search("burrito", "san francisco")
#   # => {
#          "total": 1000000,
#          "businesses": [
#            "name": "El Farolito"
#            ...
#          ]
#        }
#
#   search("sea food", "Seattle")
#   # => {
#          "total": 1432,
#          "businesses": [
#            "name": "Taylor Shellfish Farms"
#            ...
#          ]
#        }
#
# Returns a parsed json object of the request
def search(term, location)
  url = "#{API_HOST}#{SEARCH_PATH}"
  params = {
    term: term,
    location: location,
    limit: SEARCH_LIMIT
  }

  response = HTTP.auth(bearer_token).get(url, params: params)
  response.parse
end


# Look up a business by a given business id. Full documentation is online at:
# https://www.yelp.com/developers/documentation/v3/business
#
# business_id - a string business id
#
# Examples
#
#   business("yelp-san-francisco")
#   # => {
#          "name": "Yelp",
#          "id": "yelp-san-francisco"
#          ...
#        }
#
# Returns a parsed json object of the request
def business(business_id)
  url = "#{API_HOST}#{BUSINESS_PATH}#{business_id}"

  response = HTTP.auth(bearer_token).get(url)
  response.parse
end

search(DEFAULT_TERM, DEFAULT_LOCATION)["businesses"].each {|biz| puts biz["name"]}
puts JSON.pretty_generate(business(DEFAULT_BUSINESS_ID))
