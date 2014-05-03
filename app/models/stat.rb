class Stat < ActiveRecord::Base
  attr_accessible :jumps, :npc_kills, :pod_kills, :ship_kills

  belongs_to :solar_system

end
