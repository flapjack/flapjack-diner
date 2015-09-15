module Flapjack
  module Diner
    module Utility
      def self.symbolize(obj)
        case obj
        when Hash
          obj.each_with_object({}) {|(k, v), a| a[k.to_sym] = symbolize(v) }
        when Array
          obj.each_with_object([]) {|e, a| a << symbolize(e) }
        else
          obj
        end
      end
    end
  end
end