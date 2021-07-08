class AddNameEtcToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :name, :string,     null: false
    add_column :users, :profile, :text,    null: false
    add_column :users, :occupation, :text, null: false
    add_column :users, :position, :text,   null: false
  end
end
