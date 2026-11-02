class CreateSchools < ActiveRecord::Migration[8.1]
  def change
    create_table :schools do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :address

      t.timestamps
    end

    add_index :schools, :name, unique: true
    add_index :schools, :code, unique: true
  end
end
