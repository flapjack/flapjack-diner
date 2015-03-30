require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Metrics

        def metrics_check_freshness
          perform_get('check_freshness', '/metrics/check_freshness')
        end

        def metrics_events
          perform_get('events', '/metrics/events')
        end

      end
    end
  end
end
