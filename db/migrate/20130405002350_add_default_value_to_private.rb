class AddDefaultValueToPrivate < ActiveRecord::Migration
  def change
    change_column :microposts, :private, :boolean, :default => false
  end
end
