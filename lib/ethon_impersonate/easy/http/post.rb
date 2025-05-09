# frozen_string_literal: true
module EthonImpersonate
  class Easy
    module Http
      # This class knows everything about making POST requests.
      class Post
        include EthonImpersonate::Easy::Http::Actionable
        include EthonImpersonate::Easy::Http::Postable

        # Setup easy to make a POST request.
        #
        # @example Setup.
        #   post.setup(easy)
        #
        # @param [ Easy ] easy The easy to setup.
        def setup(easy)
          super
          if form.empty?
            easy.postfieldsize = 0
            easy.copypostfields = ""
          end
        end
      end
    end
  end
end
