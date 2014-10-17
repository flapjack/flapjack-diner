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
          ids, data = unwrap_create_ids_and_data(*args)
          data.each do |d|
            validate_params(d) do
              validate :query => :entity_id, :as => [:required, :string]
              validate :query => :name,      :as => [:required, :string]
              validate :query => :tags,      :as => :array_of_strings
            end
          end
          perform_post('/checks', nil, :checks => data)
        end

        def checks(*ids)
          perform_get('checks', '/checks', ids)
        end

        def update_checks(*args)
          ids, params, data = unwrap_ids_params_and_data(*args)
          raise "'update_checks' requires at least one check id parameter" if ids.nil? || ids.empty?
          validate_params(params) do
            validate :query => :enabled, :as => :boolean
            validate :query => :tags,    :as => :array_of_strings
          end
          ops = params.inject([]) do |memo, (k,v)|
            case k
            when :enabled
              memo << {:op    => 'replace',
                       :path  => "/checks/0/#{k.to_s}",
                       :value => v}
            when :add_tag
              memo << {:op    => 'add',
                       :path  => '/checks/0/links/tags/-',
                       :value => v}
            when :remove_tag
              memo << {:op    => 'remove',
                       :path  => "/checks/0/links/tags/#{v}"}
            end
            memo
          end
          raise "'update_checks' did not find any valid update fields" if ops.empty?
          perform_patch("/checks/#{escaped_ids(ids)}", nil, ops)
        end

      end

    end
  end
end
