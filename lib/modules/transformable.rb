module Transformable

  def change_data_to_array(data_class)
    data_class.all.values
  end

end
