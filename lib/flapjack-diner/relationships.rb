require 'flapjack-diner/query'

module Flapjack
  module Diner
    module Relationships

      # FIXME include option for GET should check config settings for includable

      def self.included(base)
        # base.extend ClassMethods
        base.class_eval do

          ::Flapjack::Diner::Configuration::RESOURCES.each_pair do |resource, config|
            mappings = config[:relationships]
            next if mappings.nil?

            res = config[:resource]
            resource_id_validator = :uuid

            # # NB: no non-GET singular link methods, so commented out for now
            # mappings.select {|n, a| a[:post] && a[:link] && :singular.eql?(a[:number]) }.each do |linked, assoc|
            #   linked_id_validator  = :singular_link_uuid

            #   define_singleton_method("create_#{res}_link_#{linked}") do |resource_id, linked_id|
            #     validations_proc = proc do
            #       Flapjack::Diner::Query.validate_params(:resource_id => resource_id, :linked_id => linked_id) do
            #         validate :query => :resource_id, :as => resource_id_validator
            #         validate :query => :linked_id, :as => linked_id_validator
            #       end
            #     end

            #     resp = Flapjack::Diner::Request.new(
            #       linked, "/#{resource}/#{resource_id}/relationships/#{linked}",
            #       :ids => linked_id, :validations_proc => validations_proc
            #     ).post_links
            #     @response = Flapjack::Diner::Response.new(resp)
            #     @response.process
            #     @response.output
            #   end
            # end

            mappings.select {|n, a| a[:post] && a[:link] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
              type = ::Flapjack::Diner::Configuration::RESOURCES[linked][:resource]
              linked_ids_validator = :multiple_link_uuid

              define_singleton_method("create_#{res}_link_#{linked}") do |resource_id, *linked_ids|
                validations_proc = proc do
                  Flapjack::Diner::Query.validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                    validate :query => :resource_id, :as => resource_id_validator
                    validate :query => :linked_ids, :as => linked_ids_validator
                  end
                end

                resp = Flapjack::Diner::Request.new(
                  type, "/#{resource}/#{resource_id}/relationships/#{linked}",
                  :ids => linked_ids, :validations_proc => validations_proc
                ).post_links
                @response = Flapjack::Diner::Response.new(resp)
                @response.process
                @response.output
              end
            end

            mappings.select {|n, a| a[:get] && a[:link] }.each do |linked, assoc|
              define_singleton_method("#{res}_link_#{linked}") do |resource_id, opts = {}|
                validations_proc = proc do |data|
                  Flapjack::Diner::Query.validate_params(:resource_id => resource_id) do
                    validate :query => :resource_id, :as => resource_id_validator
                  end

                  Flapjack::Diner::Query.validate_params(opts) do
                    validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
                    validate :query => :filter, :as => :hash
                    validate :query => [:page, :per_page], :as => :positive_integer
                  end
                end

                resp = Flapjack::Diner::Request.new(
                  linked, "/#{resource}/#{resource_id}/#{linked}", :data => [opts],
                  :assoc => linked, :validations_proc => validations_proc
                ).get
                @response = Flapjack::Diner::Response.new(resp)
                @response.process
                @response.output
              end
            end

            # # NB: no non-GET singular link methods, so commented out for now
            # mappings.select {|n, a| a[:patch] && a[:link] && :singular.eql?(a[:number]) }.each do |linked, assoc|
            #   linked_id_validator = :singular_link_uuid

            #   define_singleton_method("update_#{res}_link_#{linked}") do |resource_id, linked_id|
            #     validations_proc = proc do
            #       Flapjack::Diner::Query.validate_params(:resource_id => resource_id, :linked_id => linked_id) do
            #         validate :query => :resource_id, :as => resource_id_validator
            #         validate :query => :linked_id, :as => linked_id_validator
            #       end
            #     end

            #     resp = Flapjack::Diner::Request.new(
            #       linked, "/#{resource}/#{resource_id}/relationships/#{linked}",
            #       :ids => linked_id, :validations_proc => validation_proc, :single => true
            #     ).patch_links
            #     @response = Flapjack::Diner::Response.new(resp)
            #     @response.process
            #     @response.output
            #   end
            # end

            mappings.select {|n, a| a[:patch] && a[:link] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
              type = ::Flapjack::Diner::Configuration::RESOURCES[linked][:resource]
              linked_ids_validator = :multiple_link_uuid

              define_singleton_method("update_#{res}_link_#{linked}") do |resource_id, *linked_ids|
                validations_proc = proc do
                  Flapjack::Diner::Query.validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                    validate :query => :resource_id, :as => resource_id_validator
                    validate :query => :linked_id, :as => linked_ids_validator
                  end
                end

                resp = Flapjack::Diner::Request.new(
                  type, "/#{resource}/#{resource_id}/relationships/#{linked}",
                  :ids => linked_ids, :validations_proc => validations_proc
                ).patch_links
                @response = Flapjack::Diner::Response.new(resp)
                @response.process
                @response.output
              end
            end

            # # NB: no non-GET singular link methods, so commented out for now
            # mappings.select {|n, a| a[:delete] && a[:link] && :singular.eql?(a[:number]) }.each do |linked, assoc|
            #   linked_id_validator  = :singular_link_uuid

            #   define_singleton_method("delete_#{res}_link_#{linked}") do |resource_id, linked_id|
            #     validations_proc = proc do
            #       Flapjack::Diner::Query.validate_params(:resource_id => resource_id, :linked_id => linked_id) do
            #         validate :query => :resource_id, :as => resource_id_validator
            #         validate :query => :linked_id, :as => linked_id_validator
            #       end
            #     end

            #    resp = Flapjack::Diner::Request.new(
            #       linked, "/#{resource}/#{resource_id}/relationships/#{linked}",
            #       :ids => linked_ids :validations_proc => validations_proc
            #     ).delete_links
            #     @response = Flapjack::Diner::Response.new(resp)
            #     @response.process
            #     @response.output
            #   end
            # end

            mappings.select {|n, a| a[:delete] && a[:link] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
              type = ::Flapjack::Diner::Configuration::RESOURCES[linked][:resource]
              linked_ids_validator = :uuid_or_array_of_uuids

              define_singleton_method("delete_#{res}_link_#{linked}") do |resource_id, *linked_ids|
                validations_proc = proc do
                  Flapjack::Diner::Query.validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                    validate :query => :resource_id, :as => resource_id_validator
                    validate :query => :linked_ids, :as => linked_ids_validator
                  end
                end

                resp = Flapjack::Diner::Request.new(
                  type, "/#{resource}/#{resource_id}/relationships/#{linked}",
                  :ids => linked_ids, :validations_proc => validations_proc
                ).delete_links
                @response = Flapjack::Diner::Response.new(resp)
                @response.process
                @response.output
              end
            end
          end
        end
      end
    end
  end
end
