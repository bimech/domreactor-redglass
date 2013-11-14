class Archive
  attr_reader :path, :opts

  REQUIRED_ARCHIVE_FILES = %w(dom.json metadata.json screenshot.png source.html)

  def initialize(path, opts={})
    @path = path
    @opts = opts
  end

  def meta_data
    @meta_data = parse_json_file("#{path}/metadata.json")
  end

  def browser
    meta_data[:browser]
  end

  def page_url
    meta_data[:page_url]
  end

  def dom_elements
    @dom_elements ||= File.open("#{path}/dom.json", 'rb') {|f| f.read}
  end

  def page_source
    @page_source ||= File.open("#{path}/source.html") {|f| f.read}
  end

  def screenshot
    @file ||= File.open("#{path}/screenshot.png")
  end

  def self.is_valid_page_archive?(file)
    is_valid = false
    if File.directory? file
      dir_files = Dir.entries(file).delete_if {|name| name == '.' || name == '..'}
      is_valid = dir_files.sort == REQUIRED_ARCHIVE_FILES.sort
    end
    is_valid
  end

  private

  def parse_json_file(path)
    json_str = File.open(path, 'rb') {|f| f.read}
    JSON.parse(json_str, symbolize_names: true)
  end
end
