class ChangeColumnOfScripts < ActiveRecord::Migration[5.2]
  def change
    rename_column :scripts, :slides_url, :presentation_url
  end
end
