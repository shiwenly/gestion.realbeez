class AddDefaultPic < ActiveRecord::Migration[5.2]
  def change
    change_column :tenants, :contract, :string, default: "image/upload/v1598991055/default_annonce_k6x0wm.png"
    change_column :tenants, :inventory, :string, default: "image/upload/v1598991055/default_annonce_k6x0wm.png"
    change_column :waters, :photo, :string, default: "image/upload/v1598991055/default_annonce_k6x0wm.png"
  end
end
