class CreateMarkings < ActiveRecord::Migration[8.1]
  def change
    create_table :markings do |t|
      t.references :homework, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.decimal :score, precision: 5, scale: 2
      t.string :status, null: false, default: "pending"
      t.text :feedback
      t.datetime :marked_at

      t.timestamps
    end

    add_index :markings, [:homework_id, :student_id], unique: true
    add_index :markings, :status
  end
end
