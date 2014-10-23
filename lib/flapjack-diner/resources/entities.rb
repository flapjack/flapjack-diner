require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Entities
        def create_entities(*args)
          data = unwrap_create_data(*args)
          validate_params(data) do
            validate :query => :id,   :as => [:required, :string]
            validate :query => :name, :as => :string
            validate :query => :tags, :as => :array_of_strings
          end
          perform_post('/entities', nil, :entities => data)
        end

        def entities(*ids)
          perform_get('entities', '/entities', ids)
        end

        def entities_matching(name_re)
          raise "Must be a regexp: #{name_re.inspect}" unless
            name_re.is_a?(Regexp)
          entities.reject {|e| name_re.match(e[:name]).nil? }
        end

        def update_entities(*args)
          ids, params = unwrap_ids(*args), unwrap_params(*args)
          raise "'update_entities' requires at least one entity id " \
                ' parameter' if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => :name, :as => :string
            validate :query => :tags, :as => :array_of_strings
          end
          perform_patch("/entities/#{escaped_ids(ids)}", nil,
                        update_entities_ops(params))
        end

        private

        def update_entities_ops(params)
          ops = params.each_with_object([]) do |(k, v), memo|
            case k
            when :name
              memo << patch_replace('entities', k, v)
            when :add_contact
              memo << patch_add('entities', 'contacts', v)
            when :remove_contact
              memo << patch_remove('entities', 'contacts', v)
            when :add_tag
              memo << patch_add('entities', 'tags', v)
            when :remove_tag
              memo << patch_remove('entities', 'tags', v)
           end
          end
          raise "'update_entities' did not find any valid update " \
                'fields' if ops.empty?
          ops
        end
      end
    end
  end
end
