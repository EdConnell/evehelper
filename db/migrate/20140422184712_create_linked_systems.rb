class CreateLinkedSystems < ActiveRecord::Migration
  def change
    create_table :linked_systems do |t|
      t.references :solar_system
      t.references :link
    end
    add_index :linked_systems, :link_id
    add_index :linked_systems, :solar_system_id
  end
end
