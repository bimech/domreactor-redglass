module DomReactorRedGlass
  class Config
    #DOMREACTOR_INIT_CHAIN_REACTION_URL = 'http://domreactor.com'
    DOMREACTOR_INIT_CHAIN_REACTION_URL = 'http://localhost:3000'

    class << self
      def url
        @url || DOMREACTOR_INIT_CHAIN_REACTION_URL
      end

      def url=(url)
        @url = url
      end

      def auth_token
        @auth_token
      end

      def auth_token=(auth_token)
        @auth_token = auth_token
      end
    end
  end
end
