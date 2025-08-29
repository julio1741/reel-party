class AddPositionAndStatusToMedia < ActiveRecord::Migration[7.1]
  def change
    add_column :media, :position, :integer, null: false, default: 0
    add_column :media, :status, :string, null: false, default: 'queued'
    add_index :media, [:playlist_id, :position]
    add_index :media, [:playlist_id, :status]
  end
end
