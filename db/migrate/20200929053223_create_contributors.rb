class CreateContributors < ActiveRecord::Migration[5.2]
  def change
    create_table :contributors do |t|
      t.string :name
      t.references :scripts
    end
  end
end
