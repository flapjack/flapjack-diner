require 'httparty'
require 'json'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

%w(contacts media checks maintenance_periods
   notifications reports rules tags).each do |resource|
  require "flapjack-diner/resources/#{resource}"
end

require 'flapjack-diner/tools'

# NB: clients will need to handle any exceptions caused by,
# e.g., network failures or non-parseable JSON data.

module Flapjack
  # Top level module for Flapjack::Diner API consumer.
  module Diner
    include HTTParty

    format :json

    class << self
      attr_accessor :logger, :return_keys_as_strings

      include Flapjack::Diner::Resources::Contacts
      include Flapjack::Diner::Resources::Media
      include Flapjack::Diner::Resources::Checks
      include Flapjack::Diner::Resources::MaintenancePeriods
      include Flapjack::Diner::Resources::Notifications
      include Flapjack::Diner::Resources::Reports
      include Flapjack::Diner::Resources::Rules
      include Flapjack::Diner::Resources::Tags

      include Flapjack::Diner::Tools
    end
  end
end
