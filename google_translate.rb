class GoogleTranslate < Page
  XPATH_PREFIX = '/html/body/c-wiz/div/div[2]/c-wiz/div[2]/c-wiz/div[1]/'.freeze
  SOURCE_XPATH = "#{XPATH_PREFIX}div[2]/div[3]/c-wiz[1]/span/span/div/textarea".freeze
  DEST_XPATH = "#{XPATH_PREFIX}div[2]/div[3]/c-wiz[2]/div[8]/div/div[1]/span[1]/span/span".freeze

  def source = find_element xpath: SOURCE_XPATH
  def dest = find_element xpath: DEST_XPATH

  def translate(text, tl:, sl: nil)
    in_a_new_tab do
      url = "https://translate.google.com/?sl=#{sl || 'auto'}&tl=#{tl}&op=translate&text=#{text.gsub(/\s+/, '%20')}"
      driver.get url

      # source.send_keys text
      dest.text
    end
  end
end
