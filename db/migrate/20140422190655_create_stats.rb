class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.references :solar_system
      t.integer :npc_kills
      t.integer :ship_kills
      t.integer :pod_kills
      t.integer :jumps

      t.timestamps
    end
    add_index :stats, :solar_system_id
  end
end
