class ChangeColumnPresentationurlPresentationid < ActiveRecord::Migration[5.2]
  def change
    rename_column :scripts, :presentation_url, :presentation_id
  end
end
