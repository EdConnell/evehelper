class Region < ActiveRecord::Base
  attr_accessible :name

  has_many :solar_systems

  def update_solar_systems(solar_system_data)
    self.solar_systems.each {|solar_system| solar_system.set_x_and_y(solar_system_data[solar_system.name])}
  end

  def self.find_by_given_name(name)
    self.where("lower(name) = ?", name.downcase).first
  end
end
