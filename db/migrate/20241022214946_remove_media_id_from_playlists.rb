class RemoveMediaIdFromPlaylists < ActiveRecord::Migration[7.1]
  def change
    remove_column :playlists, :media_id, :integer
  end
end
