class CreateSolarSystems < ActiveRecord::Migration
  def change
    create_table :solar_systems do |t|
      t.string :name
      t.references :region
      t.string :eve_id
      t.boolean :station, :default => "F"
    end
    add_index :solar_systems, :region_id
  end
end
