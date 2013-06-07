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
      web_browser_ids = []
      #TODO: Cache the web prowser for each archive location.
      Dir.foreach(archive_location) do |file|
        next if file == '.' or file == '..'
        path = "#{archive_location}/#{file}"
        if is_valid_page_archive? path
          web_browser_ids << get_web_browser_info(parse_json_file("#{path}/metadata.json")[:browser])[:id]
        end
      end
      update_chain_reaction(web_browser_ids: web_browser_ids)
      dom_gun_reaction = create_dom_gun_reaction
      Dir.foreach(archive_location) do |file|
        next if file == '.' or file == '..'
        path = "#{archive_location}/#{file}"
        if is_valid_page_archive? path
          payload = create_payload(path)
          RestClient.put("#{chain_reaction_url}/dom_gun_reactions/#{dom_gun_reaction[:id]}", payload, content_type: 'application/json')
        end
      end
      start_reaction(dom_gun_reaction[:id])
    end

    def start_reaction(id)
      params = {
        auth_token: auth_token,
      }
      RestClient.post("#{chain_reaction_url}/dom_gun_reactions/#{id}/start", params, content_type: 'application/json')
    end

    def baseline_browser
      get_web_browser_info(@opts[:baseline_browser])
    end

    private

    def get_web_browser_info(browser_info={})
      parameters = {auth_token: auth_token,content_type: 'application/json', accept: :json}.merge(browser_info)
      #TODO: Handle errors.
      response = RestClient.get("#{Config.url}/api/v1/web_browsers", {params: parameters})
      JSON.parse(response, symbolize_names: true)[:web_browsers].first
    end

    def update_chain_reaction(params)
      RestClient.put(chain_reaction_url, params.merge(auth_token: auth_token), content_type: 'application/json')
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

    def create_dom_gun_reaction
      payload = {
        chain_reaction_id: id,
        auth_token: auth_token,
        page_url: page_url
      }
      dom_gun = RestClient.post("#{chain_reaction_url}/dom_gun_reactions", payload, content_type: 'application/json')
      JSON.parse(dom_gun, symbolize_names: true)
    end

    def create_payload(path)
      meta_data = parse_json_file("#{path}/metadata.json")
      {
        auth_token: auth_token,
        meta_data: meta_data,
        web_browser_id: get_web_browser_info(meta_data[:browser])[:id],
        dom_elements: File.open("#{path}/dom.json", 'rb') {|f| f.read},
        page_source: File.open("#{path}/source.html") {|f| f.read},
        file: File.open("#{path}/screenshot.png")
      }
    end
  end
end
