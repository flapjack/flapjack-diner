require 'httparty'
require 'json'
require 'uri'

require 'flapjack-diner/version'
require 'flapjack-diner/argument_validator'

module Flapjack
  module Diner
    module Resources
      module Relationships

        TYPES = {
                  :acknowledgements => 'acknowledgement',
                  :checks => 'check',
                  :contacts => 'contact',
                  :media => 'medium',
                  :rules => 'rule',
                  :scheduled_maintenances   => 'scheduled_maintenance',
                  :states => 'state',
                  :tags => 'tag',
                  :test_notifications => 'test_notification',
                  :unscheduled_maintenances => 'unscheduled_maintenance'
                }

        # FIXME include option for tools.rb/GET should check these config settings for includable

        # extracted from flapjack data models' "jsonapi_associations" class method
        ASSOCIATIONS = {
          :acknowledgements => {
            :check => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            },
            :tag => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            }
          },
          :checks => {
            :alerting_media => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :contacts => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :current_scheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :current_state => {
              :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :current_unscheduled_maintenance => {
              :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :latest_notifications => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :scheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            },
            :states => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            },
            :tags => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            },
            :unscheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :includable => false
            }
          },
          :contacts => {
            :checks => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :media => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :rules => {
              :get => :true,
              :number => :multiple, :link => true, :includable => true
            }
          },
          :media => {
            :alerting_checks => {
              :get => true,
              :number => :multiple, :link => true, :includable => true
            },
            :contact => {
              :post => true, :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :rules => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            }
          },
          :rules => {
            :contact => {
              :post => true, :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :media => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            },
            :tags => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            }
          },
          :scheduled_maintenances => {
            :check => {
              :post => true, :get => true,
              :number => :singular, :link => true, :includable => true
            },
            :tag => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            }
          },
          :states => {
            :check => {
              :get => true,
              :number => :singular, :link => true, :includable => true
            }
          },
          :tags => {
            :checks => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            },
            :rules => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :includable => true
            }
          },
          :test_notifications => {
            :check => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            },
            :tag => {
              :post => true,
              :number => :singular, :link => false, :includable => false
            }
          },
          :unscheduled_maintenances => {
            :check => {
              :get => true,
              :number => :singular, :link => false, :includable => true
            }
          }
        }

        ASSOCIATIONS.each_pair do |resource, mappings|
          res = TYPES[resource]
          resource_id_validator = :tags.eql?(resource) ? :string : :uuid

          # NB: no remaining non-GET singular link methods, so these are commented out for now

          # mappings.select {|n, a| a[:post] && a[:link] && :singular.eql?(a[:number]) }.each do |linked, assoc|

          #   linked_id_validator  = :tag.eql?(linked) ? :singular_link : :singular_link_uuid

          #   define_method("create_#{res}_link_#{linked}") do |resource_id, linked_id|
          #     validate_params(:resource_id => resource_id, :linked_id => linked_id) do
          #       validate :query => :resource_id, :as => resource_id_validator
          #       validate :query => :linked_id, :as => linked_id_validator
          #     end
          #     perform_post_links(linked,
          #       "/#{resource}/#{resource_id}/relationships/#{linked}", linked_id)
          #   end
          # end

          mappings.select {|n, a| a[:post] && a[:link] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
            type = TYPES[linked] || linked
            linked_ids_validator = :tags.eql?(linked) ? :multiple_link : :multiple_link_uuid

            define_method("create_#{res}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_ids, :as => linked_ids_validator
              end
              perform_post_links(type,
                "/#{resource}/#{resource_id}/relationships/#{linked}", *linked_ids)
            end
          end

          mappings.select {|n, a| a[:get] && a[:link] }.each do |linked, assoc|
            define_method("#{res}_link_#{linked}") do |resource_id, opts = {}|
              validate_params(:resource_id => resource_id) do
                validate :query => :resource_id, :as => resource_id_validator
              end
              validate_params(opts) do
                validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
                validate :query => :filter, :as => :hash
                validate :query => [:page, :per_page], :as => :positive_integer
              end
              perform_get("/#{resource}/#{resource_id}/#{linked}", [], opts, {:assoc => linked})
            end
          end

          # mappings.select {|n, a| a[:patch] && a[:link] && :singular.eql?(a[:number]) }.each do |linked, assoc|
          #   linked_id_validator  = :tag.eql?(linked) ? :singular_link : :singular_link_uuid

          #   define_method("update_#{res}_link_#{linked}") do |resource_id, linked_id|
          #     validate_params(:resource_id => resource_id, :linked_id => linked_id) do
          #       validate :query => :resource_id, :as => resource_id_validator
          #       validate :query => :linked_id, :as => linked_id_validator
          #     end
          #     perform_patch_links(linked,
          #       "/#{resource}/#{resource_id}/relationships/#{linked}", true, linked_id)
          #   end
          # end

          mappings.select {|n, a| a[:patch] && a[:link] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
            type = TYPES[linked] || linked
            linked_ids_validator = :tags.eql?(linked) ? :multiple_link : :multiple_link_uuid

            define_method("update_#{res}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_ids_validator
              end
              perform_patch_links(type,
                "/#{resource}/#{resource_id}/relationships/#{linked}", false, *linked_ids)
            end
          end

          # mappings.select {|n, a| a[:delete] && a[:link] && :singular.eql?(a[:number]) }.each do |linked, assoc|
          #   linked_id_validator  = :tag.eql?(linked) ? :singular_link : :singular_link_uuid

          #   define_method("delete_#{res}_link_#{linked}") do |resource_id, linked_id|
          #     validate_params(:resource_id => resource_id, :linked_id => linked_id) do
          #       validate :query => :resource_id, :as => resource_id_validator
          #       validate :query => :linked_id, :as => linked_id_validator
          #     end
          #     perform_delete_links(linked,
          #       "/#{resource}/#{resource_id}/relationships/#{linked}", linked_id)
          #   end
          # end

          mappings.select {|n, a| a[:delete] && a[:link] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
            type = TYPES[linked] || linked
            linked_ids_validator = :tags.eql?(linked) ? :string_or_array_of_strings : :uuid_or_array_of_uuids

            define_method("delete_#{res}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_ids, :as => linked_ids_validator
              end
              perform_delete_links(type,
                "/#{resource}/#{resource_id}/relationships/#{linked}", *linked_ids)
            end
          end
        end

      end

    end
  end
end
