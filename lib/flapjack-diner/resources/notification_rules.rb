require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module NotificationRules
        def create_contact_notification_rules(*args)
          ids, data = unwrap_ids(*args), unwrap_create_data(*args)
          raise "'create_contact_notification_rules' requires at least one " \
                'contact id parameter' if ids.nil? || ids.empty?
          validate_params(data) do
            validate :query => STRING_PARAMS,  :as => :array_of_strings
            validate :query => BOOLEAN_PARAMS, :as => :boolean
          end
          perform_post("/contacts/#{escaped_ids(ids)}/notification_rules",
                       nil, :notification_rules => data)
        end

        def notification_rules(*ids)
          perform_get('notification_rules', '/notification_rules', ids)
        end

        def update_notification_rules(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          raise "'update_notification_rules' requires at least one " \
                'notification rule id parameter' if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => STRING_PARAMS,  :as => :array_of_strings
            validate :query => BOOLEAN_PARAMS, :as => :boolean
          end
          perform_patch("/notification_rules/#{escaped_ids(ids)}", nil,
                        update_notification_rules_ops(params))
        end

        def delete_notification_rules(*ids)
          raise "'delete_notification_rules' requires at least one " \
                'notification rule id parameter' if ids.nil? || ids.empty?
          perform_delete('/notification_rules', ids)
        end

        private

        STRING_PARAMS  = [:entities, :regex_entities, :tags, :regex_tags,
                          :unknown_media, :warning_media, :critical_media]
        BOOLEAN_PARAMS = [:unknown_blackhole, :warning_blackhole,
                          :critical_blackhole]
        OTHER_PARAMS   = [:time_restrictions]

        def update_notification_rules_ops(params)
          ops = params.each_with_object([]) do |(k, v), memo|
            next unless (STRING_PARAMS + BOOLEAN_PARAMS + OTHER_PARAMS).include?(k)
            memo << patch_replace('notification_rules', k, v)
          end
          raise "'update_notification_rules' did not find any valid update " \
                'fields' if ops.empty?
          ops
        end
      end
    end
  end
end
