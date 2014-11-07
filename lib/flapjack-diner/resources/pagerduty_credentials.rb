require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module PagerdutyCredentials
        def create_pagerduty_credentials(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :string
            validate :query => [:service_key], :as => [:required, :string]
          end
          perform_post('pagerduty_credentials', "/pagerduty_credentials",
                       nil, :pagerduty_credentials => data)
        end

        def pagerduty_credentials(*ids)
          perform_get('pagerduty_credentials', '/pagerduty_credentials', ids)
        end

        def update_pagerduty_credentials(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          raise "'update_pagerduty_credentials' requires at least one check id " \
                'parameter' if ids.nil? || ids.empty?
          validate_params(data) do
            validate :query => [:service_key, :subdomain,
                                :username, :password], :as => :string
          end
          perform_put('pagerduty_credentials', "/pagerduty_credentials", ids,
                      :pagerduty_credentials => data)
        end

        def delete_pagerduty_credentials(*ids)
          raise "'delete_pagerduty_credentials' requires at least one " \
                'pagerduty_credentials id parameter' if ids.nil? || ids.empty?
          perform_delete('/pagerduty_credentials', ids)
        end
      end
    end
  end
end
