module Calculable

  def average(nums_to_sum, nums_to_count)
    nums_to_sum.to_f / nums_to_count.length.to_f
  end

  def add(nums)
    nums.sum
  end

end
