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
                 :unscheduled_maintenances => 'unscheduled_maintenance'}

        RESOURCE_ASSOCIATIONS = {
          :acknowledgements => {
            :post => [:check, :tag]
          },
          :checks => {
            :post => [:tags],
            :get => [:alerting_media, :contacts, :current_state,
              :latest_notifications, :scheduled_maintenances, :states, :tags,
              :unscheduled_maintenances],
            :patch => [:tags]
          },
          :contacts => {
            :post => [:media, :rules],
            :get => [:checks, :media, :rules],
            :patch => [:media, :rules]
          },
          :media => {
            :post => [:contact, :rules],
            :get => [:alerting_checks, :contact, :rules],
            :patch => [:rules]
          },
          :rules => {
            :post => [:contact, :media, :tags],
            :get => [:contact, :media, :tags],
            :patch => [:media, :tags]
          },
          :scheduled_maintenances => {
            :post => [:check],
            :get => [:check]
          },
          :states => {
            :get => [:check]
          },
          :tags => {
           :post => [:checks, :rules],
           :get => [:checks, :rules],
           :patch => [:checks, :rules]
          },
          :test_notifications => {
            :post => [:check, :tag]
          },
          :unscheduled_maintenances => {
            :get => [:check]
          }
        }

        # extracted from flapjack data models' "jsonapi_associations" class method
        ASSOCIATIONS = {
          :acknowledgements => {
            :check => {
              :post => true,
              :number => :singular, :link => false, :include => false
            },
            :tag => {
              :post => true,
              :number => :singular, :link => false, :include => false
            }
          },
          :checks => {
            :alerting_media => {
              :get => true,
              :number => :multiple, :link => true, :include => true
            },
            :contacts => {
              :get => true,
              :number => :multiple, :link => true, :include => true
            },
            :current_scheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :include => true
            },
            :current_state => {
              :get => true,
              :number => :singular, :link => true, :include => true
            },
            :current_unscheduled_maintenance => {
              :get => true,
              :number => :singular, :link => true, :include => true
            },
            :latest_notifications => {
              :get => true,
              :number => :multiple, :link => true, :include => true
            },
            :scheduled_maintenances => {
              :post => true, :get => true,
              :number => :multiple, :link => true, :include => false
            },
            :states => {
              :get => true,
              :number => :multiple, :link => true, :include => false
            },
            :tags => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :include => true
            },
            :unscheduled_maintenances => {
              :get => true,
              :number => :multiple, :link => true, :include => false
            }
          },
          :contacts => {
            :checks => {
              :get => true,
              :number => :multiple, :link => true, :include => true
            },
            :media => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :include => true
            },
            :rules => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :include => true
            }
          },
          :media => {
            :alerting_checks => {
              :get => true,
              :number => :multiple, :link => true, :include => true
            },
            :contact => {
              :get => true,
              :number => :singular, :link => true, :include => true
            },
            :rules => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :include => true
            }
          },
          :rules => {
            :contact => {
              :get => true,
              :number => :singular, :link => true, :include => true
            },
            :media => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :include => true
            },
            :tags => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :include => true
            }
          },
          :scheduled_maintenances => {
            :check => {
              :post => true, :get => true,
              :number => :singular, :link => true, :include => true
            }
          },
          :states => {
            :check => {
              :get => true,
              :number => :singular, :link => true, :include => true
            }
          },
          :tags => {
            :checks => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :include => true
            },
            :rules => {
              :post => true, :get => true, :patch => true, :delete => true,
              :number => :multiple, :link => true, :include => true
            }
          },
          :test_notifications => {
            :check => {
              :post => true,
              :number => :singular, :link => false, :include => false
            },
            :tag => {
              :post => true,
              :number => :singular, :link => false, :include => false
            }
          },
          :unscheduled_maintenances => {
            :check => {
              :get => true,
              :number => :singular, :link => true, :include => true
            }
          }
        }

        ASSOCIATIONS.each_pair do |resource, mappings|
          resource_id_validator = :tags.eql?(resource) ? :string : :uuid

          mappings.select {|n, a| a[:post] }.each do |linked, assoc|

            linked_id_validator  = :tags.eql?(linked) ? :string : :uuid

            define_method("create_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_post_links(linked,
                "/#{resource}/#{resource_id}/relationships/#{linked}", linked_id)
            end
          end

          mappings.select {|n, a| a[:get] }.each do |linked, assoc|
            define_method("#{resource}_link_#{linked}") do |resource_id, opts = {}|
              validate_params(:resource_id => resource_id) do
                validate :query => :resource_id, :as => resource_id_validator
              end
              validate_params(opts) do
                validate :query => [:fields, :sort, :include], :as => :string_or_array_of_strings
                validate :query => :filter, :as => :hash
                validate :query => [:page, :per_page], :as => :positive_integer
              end
              perform_get("/#{resource}/#{resource_id}/#{linked}", [], opts)
            end
          end

          mappings.select {|n, a| a[:patch] && :singular.eql?(a[:number]) }.each do |linked, assoc|
            linked_id_validator  = :tags.eql?(linked) ? :string : :uuid

            define_method("update_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_patch_links(linked,
                "/#{resource}/#{resource_id}/relationships/#{linked}", true, linked_id)
            end
          end

          mappings.select {|n, a| a[:delete] && :singular.eql?(a[:number]) }.each do |linked, assoc|
            linked_id_validator  = :tags.eql?(linked) ? :string : :uuid

            define_method("delete_#{resource}_link_#{linked}") do |resource_id, linked_id|
              validate_params(:resource_id => resource_id, :linked_id => linked_id) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_id_validator
              end
              perform_delete_links(linked,
                "/#{resource}/#{resource_id}/relationships/#{linked}", linked_id)
            end
          end

          mappings.select {|n, a| a[:post] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
            type = TYPES[linked] || linked
            linked_ids_validator = :tags.eql?(linked) ? :string_or_array_of_strings : :uuid_or_array_of_uuids

            define_method("create_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              linked_ids = linked_ids.first if linked_ids.size == 1
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_ids, :as => linked_ids_validator
              end
              perform_post_links(type,
                "/#{resource}/#{resource_id}/relationships/#{linked}", *linked_ids)
            end
          end

          mappings.select {|n, a| a[:patch] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
            type = TYPES[linked] || linked
            linked_ids_validator = :tags.eql?(linked) ? :string_or_array_of_strings : :uuid_or_array_of_uuids

            define_method("update_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
              validate_params(:resource_id => resource_id, :linked_ids => linked_ids) do
                validate :query => :resource_id, :as => resource_id_validator
                validate :query => :linked_id, :as => linked_ids_validator
              end
              perform_patch_links(type,
                "/#{resource}/#{resource_id}/relationships/#{linked}", false, *linked_ids)
            end
          end

          mappings.select {|n, a| a[:delete] && :multiple.eql?(a[:number]) }.each do |linked, assoc|
            type = TYPES[linked] || linked
            linked_ids_validator = :tags.eql?(linked) ? :string_or_array_of_strings : :uuid_or_array_of_uuids

            define_method("delete_#{resource}_link_#{linked}") do |resource_id, *linked_ids|
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
