class AddDescriptionColumnToOptionValues < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_option_values, :description, :text, default: ''
  end
end
