class GoogleTranslate
  XPATH_PREFIX = '/html/body/c-wiz/div/div[2]/c-wiz/div[2]/c-wiz/div[1]/'.freeze
  SOURCE_XPATH = "#{XPATH_PREFIX}div[2]/div[3]/c-wiz[1]/span/span/div/textarea".freeze
  DEST_XPATH = "#{XPATH_PREFIX}div[2]/div[3]/c-wiz[2]/div[8]/div/div[1]/span[1]/span/span".freeze

  def initialize(driver)
    @driver = driver
    @wait = Selenium::WebDriver::Wait.new timeout: 10
  end

  def source = find_element xpath: SOURCE_XPATH
  def dest = find_element xpath: DEST_XPATH

  def translate(text, tl:, sl: nil)
    in_a_new_tab do
      @driver.get "https://translate.google.com/?sl=#{sl || 'auto'}&tl=#{tl}"

      source.send_keys text
      dest.text
    end
  end

  def find_element(**options)
    @wait.until { @driver.find_element **options }
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
