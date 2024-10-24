class AddEmbedCodeToMedia < ActiveRecord::Migration[7.1]
  def change
    add_column :media, :embed_code, :text
  end
end
