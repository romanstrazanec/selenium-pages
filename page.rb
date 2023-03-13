# frozen_string_literal: true

class Page
  attr_accessor :driver

  def initialize(*, driver: nil, **)
    unless defined? @@driver
      options = Selenium::WebDriver::Options.chrome
      options.add_preference 'profile.default_content_setting_values.notifications', 2
      @@driver = Selenium::WebDriver.for :chrome, options: options
    end

    @driver = driver ? driver : @@driver
  end

  def find_element(*, attr: nil, value: nil, text: nil, timeout: 5, try: true, **options)
    block = -> do
      return @driver.find_element xpath: "//*[@#{attr}='#{value}']" if attr && value
      return @driver.find_element xpath: "//*[contains(text(), \"#{text || value}\")]" if text || value

      @driver.find_element **options
    end

    begin
      sleep until block.call.present? unless timeout
      Selenium::WebDriver::Wait.new(timeout: timeout).until { block.call } if timeout > 0
      block.call
    rescue => e
      raise e unless try
    end
  end

  def find_elements(*, attr: nil, value: nil, text: nil, timeout: 5, try: true, **options)
    block = -> do
      return @driver.find_elements xpath: "//*[@#{attr}='#{value}']" if attr && value
      return @driver.find_elements xpath: "//*[contains(text(), \"#{text || value}\")]" if text || value

      @driver.find_elements **options
    end

    begin
      sleep until block.call.present? unless timeout
      Selenium::WebDriver::Wait.new(timeout: timeout).until { block.call } if timeout > 0
      block.call
    rescue => e
      raise e unless try
    end
  end

  def in_a_new_tab
    window_handle = @driver.window_handle
    @driver.switch_to.new_window :tab

    yield
  ensure
    unless @driver.window_handle == window_handle
      @driver.close
      @driver.switch_to.window window_handle
    end
  end
end
