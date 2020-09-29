class CreateScripts < ActiveRecord::Migration[5.2]
  def change
    create_table :scripts do |t|
      t.string :name
      t.string :password_digest
      t.string :slides_url
      t.timestamps
    end
  end
end
