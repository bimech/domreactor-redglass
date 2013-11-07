require 'json'
require 'rest-client'

module DomReactorRedGlass
  class ChainReaction
    attr_reader :id, :info

    def initialize(opts)
      @opts = opts
      @info = info
    end

    def auth_token
      Config.auth_token
    end

    def resource_url
      "#{Config.url}/api/v1/chain_reactions"
    end

    def chain_reaction_url
      "#{resource_url}/#{id}"
    end

    def id
      id ||= info[:id]
    end

    def info
      @info ||= create_chain_reaction(@opts)
    end


    def post_archives(archive_location)
      archive_location.archives.each do |archive|
        payload = create_payload(archive)
        create_dom_gun_reaction(payload)
      end
      start_reaction
    end

    private

    def start_reaction
      params = {
        auth_token: auth_token,
      }
      RestClient.post("#{chain_reaction_url}/start", params, content_type: 'application/json')
    end


    def create_dom_gun_reaction(payload)
      RestClient.post("#{chain_reaction_url}/dom_gun_reactions", payload, content_type: 'application/json')
    end

    def get_web_browser_info(browser_info={})
      parameters = {auth_token: auth_token,content_type: 'application/json', accept: :json}.merge(browser_info)
      #TODO: Handle errors.
      response = RestClient.post("#{Config.url}/api/v1/web_browsers", parameters)
      JSON.parse(response, symbolize_names: true)[:web_browser]
    end

    def baseline_browser
      get_web_browser_info(@opts[:baseline_browser])
    end

    def create_chain_reaction(opts)
      payload = {
        auth_token: auth_token,
        analysis_only: true,
        displacement_threshold: opts[:threshold] || 0.04,
        baseline_browser_id: baseline_browser[:id]
      }.to_json
      response = RestClient.post(resource_url, payload, content_type: 'application/json') do |response|
        unless response.code == 200 && response.body.match(/chain_reaction/)
          raise "ChainReaction initialization failed with code #{response.code} : #{response.body}"
        end
        response
      end
      JSON.parse(response, symbolize_names: true)[:chain_reaction]
    end

    def create_payload(archive)
      {
        auth_token: auth_token,
        meta_data: archive.meta_data,
        web_browser_id: get_web_browser_info(archive.browser)[:id],
        page_url: archive.page_url,
        dom_elements: archive.dom_elements,
        page_source: archive.page_source,
        file: archive.screenshot
      }
    end
  end
end
