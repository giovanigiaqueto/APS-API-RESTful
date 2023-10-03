class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries, id: false do |t|
      t.string :name, primary_key: true, uniqueness: true, null: false
      t.integer :corruption_index, null: false
      t.decimal :annual_income, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
