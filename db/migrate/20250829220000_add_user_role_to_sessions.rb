class AddUserRoleToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :user_role, :string, default: 'host'
    add_column :sessions, :allow_remote_listening, :boolean, default: false
  end
end