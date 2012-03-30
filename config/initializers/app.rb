class ActiveSupport::TimeWithZone
  def as_json(options={})
    (to_f*1000).to_i
  end
end
