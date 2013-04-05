class AddPrivateToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :private, :boolean, default: false
  end
end
