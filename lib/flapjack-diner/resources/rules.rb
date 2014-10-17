require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Rules

        # 3: Notification Rules
        def create_contact_rules(*args)
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'create_contact_rules' requires at least one contact id parameter" if ids.nil? || ids.empty?
          perform_post("/contacts/#{escaped_ids(ids)}/rules", nil, :rules => data)
        end

        def rules(*ids)
          perform_get('rules', '/rules', ids)
        end

        def update_rules(*args)
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'update_rules' requires at least one rule id parameter" if ids.nil? || ids.empty?
          ops = params.inject([]) do |memo, (k,v)|
            case k
            when :add_tag
              memo << {:op    => 'add',
                       :path  => '/rules/0/links/tags/-',
                       :value => v}
            when :remove_tag
              memo << {:op    => 'remove',
                       :path  => "/rules/0/links/tags/#{v}"}
            end
            memo
          end
          raise "'update_rules' did not find any valid update fields" if ops.empty?
          perform_patch("/rules/#{escaped_ids(ids)}", nil, ops)
        end

        def delete_rules(*ids)
          raise "'delete_rules' requires at least one rule id parameter" if ids.nil? || ids.empty?
          perform_delete('/rules', ids)
        end

      end

    end
  end
end
