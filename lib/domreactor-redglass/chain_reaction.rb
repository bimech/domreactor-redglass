require 'json'
require 'rest-client'

module DomReactorRedGlass
  class ChainReaction
    attr_reader :id, :info, :page_url

    def initialize(page_url, opts)
      @page_url = page_url
      @opts = opts
      @info = info
    end

    def api_url=(api_url)
      @api_url = api_url
    end

    def api_url
      @api_url ||= DOMREACTOR_INIT_CHAIN_REACTION_URL
    end

    def resource_url
      "#{api_url}/#{id}"
    end

    def id
      id ||= info[:id]
    end

    def info
      @info ||= create_chain_reaction(@opts)
    end

    def post_archives(archive_location)
      dom_gun_reaction = create_dom_gun_reaction
      Dir.foreach(archive_location) do |file|
        next if file == '.' or file == '..'
        path = "#{archive_location}/#{file}"
        if is_valid_page_archive? path
          payload = create_payload(path)
          RestClient.put("#{resource_url}/dom_gun_reactions/#{dom_gun_reaction[:id]}", payload, content_type: 'application/json')
        end
      end
    end

    def baseline_browser
      get_web_browser_info(@opts[:baseline_browser])
    end

    private

    def get_web_browser_info(browser_info={})
      parameters = {content_type: 'application/json'}.merge({} || browser_info)
      #TODO: Handle errors.
      JSON.parse(RestClient.get("#{api_url}/api/v1/web_browsers", parameters), symbolize_names: true)[:web_browsers].first
    end

    def create_chain_reaction(opts)
      payload = {
        auth_token: api_token,
        analysis_only: true,
        threshold: opts[:threshold] || 0.04,
        baseline_browser_id: baseline_browser[:id]
      }.to_json
      response = RestClient.post(api_url, payload, content_type: 'application/json') do |response|
        unless response.code == 200 && response.body.match(/chain_reaction/)
          raise "ChainReaction initialization failed with code #{response.code} : #{response.body}"
        end
        response
      end
      JSON.parse(response, symbolize_names: true)[:chain_reaction]
    end

    def create_dom_gun_reaction
      payload = {
        chain_reaction_id: id,
        auth_token: api_token,
        page_url: page_url
      }
      JSON.parse(RestClient.post("#{resource_url}/dom_gun_reactions", payload, content_type: 'application/json'), symbolize_names: true)[:dom_gun_reaction]
    end

    def create_payload(path)
      {
        chain_reaction_id: id,
        auth_token: api_token,
        web_browser_id: get_web_browser_info(parse_json_file("#{path}/metadata.json")[:browser]),
        dom_elements: File.open("#{path}/dom.json", 'rb') {|f| f.read},
        file: File.open("#{path}/screenshot.png"),
        page_url: page_url
      }
    end
  end
end
