class ModifyPublishingHouses < ActiveRecord::Migration[5.2]
  def change
    change_column :publishing_houses, :discount, :decimal, precision: 5, scale: 2
  end
end
