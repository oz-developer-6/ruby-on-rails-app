class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.references :school, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :enrollment_number, null: false

      t.timestamps
    end

    add_index :students, :enrollment_number, unique: true
    add_index :students, :email
  end
end
