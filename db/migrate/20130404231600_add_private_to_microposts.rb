class AddPrivateToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :direct_message, :boolean, default: false
  end
end
