class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, limit: 30
      t.boolean :allow_write, null: false, default: false
      t.boolean :admin, null: false, default: false

      t.timestamps
    end
    add_index :users, :name, unique: true
  end
end
