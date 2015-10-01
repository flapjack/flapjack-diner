require 'flapjack-diner/utility'

module Flapjack
  module Diner
    class Response
      SUCCESS_STATUS_CODES = [200, 201, 204]

      attr_reader :output, :context, :error

      def initialize(resp, opts = {})
        @response = resp
        @output = nil
        @context = nil
        @error = nil
        @return_keys_as_strings = Flapjack::Diner.return_keys_as_strings
      end

      def process
        if 204.eql?(@response.code)
          @output = true
          @context = nil
          @error = nil
          return
        end
        if @response.respond_to?(:parsed_response)
          parsed = @response.parsed_response
        end
        strify = @return_keys_as_strings.is_a?(TrueClass)
        if [200, 201].include?(@response.code)
          @output = handle_data(parsed, strify)
          return
        end
        @error = handle_errors(parsed, strify)
      end

      private

      def flatten_jsonapi_data(data)
        ret = nil
        case data
        when Array
          ret = data.inject([]) do |memo, d|
            attrs = d['attributes'] || {}
            d.each_pair do |k, v|
              next if 'attributes'.eql?(k)
              attrs.update(k => v)
            end
            memo += [attrs]
            memo
          end
        when Hash
          ret = data['attributes'] || {}
          data.each_pair do |k, v|
            next if 'attributes'.eql?(k)
            ret.update(k => v)
          end
        else
          ret = data
        end
        ret
      end

      def handle_data(parsed, strify)
        return parsed if parsed.nil? || !parsed.is_a?(Hash) ||
                         !parsed.key?('data')
        @context = {}
        c_incl_key = strify ? 'included' : :included
        if parsed.key?('included')
          incl = flatten_jsonapi_data(parsed['included'])
          @context[c_incl_key] = incl.each_with_object({}) do |i, memo|
            memo[i['type']] ||= {}
            memo[i['type']][i['id']] = strify ? i : Flapjack::Diner::Utility.symbolize(i)
          end
        end
        (%w(relationships meta) & parsed.keys).each do |k|
          c = parsed[k]
          @context[strify ? k : k.to_sym] = (strify ? c : Flapjack::Diner::Utility.symbolize(c))
        end
        ret = flatten_jsonapi_data(parsed['data'])
        strify ? ret : Flapjack::Diner::Utility.symbolize(ret)
      end

      def handle_errors(parsed, strify)
        return parsed if parsed.nil? || !parsed.is_a?(Hash) ||
                         !parsed.key?('errors')
        errs = parsed['errors']
        strify ? errs : Flapjack::Diner::Utility.symbolize(errs)
      end
    end
  end
end
