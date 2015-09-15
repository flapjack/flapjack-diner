require 'flapjack-diner/configuration'

module Flapjack
  module Diner
    module Resources
      def self.included(base)
        # base.extend ClassMethods
        base.class_eval do
          Flapjack::Diner::Configuration::RESOURCES.each_pair do |name, config|
            requests = config[:requests]
            next if requests.nil?

            if requests.key?(:post)
              define_singleton_method("create_#{name}".to_sym) do |*data|
                resp = Flapjack::Diner::Request.new(
                  name, "/#{name}", :data => data,
                  :validations => requests[:post]
                ).post
                @response = Flapjack::Diner::Response.new(resp)
                @response.process
                @response.output
              end
            end

            if requests.key?(:get)
              define_singleton_method(name) do |*data|
                resp = Flapjack::Diner::Request.new(
                  name, "/#{name}", :data => data,
                  :validations => requests[:get]
                ).get
                @response = Flapjack::Diner::Response.new(resp)
                @response.process
                @response.output
              end
            end

            if requests.key?(:patch)
              define_singleton_method("update_#{name}".to_sym) do |*data|
                resp = Flapjack::Diner::Request.new(
                  name, "/#{name}", :data => data,
                  :validations => requests[:patch]
                ).patch
                @response = Flapjack::Diner::Response.new(resp)
                @response.process
                @response.output
              end
            end

            next unless requests.key?(:delete)
            define_singleton_method("delete_#{name}".to_sym) do |*uuids|
              raise "'#{method_name}' requires at least one #{resource} UUID " \
                    'parameter' if uuids.nil? || uuids.empty?
              resp = Flapjack::Diner::Request.new(name, "/#{name}",
                :ids => uuids).delete
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
