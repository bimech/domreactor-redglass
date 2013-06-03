require 'json'
require 'rest-client'
require 'domreactor-redglass/chain_reaction'
require 'domreactor-redglass/version'

module DomReactorRedGlass

  REQUIRED_ARCHIVE_FILES = %w(dom.json metadata.json screenshot.png source.html)
  REQUIRED_BASELINE_BROWSER_CONFIG_KEYS = [:name, :version, :platform]
  DOMREACTOR_INIT_CHAIN_REACTION_URL = 'http://domreactor.com/api/v1/chain_reactions'

  def create_chain_reaction(page_url, archive_location, opts)
    detect_archive_location archive_location
    detect_min_archive_quota archive_location
    detect_baseline_browser archive_location, opts
    @chain_reaction = ChainReaction.new(page_url, opts)
    @chain_reaction.post_archives(archive_location)
  end

  def api_token=(api_token)
    @api_token = api_token
  end

  def api_token
    @api_token
  end

  def detect_archive_location(archive_location)
    unless File.directory?(archive_location)
      raise 'A valid archive location is required.'
    end
  end

  def detect_min_archive_quota(archive_location)
    raise 'At least two valid page archives are required.' unless sum_archive_count(archive_location) >= 2
  end

  def sum_archive_count(archive_location)
    archive_count = 0
    Dir.foreach(archive_location) do |file|
      next if file == '.' or file == '..'
      archive_count += 1 if is_valid_page_archive? "#{archive_location}/#{file}"
    end
    archive_count
  end

  def is_valid_page_archive?(file)
    is_valid = false
    if File.directory? file
      dir_files = Dir.entries(file).delete_if {|name| name == '.' || name == '..'}
      is_valid = true if dir_files == REQUIRED_ARCHIVE_FILES
    end
    is_valid
  end

  def detect_baseline_browser(archive_location, config)
    unless config[:baseline_browser] && is_valid_baseline_browser_config?(config[:baseline_browser])
      raise 'A valid baseline_browser configuration is required.'
    end
    unless has_baseline_archive?(archive_location, config)
      raise 'A page archive that corresponds to the baseline browser configuration is required.'
    end
  end

  def is_valid_baseline_browser_config?(baseline_browser_config)
    baseline_browser_config.keys == REQUIRED_BASELINE_BROWSER_CONFIG_KEYS
  end

  def has_baseline_archive?(archive_location, config)
    found_archive = false
    Dir.foreach(archive_location) do |file|
      next if file == '.' or file == '..'
      path = "#{archive_location}/#{file}"
      if is_valid_page_archive? path
        if parse_json_file("#{path}/metadata.json")[:browser] == config[:baseline_browser]
          found_archive = true
          break
        end
      end
    end
    found_archive
  end

  def archive_metadata(archive_location)
    metadata = []
    Dir.foreach(archive_location) do |file|
      next if file == '.' or file == '..'
      path = "#{archive_location}/#{file}"
      if is_valid_page_archive? path
        metadata << parse_json_file("#{path}/metadata.json")
      end
    end
    metadata
  end

  def parse_json_file(path)
    json_str = File.open(path, 'rb') {|f| f.read}
    JSON.parse(json_str, symbolize_names: true)
  end
end
