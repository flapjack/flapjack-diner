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
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :id, :as => :uuid
            validate :query => :name, :as => [:required, :string]
            validate :query => :enabled, :as => :boolean
            validate :query => [:scheduled_maintenances,
              :unscheduled_maintenances], :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          perform_post(:checks, '/checks', data)
        end

        def checks(*args)
          ids, data = unwrap_uuids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
            validate :query => :filter, :as => :hash
            validate :query => [:page, :per_page], :as => :positive_integer
          end
          perform_get('/checks', ids, data)
        end

        def checks_matching(name_re)
          raise "FIXME"
          # raise "Must be a regexp: #{name_re.inspect}" unless
          #   name_re.is_a?(Regexp)
          # checks.reject {|e| name_re.match(e[:name]).nil? }
        end

        def update_checks(*args)
          data = unwrap_data(*args)
          validate_params(data) do
            validate :query => :name,                  :as => :string
            validate :query => :enabled,               :as => :boolean
            validate :query => [:scheduled_maintenances,
              :unscheduled_maintenances], :as => :multiple_link_uuid
            validate :query => :tags, :as => :multiple_link
          end
          perform_patch(:checks, "/checks", data)
        end

        def delete_checks(*ids)
          raise "'delete_checks' requires at least one check id " \
                'parameter' if ids.nil? || ids.empty?
          perform_delete(:checks, '/checks', *ids)
        end
      end
    end
  end
end
