
class Time
  def self.moc(arg)
    t = Time.utc(2000, 01, 01)
    day = 60 * 24
    start = day * 36525         # 100 years plus leap days
    t += (arg - start).minute
    t
  end
end
