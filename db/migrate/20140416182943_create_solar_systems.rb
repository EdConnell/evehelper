class CreateSolarSystems < ActiveRecord::Migration
  def change
    create_table :solar_systems do |t|
      t.string :name
      t.references :region
      t.string :eve_id
      t.boolean :station, :default => "F"
      t.integer :x
      t.integer :y
    end
    add_index :solar_systems, :region_id
  end
end
