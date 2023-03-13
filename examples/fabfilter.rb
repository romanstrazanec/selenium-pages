# frozen_string_literal: true

require_relative '../require'

class FabFilter < Page
  VERIFY_XPATH = '/html/body/div/section/div/div/article[1]/div/a/h2'
  PRICE_XPATH = '/html/body/div/section/div/div/article[1]/div/footer/span[2]'

  def initialize(*, driver: nil, **)
    super
    @driver.get 'https://www.fabfilter.com/shop/pro-q-3-equalizer-plug-in'
  end

  def get_price
    [
      find_element(xpath: VERIFY_XPATH).text,
      find_element(xpath: PRICE_XPATH).text,
    ].join(': ')
  end
end
