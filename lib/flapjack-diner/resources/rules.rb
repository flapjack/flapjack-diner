require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Rules

        def create_contact_rules(*args)
          ids, data = unwrap_ids(*args), unwrap_create_data(*args)
          raise "'create_contact_rules' requires at least one contact id parameter" if ids.nil? || ids.empty?
          validate_params(data) do
            validate :query => :id, :as => :string
            # TODO proper validation of time_restrictions field
          end
          perform_post("/contacts/#{escaped_ids(ids)}/rules", nil, :rules => data)
        end

        def rules(*ids)
          perform_get('rules', '/rules', ids)
        end

        def update_rules(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          raise "'update_rules' requires at least one rule id " \
                'parameter' if ids.nil? || ids.empty?
          # validate_params(data) do
            # TODO proper validation of time_restrictions field
          # end
          perform_patch("/rules/#{escaped_ids(ids)}", nil,
                        update_rules_ops(params))
        end

        def delete_rules(*ids)
          raise "'delete_rules' requires at least one rule id parameter" if ids.nil? || ids.empty?
          perform_delete('/rules', ids)
        end

        private

        # STRING_PARAMS  = []
        # BOOLEAN_PARAMS = []
        OTHER_PARAMS   = [:time_restrictions]

        def update_rules_ops(params)
          ops = params.each_with_object([]) do |(k, v), memo|
            case k
            when :time_restrictions
              memo << patch_replace('rules', k, v)
            when :add_tag
              memo << patch_add('rules', 'tags', v)
            when :remove_tag
              memo << patch_remove('rules', 'tags', v)
            end
          end
          raise "'update_rules' did not find any valid update " \
                'fields' if ops.empty?
          ops
        end

      end
    end
  end
end
