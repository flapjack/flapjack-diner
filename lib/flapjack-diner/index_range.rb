# fairly similar to the object in Zermelo that this ends up being translated to
# by Flapjack's JSONAPI, although slightly limited in scope

module Flapjack
  module Diner
    class IndexRange
      attr_reader :start, :finish

      def initialize(start, finish, opts = {})
        value_types = [Float, Date, Time, DateTime]
        [start, finish].each do |v|
          raise "Values must be #{value_types.join('/')}" unless v.nil? || value_types.any? {|vt| v.is_a?(vt)}
        end
        if !start.nil? && !finish.nil? && (start > finish)
          raise "Start of range must be <= finish"
        end
        if start.nil? && finish.nil?
          raise "Range must be bounded on at least one side"
        end
        @start  = start
        @finish = finish
      end

      # NB
      def to_s
        start_s = case @start
        when Date, Time, DateTime
          @start.iso8601
        else
          @start.to_s
        end
        finish_s = case @finish
        when Date, Time, DateTime
          @finish.iso8601
        else
          @finish.to_s
        end
        "#{start_s}..#{finish_s}"
      end
    end
  end
end