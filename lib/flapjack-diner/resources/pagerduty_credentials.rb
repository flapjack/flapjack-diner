require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module PagerdutyCredentials

        # 2a: Pagerduty credentials
        def create_contact_pagerduty_credentials(*args)
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'create_contact_pagerduty_credentials' requires at least one contact id parameter" if ids.nil? || ids.empty?
          data.each do |d|
            validate_params(d) do
              validate :query => [:service_key, :subdomain, :username, :password], :as => [:required, :string]
            end
          end
          perform_post("/contacts/#{escaped_ids(ids)}/pagerduty_credentials", nil, :pagerduty_credentials => data)
        end

        def pagerduty_credentials(*ids)
          extract_get('pagerduty_credentials', perform_get('/pagerduty_credentials', ids))
        end

        def update_pagerduty_credentials(*args)
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'update_pagerduty_credentials' requires at least one pagerduty_credentials id parameter" if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => [:service_key, :subdomain, :username, :password], :as => :string
          end
          ops = params.inject([]) do |memo, (k,v)|
            case k
            when :service_key, :subdomain, :username, :password
              memo << {:op    => 'replace',
                       :path  => "/pagerduty_credentials/0/#{k.to_s}",
                       :value => v}
            end
            memo
          end
          raise "'update_pagerduty_credentials did not find any valid update fields" if ops.empty?
          perform_patch("/pagerduty_credentials/#{escaped_ids(ids)}", nil, ops)
        end

        def delete_pagerduty_credentials(*ids)
          raise "'delete_pagerduty_credentials' requires at least one pagerduty_credentials id parameter" if ids.nil? || ids.empty?
          perform_delete('/pagerduty_credentials', ids)
        end

      end

    end
  end
end
