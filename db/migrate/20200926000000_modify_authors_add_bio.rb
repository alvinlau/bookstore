class ModifyAuthorsAddBio < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :bio, :text
  end
end
