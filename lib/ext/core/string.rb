# frozen_string_literal: true

class String
  def clean
    self.unicode_normalize(:nfkd).gsub('ß', 'ss').gsub(/\W/, '').encode('ASCII', replace: '')
  end
end
