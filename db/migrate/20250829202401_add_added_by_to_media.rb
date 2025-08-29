class AddAddedByToMedia < ActiveRecord::Migration[7.1]
  def change
    add_column :media, :added_by, :string
  end
end
