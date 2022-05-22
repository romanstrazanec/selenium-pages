require 'logger'

class Page
  attr_reader :logger
  attr_accessor :driver

  def initialize(*, driver: nil, logger: nil, **)
    unless driver || defined? @@driver
      options = Selenium::WebDriver::Options.chrome
      options.add_preference 'profile.default_content_setting_values.notifications', 2
      @@driver = Selenium::WebDriver.for :chrome, options: options
    end

    unless logger || defined? @@logger
      @@logger = Logger.new(STDOUT)
    end

    @logger = logger || @@logger
    @driver = driver || @@driver
  end

  def find_element(*, attr: nil, value: nil, text: nil, timeout: 5, try: true, **options)
    logger.info "Looking for element with attr='#{attr}' and value='#{value || text}' (timeout=#{timeout}, try=#{try})"
    block = -> do
      return @driver.find_element xpath: "//*[@#{attr}='#{value}']" if attr && value
      return @driver.find_element xpath: "//*[contains(text(), \"#{text || value}\")]" if text || value

      @driver.find_element **options
    end

    begin
      unless timeout
        logger.info 'Sleeping unless found...'
        sleep until block.call.present?
      end

      if timeout > 0
        logger.info "Waiting #{timeout} seconds until found..."
        Selenium::WebDriver::Wait.new(timeout: timeout).until { block.call }
      end

      block.call
    rescue => e
      logger.warn e

      unless try
        logger.warn 'Raising an exception.'
        raise e
      end
    end
  end

  def find_elements(*, attr: nil, value: nil, text: nil, timeout: 5, try: true, **options)
    logger.info "Looking for elements with attr='#{attr}' and value='#{value || text}' (timeout=#{timeout}, try=#{try})"
    block = -> do
      return @driver.find_elements xpath: "//*[@#{attr}='#{value}']" if attr && value
      return @driver.find_elements xpath: "//*[contains(text(), \"#{text || value}\")]" if text || value

      @driver.find_elements **options
    end

    begin
      unless timeout
        logger.info 'Sleeping unless found...'
        sleep until block.call.present?
      end

      if timeout > 0
        logger.info "Waiting #{timeout} seconds until found..."
        Selenium::WebDriver::Wait.new(timeout: timeout).until { block.call }
      end

      block.call
    rescue => e
      logger.warn 'Unable to find the elements.'

      unless try
        logger.warn 'Raising an exception.'
        raise e
      end
    end
  end

  def in_a_new_tab
    window_handle = @driver.window_handle
    logger.info 'Switching to a new tab.'
    @driver.switch_to.new_window :tab

    yield
  ensure
    unless @driver.window_handle == window_handle
      @driver.close
      @driver.switch_to.window window_handle
    end
  end
end
