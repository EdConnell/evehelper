class SolarSystem < ActiveRecord::Base
  attr_accessible :name, :region, :eve_id, :station

  belongs_to :region
  has_many :updates
  has_many :linked_systems
  has_many :links, :through => :linked_systems, :class_name => "SolarSystem"
  has_many :stats, :order => "created_at DESC"

  #These methods are used as a shortcut to access their most recent stats
  def most_recent
    self.stats.first
  end

  def npc_kills
    most_recent.npc_kills
  end

  def ship_kills
    most_recent.ship_kills
  end

  def pod_kills
    most_recent.ship_kills
  end

  def jumps
    most_recent.jumps
  end

  def set_x_and_y(coordinate_values)
    self.x = coordinate_values[:x]
    self.y = coordinate_values[:y]
    self.save
  end
end
