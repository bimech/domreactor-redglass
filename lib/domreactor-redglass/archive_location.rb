class ArchiveLocation
  attr_reader :location, :opts

  REQUIRED_BASELINE_BROWSER_CONFIG_KEYS = [:name, :version, :platform]

  def initialize(location, opts={})
    @location = location
    @opts = opts
  end

  def archives
    @archives ||= archive_list
  end

  def validate!
    detect_archive_location
  end

  def detect_archive_location
    unless File.directory?(location)
      raise 'A valid archive location is required.'
    end
  end

  def detect_min_archive_quota
    raise 'At least two valid page archives are required.' unless sum_archive_count(location) >= 2
  end

  def detect_baseline_browser
    unless opts[:baseline_browser] && is_valid_baseline_browser_config?(opts[:baseline_browser])
      raise 'A valid baseline_browser configuration is required.'
    end
    unless has_baseline_archive?(location, opts)
      raise 'A page archive that corresponds to the baseline browser configuration is required.'
    end
  end

  def is_valid_baseline_browser_config?(baseline_browser_config)
    baseline_browser_config.keys == REQUIRED_BASELINE_BROWSER_CONFIG_KEYS
  end


  private

  def has_baseline_archive?(archive_location, config)
    found_archive = false
    Dir.foreach(archive_location) do |file|
      next if file == '.' or file == '..'
      path = "#{archive_location}/#{file}"
      if Archive.is_valid_page_archive?(path)
        if Archive.new(path).browser == config[:baseline_browser]
          found_archive = true
          break
        end
      end
    end
    found_archive
  end

  def sum_archive_count(archive_location)
    archive_count = 0
    Dir.foreach(archive_location) do |file|
      next if file == '.' or file == '..'
      archive_count += 1 if Archive.is_valid_page_archive?("#{archive_location}/#{file}")
    end
    archive_count
  end

  def archive_list
    list = []
    Dir.foreach(location) do |file|
      next if file == '.' or file == '..'
      path = "#{location}/#{file}"
      if Archive.is_valid_page_archive? path
        list << file
      end
    end
    list
  end
end
