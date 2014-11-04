require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module PagerdutyCredentials
        def create_contact_pagerduty_credentials(*args)
          ids, data = unwrap_ids(*args), unwrap_create_data(*args)
          raise "'create_contact_pagerduty_credentials' requires at least " \
                'one contact id parameter' if ids.nil? || ids.empty?
          validate_params(data) do
            validate :query => :id, :as => :string
            validate :query => [:service_key], :as => [:required, :string]
          end
          perform_post("/contacts/#{escaped_ids(ids)}/pagerduty_credentials",
                       nil, :pagerduty_credentials => data)
        end

        def pagerduty_credentials(*ids)
          perform_get('pagerduty_credentials', '/pagerduty_credentials', ids)
        end

        def update_pagerduty_credentials(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          raise "'update_pagerduty_credentials' requires at least one " \
                ' pagerduty_credentials id parameter' if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => [:service_key, :subdomain,
                                :username, :password], :as => :string
          end
          perform_patch("/pagerduty_credentials/#{escaped_ids(ids)}",
                        nil, update_pagerduty_credentials_ops(params))
        end

        def delete_pagerduty_credentials(*ids)
          raise "'delete_pagerduty_credentials' requires at least one " \
                'pagerduty_credentials id parameter' if ids.nil? || ids.empty?
          perform_delete('/pagerduty_credentials', ids)
        end

        private

        def update_pagerduty_credentials_ops(params)
          ops = params.each_with_object([]) do |(k, v), memo|
            next unless [:service_key, :subdomain,
                         :username, :password].include?(k)
            memo << patch_replace('pagerduty_credentials', k, v)
          end
          raise "'update_pagerduty_credentials' did not find any valid " \
                'update fields' if ops.empty?
          ops
        end
      end
    end
  end
end
