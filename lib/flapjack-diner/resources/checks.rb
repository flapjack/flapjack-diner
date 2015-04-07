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
            validate :query => :id, :as => :string
            validate :query => :name,    :as => [:required, :string]
            validate :query => :enabled, :as => :boolean
          end
          perform_post('check', '/checks', data)
        end

        def checks(*args)
          ids, data = unwrap_ids(*args), unwrap_data(*args)
          validate_params(data) do
            validate :query => :filter,  :as => :hash
            validate :query => :include, :as => :string_or_array_of_strings
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
          end
          perform_patch('check', "/checks", data)
        end

        # TODO should allow DELETE when API does
      end
    end
  end
end
