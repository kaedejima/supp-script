class CreateLines < ActiveRecord::Migration[5.2]
  def change
    create_table :lines do |t|
      t.references :scripts
      t.references :contributors
      t.string :body
    end
  end
end
