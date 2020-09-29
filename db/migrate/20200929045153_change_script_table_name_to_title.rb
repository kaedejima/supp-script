class ChangeScriptTableNameToTitle < ActiveRecord::Migration[5.2]
  def change
    rename_column :scripts, :name, :title
  end
end
