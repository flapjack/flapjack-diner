require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Contacts
        def create_contacts(*args)
          data = unwrap_create_data(*args)
          validate_params(data) do
            validate :query => [:first_name, :last_name, :email],
                     :as => [:required, :string]
            validate :query => :timezone,   :as => :string
            validate :query => :tags,       :as => :array_of_strings
          end
          perform_post('/contacts', nil, :contacts => data)
        end

        def contacts(*ids)
          perform_get('contacts', '/contacts', ids)
        end

        def update_contacts(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          raise "'update_contacts' requires at least one contact id " \
                'parameter' if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => [:first_name, :last_name,
                                :email, :timezone], :as => :string
            validate :query => :tags,       :as => :array_of_strings
          end
          perform_patch("/contacts/#{escaped_ids(ids)}", nil,
                        update_contacts_ops(params))
        end

        def delete_contacts(*ids)
          raise "'delete_contacts' requires at least one contact id " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete('/contacts', ids)
        end

        private

        def update_contacts_ops(params)
          ops = params.each_with_object([]) do |(k, v), memo|
            case k
            when :add_entity
              memo << patch_add('contacts', 'entities', v)
            when :remove_entity
              memo << patch_remove('contacts', 'entities', v)
            when :add_notification_rule
              memo << patch_add('contacts', 'notification_rules', v)
            when :remove_notification_rule
              memo << patch_remove('contacts', 'notification_rules', v)
            when :first_name, :last_name, :email, :timezone
              memo << patch_replace('contacts', k, v)
            end
          end
          raise "'update_contacts' did not find any valid update " \
                'fields' if ops.empty?
          ops
        end
      end
    end
  end
end
