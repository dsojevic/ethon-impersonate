# frozen_string_literal: true
module EthonImpersonate
  module Errors

    # Raises when multi_add_handle failed.
    class MultiAdd < EthonImpersonateError
      def initialize(code, easy)
        super("An error occured adding the easy handle: #{easy} to the multi: #{code}")
      end
    end
  end
end
