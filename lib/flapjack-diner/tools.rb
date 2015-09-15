module Flapjack
  module Diner
    module Tools
      module ClassMethods
        def included
          return if context.nil?
          context[return_keys_as_strings ? 'included' : :included]
        end

        def related(record, rel)
          incl = included
          return if incl.nil?

          type = record[return_keys_as_strings ? 'type' : :type]
          return if type.nil?

          res = Flapjack::Diner::Configuration::RESOURCES.values.detect do |r|
            type.eql?(r[:resource])
          end
          return if res.nil? || res[:relationships].nil?

          rel_cfg = res[:relationships][rel.to_sym]
          return if rel_cfg.nil?

          case rel_cfg[:number]
          when :singular
            singularly_related(record, rel, type, incl)
          else
            multiply_related(record, rel, type, incl)
          end
        end

        private

        def singularly_related(record, rel, type, incl)
          relat, data, id, rel, type_a = related_accessors(rel, type)
          return if record[relat].nil? ||
                    record[relat][rel].nil? ||
                    record[relat][rel][data].nil?

          id = record[relat][rel][data][id]
          return if id.nil?
          incl.detect {|i| type.eql?(i[type_a]) && id.eql?(i[id]) }
        end

        def multiply_related(record, rel, type, incl)
          relat, data, id, rel, type_a = related_accessors(rel, type)
          return [] if record[relat].nil? ||
                       record[relat][rel].nil? ||
                       record[relat][rel][data].nil? ||
                       record[relat][rel][data].empty?

          ids = record[relat][rel][data].map {|m| m[id] }
          return [] if ids.empty?
          incl.select {|i| type.eql?(i[type_a]) && ids.include?(i[id]) }
        end

        def related_accessors(*args)
          acc = [:relationships, :data, :id]
          return (acc + args).map(&:to_s) if return_keys_as_strings
          (acc + args.map(&:to_sym))
        end
      end

      def self.included(base)
        base.extend ClassMethods
        # base.class_eval do
        # end
      end
    end
  end
end
