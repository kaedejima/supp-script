class ChangeScriptsTablePasswordToKeyword < ActiveRecord::Migration[5.2]
  def change
    rename_column :scripts, :password_digest, :keyword
  end
end
