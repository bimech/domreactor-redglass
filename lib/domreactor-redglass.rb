require 'json'
require 'rest-client'
require 'zip/zip'

module DomReactorRedGlass

  REQUIRED_ARCHIVE_FILES = %w(dom.json metadata.json screenshot.png source.html)
  REQUIRED_BASELINE_BROWSER_CONFIG_KEYS = [:name, :version, :platform]
  DOMREACTOR_INIT_CHAIN_REACTION_URL = 'http://domreactor.com/api/v1/chain_reactions'

  def create_chain_reaction(api_token, archive_location, config)
    detect_archive_location archive_location
    detect_min_archive_quota archive_location
    detect_baseline_browser archive_location, config
    id = init_chain_reaction(api_token, archive_location, config)[:chain_reaction][:id]
    api_url = config[:api_url] || DOMREACTOR_INIT_CHAIN_REACTION_URL
    post_url = "#{api_url}/#{id}"
    archive_files = zip_archives archive_location
    post_archives(api_token, post_url, archive_files)
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

  def init_chain_reaction(api_token, archive_location, config)
    payload = {
        auth_token: api_token,
        analysis_only: true,
        threshold: config[:threshold] || 0.04,
        baseline_browser: config[:baseline_browser],
        archive_count: sum_archive_count(archive_location)
    }.to_json
    api_url = config[:api_url] || DOMREACTOR_INIT_CHAIN_REACTION_URL
    response = RestClient.post(api_url, payload, content_type: 'application/json') do |response|
      unless response.code == 200 && response.body.match(/chain_reaction/)
        raise "ChainReaction initialization failed with code #{response.code} : #{response.body}"
      end
      response
    end
    JSON.parse(response, symbolize_names: true)
  end

  def zip_archives(archive_location)
    zip_files = []
    Dir.foreach(archive_location) do |file|
      next if file == '.' or file == '..'
      path = "#{archive_location}/#{file}"
      if is_valid_page_archive? path
        zip_file = "#{path}.zip"
        zip_files << zip_file
        Zip::ZipFile.open(zip_file, Zip::ZipFile::CREATE) do |zipfile|
          REQUIRED_ARCHIVE_FILES.each do |filename|
            zipfile.add(filename, path + '/' + filename)
          end
        end
      end
    end
    zip_files
  end

  def post_archives(api_token, post_url, zip_files)
    zip_files.each do |file|
      payload = {
          auth_token: api_token,
          file: File.new(file, 'rb')
      }
      RestClient.put(post_url, payload)
    end
  end

  def parse_json_file(path)
    json_str = File.open(path, 'rb') {|f| f.read}
    JSON.parse(json_str, symbolize_names: true)
  end
end