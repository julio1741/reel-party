class AddThumbnailToMedia < ActiveRecord::Migration[7.1]
  def change
    add_column :media, :thumbnail_url, :string
    add_column :media, :display_title, :string
  end
end
