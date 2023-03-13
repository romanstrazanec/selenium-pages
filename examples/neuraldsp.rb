# frozen_string_literal: true

require_relative '../require'

class NeuralDSP < Page
  VERIFY_XPATH = '//*[@id="__next"]/div/div[3]/main/div[1]/div[2]/div/div/h1'
  PRICE_XPATH = '//*[@id="__next"]/div/div[3]/main/div[1]/div[2]/div/div/div[2]/span'

  def initialize(*, driver: nil, **)
    super
    @driver.get 'https://neuraldsp.com/plugins/parallax'
  end

  def get_price
    [
      find_element(xpath: VERIFY_XPATH).text,
      find_element(xpath: PRICE_XPATH).text,
    ].join(': ')
  end
end
