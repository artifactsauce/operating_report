# coding: utf-8
require 'uri'
require 'net/http'
require 'openssl'
require 'json'

module OperatingReport
  module Tracker
    module Api
      class Toggl
        def initialize(args)
          @token = args['token']
        end

        def get_time_entries(start_date, end_date)
          return _fetch_via_api(
            'time_entries', {
              'start_date' => start_date.round(0).iso8601(0),
              'end_date' => end_date.round(0).iso8601(0),
            }
          )
        end

        private
        def _fetch_via_api(path, queries)
          @base = 'https://www.toggl.com'
          uri = "#{@base}/api/v8/#{path}"
          uri += '?' + URI.encode_www_form(queries) if queries
          uri = URI.parse(uri)
          response = _fetch(uri, 10)
          return JSON.parse(response.body)
        end

        def _fetch(uri, limit = 10)
          raise ArgumentError, 'HTTP redirect too deep' if limit == 0

          request = Net::HTTP::Get.new(uri.request_uri)
          request.basic_auth @token, 'api_token'

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          response = nil
          http.start do |h|
            response = h.request(request)
          end

          case response
          when Net::HTTPSuccess
            response
          when Net::HTTPRedirection
            _fetch(URI.parse(@base + response['location']), limit - 1)
          else
            response.value
          end
        end
      end
    end
  end
end
