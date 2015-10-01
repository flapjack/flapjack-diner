module Flapjack
  module Diner
    module Tools
      module ClassMethods
        def included_data
          return if context.nil?
          context[return_keys_as_strings ? 'included' : :included]
        end

        def related(record, rel, incl = included_data)
          return if incl.nil?

          type = record[return_keys_as_strings ? 'type' : :type]
          return if type.nil?

          res = Flapjack::Diner::Configuration::RESOURCES.values.detect do |r|
            type.eql?(r[:resource])
          end
          return if res.nil? || res[:relationships].nil?

          rel_cfg = res[:relationships][rel.to_sym]
          return if rel_cfg.nil?

          rel_type = rel_cfg[:resource]
          has_data = incl.key?(rel_type)
          case rel_cfg[:number]
          when :singular
            has_data ? singularly_related(record, rel, rel_type, incl) : nil
          else
            has_data ? multiply_related(record, rel, rel_type, incl) : []
          end
        end

        private

        def singularly_related(record, rel, type, incl)
          relat, data, id_a, rel = related_accessors(rel)
          return if record[relat].nil? ||
                    record[relat][rel].nil? ||
                    record[relat][rel][data].nil?

          id = record[relat][rel][data][id_a]
          return if id.nil? || !incl.key?(type)
          incl[type][id]
        end

        def multiply_related(record, rel, type, incl)
          relat, data, id_a, rel = related_accessors(rel)
          return [] if record[relat].nil? ||
                       record[relat][rel].nil? ||
                       record[relat][rel][data].nil? ||
                       record[relat][rel][data].empty?

          ids = record[relat][rel][data].map {|m| m[id_a] }
          return [] if ids.empty? || !incl.key?(type)
          incl[type].values_at(*ids)
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
