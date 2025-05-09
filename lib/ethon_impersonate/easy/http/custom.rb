# frozen_string_literal: true
module EthonImpersonate
  class Easy
    module Http

      # This class knows everything about making requests for custom HTTP verbs.
      class Custom
        include EthonImpersonate::Easy::Http::Actionable
        include EthonImpersonate::Easy::Http::Postable

        def initialize(verb, url, options)
          @verb = verb
          super(url, options)
        end

        # Setup easy to make a request.
        #
        # @example Setup.
        #   custom.set_params(easy)
        #
        # @param [ Easy ] easy The easy to setup.
        def setup(easy)
          super
          easy.customrequest = @verb
        end
      end
    end
  end
end
