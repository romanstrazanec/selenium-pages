require 'webdrivers'

options = Selenium::WebDriver::Options.chrome
driver = Selenium::WebDriver.for :chrome, options: options

GoogleTranslate.new(driver).translate

driver.quit
