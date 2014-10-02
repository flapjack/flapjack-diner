require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Entities

        # 4: Entities & 5: Checks
        def create_entities(*args)
          ids, params, data = unwrap_ids_and_params(*args)
          data.each do |d|
            validate_params(d) do
              validate :query => :id,   :as => [:required, :string]
              validate :query => :name, :as => :string
              validate :query => :tags, :as => :array_of_strings
            end
          end
          perform_post('/entities', nil, :entities => data)
        end

        def entities(*ids)
          perform_get('entities', '/entities', ids)
        end

        def entities_matching(name_re)
          raise "Must be a regexp: #{name_re.inspect}" unless name_re.is_a?(Regexp)
          self.entities.select {|e| name_re === e[:name] }
        end

        def update_entities(*args)
          ids, params, data = unwrap_ids_and_params(*args)
          raise "'update_entities' requires at least one entity id parameter" if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => :name, :as => :string
            validate :query => :tags, :as => :array_of_strings
          end
          ops = params.inject([]) do |memo, (k,v)|
            case k
            when :name
              memo << {:op    => 'replace',
                       :path  => "/entities/0/#{k.to_s}",
                       :value => v}
            when :add_contact
              memo << {:op    => 'add',
                       :path  => '/entities/0/links/contacts/-',
                       :value => v}
            when :remove_contact
              memo << {:op    => 'remove',
                       :path  => "/entities/0/links/contacts/#{v}"}
            when :add_tag
              memo << {:op    => 'add',
                       :path  => '/entities/0/links/tags/-',
                       :value => v}
            when :remove_tag
              memo << {:op    => 'remove',
                       :path  => "/entities/0/links/tags/#{v}"}
            end
            memo
          end
          raise "'update_entities' did not find any valid update fields" if ops.empty?
          perform_patch("/entities/#{escaped_ids(ids)}", nil, ops)
        end

      end

    end
  end
end
