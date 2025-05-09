# frozen_string_literal: true
module EthonImpersonate
  class Easy
    class Mirror
      attr_reader :options
      alias_method :to_hash, :options

      INFORMATIONS_TO_MIRROR = Informations::AVAILABLE_INFORMATIONS.keys +
          [:return_code, :response_headers, :response_body, :debug_info]

      INFORMATIONS_TO_LOG = [:effective_url, :response_code, :return_code, :total_time]

      def self.from_easy(easy)
        options = {}
        INFORMATIONS_TO_MIRROR.each do |info|
          options[info] = easy.send(info)
        end
        new(options)
      end

      def initialize(options = {})
        @options = options
      end

      def log_informations
        Hash[*INFORMATIONS_TO_LOG.map do |info|
          [info, options[info]]
        end.flatten]
      end

      INFORMATIONS_TO_MIRROR.each do |info|
        define_method(info) do
          options[info]
        end
      end
    end
  end
end
