class AddPlaylistIdToMedia < ActiveRecord::Migration[7.1]
  def change
    add_reference :media, :playlist, null: false, foreign_key: true
  end
end
