# frozen_string_literal: true

require_relative '../require'

class OEKSound < Page
  PRICE_XPATH = '/html/body/header/div[2]/div/div/strong'

  def initialize(*, driver: nil, **)
    super
    @driver.get 'https://oeksound.com/plugins/soothe2'
  end

  def get_price
    [
      'OEK Sound Soothe2',
      find_element(xpath: PRICE_XPATH).text,
    ].join(': ')
  end
end
