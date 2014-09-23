require 'httparty'
require 'json'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

['contacts', 'media', 'pagerduty_credentials', 'notification_rules',
 'entities', 'checks', 'maintenance_periods', 'notifications',
 'reports'].each do |resource|

  require "flapjack-diner/resources/#{resource}"
end

require 'flapjack-diner/tools'

# NB: clients will need to handle any exceptions caused by,
# e.g., network failures or non-parseable JSON data.

module Flapjack
  module Diner

    include HTTParty

    format :json

    class << self
      attr_accessor :logger, :return_keys_as_strings

      include Flapjack::Diner::Resources::Contacts
      include Flapjack::Diner::Resources::Media
      include Flapjack::Diner::Resources::PagerdutyCredentials
      include Flapjack::Diner::Resources::NotificationRules
      include Flapjack::Diner::Resources::Entities
      include Flapjack::Diner::Resources::Checks
      include Flapjack::Diner::Resources::MaintenancePeriods
      include Flapjack::Diner::Resources::Notifications
      include Flapjack::Diner::Resources::Reports

      include Flapjack::Diner::Tools
    end
  end
end
