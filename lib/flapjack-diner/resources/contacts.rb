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
            validate :query => :id,         :as => :string
            validate :query => :name,       :as => [:required, :string]
            validate :query => :timezone,   :as => :string
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
            validate :query => [:name, :timezone], :as => :string
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
            when :name, :timezone
              memo << patch_replace('contacts', k, v)
            when :add_medium
              memo << patch_add('contacts', 'media', v)
            when :remove_medium
              memo << patch_remove('contacts', 'media', v)
            when :add_rule
              memo << patch_add('contacts', 'rules', v)
            when :remove_rule
              memo << patch_remove('contacts', 'rules', v)
            when :add_tag
              memo << patch_add('contacts', 'tags', v)
            when :remove_tag
              memo << patch_remove('contacts', 'tags', v)

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
