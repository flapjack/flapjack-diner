require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Checks
        def create_checks(*args)
          data = unwrap_create_data(*args)
          validate_params(data) do
            validate :query => :entity_id, :as => [:required, :string]
            validate :query => :name,      :as => [:required, :string]
            validate :query => :tags,      :as => :array_of_strings
          end
          perform_post('/checks', nil, :checks => data)
        end

        def checks(*ids)
          perform_get('checks', '/checks', ids)
        end

        def update_checks(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          raise "'update_checks' requires at least one check id " \
                'parameter' if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => :enabled, :as => :boolean
            validate :query => :tags,    :as => :array_of_strings
          end
          perform_patch("/checks/#{escaped_ids(ids)}", nil,
                        update_checks_ops(params))
        end

        private

        def update_checks_ops(params)
          ops = params.each_with_object([]) do |(k, v), memo|
            case k
            when :enabled
              memo << patch_replace('checks', k, v)
            when :add_tag
              memo << patch_add('checks', 'tags', v)
            when :remove_tag
              memo << patch_remove('checks', 'tags', v)
            end
          end
          raise "'update_checks' did not find any valid update " \
                'fields' if ops.empty?
          ops
        end
      end
    end
  end
end
