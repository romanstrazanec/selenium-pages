class Object
  def blank? = respond_to?(:empty?) ? !!empty? : !self
  def present? = !blank?

  def presence
    self if present?
  end
end
