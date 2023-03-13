# frozen_string_literal: true

require_relative '../require'

class UmanskyBass < Page
  VERIFY_XPATH = '///*[@id="ProductSection-6671014527094"]/div/div/div/div[2]/p[1]'
  PRICE_XPATH = '//*[@id="ProductSection-6671014527094"]/div/div/div/div[2]/span[2]'

  def initialize(*, driver: nil, **)
    super
    @driver.get 'https://www.submissionaudio.com/products/umanskybass'
  end

  def get_price
    [
      find_element(xpath: VERIFY_XPATH).text,
      find_element(xpath: PRICE_XPATH).text,
    ].join(': ')
  end
end
