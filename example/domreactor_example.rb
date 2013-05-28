require 'selenium-webdriver'
require 'red-glass'
require 'domreactor-redglass'
include DomReactorRedGlass

# Configurations
browsers = [:firefox, :chrome]
archive_location = '/Users/you/Desktop/red_glass_snapshots'
test_id = 1
api_token = '12345'
config = {
    baseline_browser: {name: 'firefox', version: '20.0', platform: 'darwin'},
    threshold: 0.02
}

# Take a RedGlass snapshot in each browser.
browsers.each do |browser|
  listener = RedGlassListener.new
  driver = Selenium::WebDriver.for browser, :listener => listener
  red_glass = RedGlass.new driver, {listener: listener, archive_location: archive_location, test_id: test_id}
  driver.navigate.to 'http://google.com'
  red_glass.take_snapshot
  driver.quit
end

# Send the page archives to DomReactor.
DomReactorRedGlass.create_chain_reaction(api_token, "#{archive_location}/#{test_id}", config)