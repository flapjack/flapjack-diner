require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Rules

        def create_rules(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :uuid
            validate :query => :name, :as => :string
            validate :query => :blackhole, :as => :boolean
            validate :query => :strategy, :as => :string
            validate :query => :conditions_list, :as => :string
            validate :query => :time_restriction_ical, :as => :string
            validate :query => :contact, :as => [:singular_link_uuid, :required]
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          _rules_validate_association(data)
          perform_post(:rules, '/rules', data)
        end

        def rules(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter,  :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/rules', ids, data)
        end

        def update_rules(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => [:uuid, :required]
            validate :query => :name, :as => :string
            validate :query => :blackhole, :as => :boolean
            validate :query => :strategy, :as => :string
            validate :query => :conditions_list, :as => :string
            validate :query => :time_restriction_ical, :as => :string
            validate :query => :media, :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          perform_patch(:rules, "/rules", data)
        end

        def delete_rules(*ids)
          raise "'delete_rules' requires at least one rule id parameter" if ids.nil? || ids.empty?
          perform_delete(:rules, '/rules', *ids)
        end

        private

        def _rules_validate_association(data)
          case data
          when Array
            data.each do |d|
              unless d.has_key?(:contact)
                raise ArgumentError.new("Contact association must be provided for all rules")
              end
            end
          when Hash
            unless data.has_key?(:contact)
              raise ArgumentError.new("Contact association must be provided for rule")
            end
          end
        end
      end
    end
  end
end
