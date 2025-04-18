# frozen_string_literal: true
require 'ethon_impersonate/easy/http/actionable'
require 'ethon_impersonate/easy/http/post'
require 'ethon_impersonate/easy/http/get'
require 'ethon_impersonate/easy/http/head'
require 'ethon_impersonate/easy/http/put'
require 'ethon_impersonate/easy/http/delete'
require 'ethon_impersonate/easy/http/patch'
require 'ethon_impersonate/easy/http/options'
require 'ethon_impersonate/easy/http/custom'

module EthonImpersonate
  class Easy

    # This module contains logic about making valid HTTP requests.
    module Http

      # Set specified options in order to make a HTTP request.
      # Look at {EthonImpersonate::Easy::Options Options} to see what you can
      # provide in the options hash.
      #
      # @example Set options for HTTP request.
      #   easy.http_request("www.google.com", :get, {})
      #
      # @param [ String ] url The url.
      # @param [ String ] action_name The HTTP action name.
      # @param [ Hash ] options The options hash.
      #
      # @option options :params [ Hash ] Params hash which
      #   is attached to the url.
      # @option options :body [ Hash ] Body hash which
      #   becomes the request body. It is a PUT body for
      #   PUT requests and a POST for everything else.
      # @option options :headers [ Hash ] Request headers.
      #
      # @return [ void ]
      #
      # @see EthonImpersonate::Easy::Options
      def http_request(url, action_name, options = {})
        fabricate(url, action_name, options).setup(self)
      end

      private

      # Return the corresponding action class.
      #
      # @example Return the action.
      #   Action.fabricate(:get)
      #   Action.fabricate(:smash)
      #
      # @param [ String ] url The url.
      # @param [ String ] action_name The HTTP action name.
      # @param [ Hash ] options The option hash.
      #
      # @return [ Easy::EthonImpersonate::Actionable ] The request instance.
      def fabricate(url, action_name, options)
        constant_name = action_name.to_s.capitalize

        if EthonImpersonate::Easy::Http.const_defined?(constant_name)
          EthonImpersonate::Easy::Http.const_get(constant_name).new(url, options)
        else
          EthonImpersonate::Easy::Http::Custom.new(constant_name.upcase, url, options)
        end
      end

    end
  end
end
