class AddDescriptionColToScripts < ActiveRecord::Migration[5.2]
  def change
    add_column :scripts, :description, :string
  end
end
