class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.string :nombre
      t.string :apellido
      t.string :email
      t.string :telefono
      t.string :pais
      t.string :ciudad
      t.string :departamento
      t.string :calle
      t.integer :total
      t.boolean :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
