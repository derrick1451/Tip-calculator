class CreateCalculations < ActiveRecord::Migration[8.0]
  def change
    create_table :calculations do |t|
      t.decimal :bill_amount, precision: 10, scale: 2, null: false
      t.decimal :tip_percentage, precision: 5, scale: 2, null: false
      t.decimal :tip_amount, precision: 10, scale: 2, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.integer :people_count, null: false, default: 1
      t.decimal :per_person_amount, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :calculations, :created_at
    add_index :calculations, :bill_amount
    add_index :calculations, :tip_percentage
  end
end
