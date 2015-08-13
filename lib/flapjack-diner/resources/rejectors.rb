require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Rejectors

        def create_rejectors(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :uuid
            validate :query => :name, :as => :string
            validate :query => :all, :as => :boolean
            validate :query => :conditions_list, :as => :string
            # TODO proper validation of time_restrictions field
            validate :query => :contact, :as => [:singular_link_uuid, :required]
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          _rejectors_validate_association(data)
          perform_post(:rejectors, '/rejectors', data)
        end

        def rejectors(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter,  :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/rejectors', ids, data)
        end

        def update_rejectors(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => [:uuid, :required]
            validate :query => :name, :as => :string
            validate :query => :all, :as => :boolean
            validate :query => :conditions_list, :as => :string
            # TODO proper validation of time_restrictions field
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          perform_patch(:rejectors, "/rejectors", data)
        end

        def delete_rejectors(*ids)
          raise "'delete_rejectors' requires at least one rejector id parameter" if ids.nil? || ids.empty?
          perform_delete(:rejectors, '/rejectors', *ids)
        end

        private

        def _rejectors_validate_association(data)
          case data
          when Array
            data.each do |d|
              unless d.has_key?(:contact)
                raise ArgumentError.new("Contact association must be provided for all rejectors")
              end
            end
          when Hash
            unless data.has_key?(:contact)
              raise ArgumentError.new("Contact association must be provided for rejector")
            end
          end
        end
      end
    end
  end
end
