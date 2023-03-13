# frozen_string_literal: true

class Selenium::WebDriver::Element
  def parent = find_element xpath: './..'
  def children(*, **options) = find_elements xpath: '*', **options
  def child(*, **options) = find_element xpath: '*', **options
end
