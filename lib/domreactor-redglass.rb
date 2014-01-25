require 'domreactor-redglass/chain_reaction'
require 'domreactor-redglass/archive'
require 'domreactor-redglass/archive_location'
require 'domreactor-redglass/config'
require 'domreactor-redglass/version'
require 'domreactor-redglass/report_poller'

module DomReactorRedGlass

  def auth_token=(auth_token)
    Config.auth_token=auth_token
  end

  def auth_token
    Config.auth_token
  end

  def create_chain_reaction(archive_location, opts)
    archive_location = ArchiveLocation.new(archive_location, opts)
    archive_location.validate!
    @chain_reaction = ChainReaction.new(opts)
    @chain_reaction.post_archives(archive_location)
  end

  def poll_report(opts={})
    poller = ReportPoller.new(@chain_reaction, opts)
    poller.poll_completion
    poller.report
  end

  def parse_json_file(path)
    json_str = File.open(path, 'rb') {|f| f.read}
    JSON.parse(json_str, symbolize_names: true)
  end
end
