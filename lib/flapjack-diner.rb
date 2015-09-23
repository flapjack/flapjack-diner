require 'httparty'
require 'json'

require 'flapjack-diner/log_formatter'
require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'
require 'flapjack-diner/index_range'

require 'flapjack-diner/resources'
require 'flapjack-diner/relationships'
require 'flapjack-diner/tools'

# HTTParty master contains a non-hacky way of doing this, but 0.13.5 doesn't
module HTTParty
  module Logger
    def self.build(logger, level, formatter)
      level ||= :info
      formatter ||= :apache

      case formatter
      when :'flapjack-diner'
        Flapjack::Diner::LogFormatter.new(logger, level)
      when :curl
        Logger::CurlLogger.new(logger, level)
      else
        Logger::ApacheLogger.new(logger, level)
      end
    end
  end
end

# NB: clients will need to handle any exceptions caused by,
# e.g., network failures or non-parseable JSON data.
module Flapjack

  # Top level module for Flapjack::Diner API consumer.
  module Diner
    UUID_RE = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"

    include HTTParty
    format :json

    class << self
      attr_accessor :return_keys_as_strings

      # redefine HTTParty logger methods for getter/setter style
      alias :original_logger :logger
      def logger=(lgr)
        original_logger(lgr, :info, :'flapjack-diner')
      end
      def logger
        default_options[:logger]
      end

      def output
        return if !instance_variable_defined?('@response') || @response.nil?
        @response.output
      end

      def context
        return if !instance_variable_defined?('@response') || @response.nil?
        @response.context
      end

      def error
        return if !instance_variable_defined?('@response') || @response.nil?
        @response.error
      end
    end

    include Flapjack::Diner::Resources
    include Flapjack::Diner::Relationships
    include Flapjack::Diner::Tools
  end
end
