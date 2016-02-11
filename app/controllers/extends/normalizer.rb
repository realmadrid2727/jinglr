module Extends::Normalizer
private
  def normalize_sort_time(time)
    return DateTime.strptime(time, '%m-%d-%Y')
  end
end