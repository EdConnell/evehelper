class LinkedSystem < ActiveRecord::Base
  attr_accessible :solar_system, :link

  belongs_to :solar_system
  belongs_to :link, :class_name => "SolarSystem"



end
