class AddThumbnailurlToLines < ActiveRecord::Migration[5.2]
  def change
    add_column :lines, :thumbnail_url, :string
  end
end
