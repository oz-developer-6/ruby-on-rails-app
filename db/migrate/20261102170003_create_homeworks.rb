class CreateHomeworks < ActiveRecord::Migration[8.1]
  def change
    create_table :homeworks do |t|
      t.references :school, null: false, foreign_key: true
      t.string :title, null: false
      t.string :subject, null: false
      t.text :description
      t.integer :max_score, null: false, default: 100
      t.date :due_date, null: false

      t.timestamps
    end

    add_index :homeworks, :due_date
    add_index :homeworks, :subject
  end
end
