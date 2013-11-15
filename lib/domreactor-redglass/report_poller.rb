require 'timeout'
require 'rest_client'

class ReportPoller
  attr_reader :time_limit

  def initialize(chain_reaction, opts={})
    @chain_reaction = chain_reaction
    @time_limit = opts[:time_limit] || 60
  end

  def params
    @params ||= build_params(@chain_reaction)
  end

  def poll_completion
    Timeout::timeout(@time_limit) {
      percent_complete = @chain_reaction.info[:percent_complete]
      until percent_complete == 100
        percent_complete = fetch_percent_complete
        sleep 1 unless percent_complete == 100
      end
      percent_complete
    }
  end

  def report
    fetch_report
  end

  private

  def build_params(chain_reaction)
    {
        auth_token: chain_reaction.auth_token,
        chain_reaction_id: chain_reaction.id,
        content_type: 'application/json',
        accept: :json
    }
  end

  def fetch_percent_complete
    fetch_chain_reaction[:percent_complete]
  end

  def fetch_chain_reaction
    response = RestClient.get(@chain_reaction.chain_reaction_url, { params: params })
    JSON.parse(response, symbolize_names: true)[:chain_reaction]
  end

  def fetch_report
    response = RestClient.get("#{@chain_reaction.chain_reaction_url}/reports", { params: params })
    JSON.parse(response, symbolize_names: true)[:reports].first
  end
end