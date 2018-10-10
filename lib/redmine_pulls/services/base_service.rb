module RedminePulls
  module Services
    class BaseService
      attr_accessor :pull, :options

      def initialize(pull, options = {})
        @pull, @options = pull, options.dup
      end

      def execute
        raise NotImplementedError, "Subclasses must define method `execute`."
      end
    end
  end
end
