class AddOrderColumnToLines < ActiveRecord::Migration[5.2]
  def change
    add_column :lines, :order_num, :integer
  end
end
