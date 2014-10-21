require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module NotificationRules

        # 3: Notification Rules
        def create_contact_notification_rules(*args)
          ids, data = unwrap_create_ids_and_data(*args)
          raise "'create_contact_notification_rules' requires at least one contact id parameter" if ids.nil? || ids.empty?
          data.each do |d|
            validate_params(d) do
              validate :query => [:entities, :regex_entities, :tags, :regex_tags,
                :unknown_media, :warning_media, :critical_media], :as => :array_of_strings
              validate :query => [:unknown_blackhole, :warning_blackhole, :critical_blackhole],
                :as => :boolean
            end
          end
          perform_post("/contacts/#{escaped_ids(ids)}/notification_rules", nil, :notification_rules => data)
        end

        def notification_rules(*ids)
          perform_get('notification_rules', '/notification_rules', ids)
        end

        def update_notification_rules(*args)
          ids, params, data = unwrap_ids_params_and_data(*args)
          raise "'update_notification_rules' requires at least one notification rule id parameter" if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => [:entities, :regex_entities, :tags, :regex_tags,
              :unknown_media, :warning_media, :critical_media], :as => :array_of_strings
            validate :query => [:unknown_blackhole, :warning_blackhole, :critical_blackhole],
              :as => :boolean
          end
          ops = params.inject([]) do |memo, (k,v)|
            case k
            when :entities, :regex_entities, :tags, :regex_tags,
              :time_restrictions, :unknown_media, :warning_media, :critical_media,
              :unknown_blackhole, :warning_blackhole, :critical_blackhole

              memo << {:op    => 'replace',
                       :path  => "/notification_rules/0/#{k.to_s}",
                       :value => v}
            end
            memo
          end
          raise "'update_notification_rules' did not find any valid update fields" if ops.empty?
          perform_patch("/notification_rules/#{escaped_ids(ids)}", nil, ops)
        end

        def delete_notification_rules(*ids)
          raise "'delete_notification_rules' requires at least one notification rule id parameter" if ids.nil? || ids.empty?
          perform_delete('/notification_rules', ids)
        end

      end

    end
  end
end
