# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'
require 'open-uri'
require 'nokogiri'

BASE_URL = "https://api.eveonline.com/"
JUMP_URL = "map/Jumps.xml.aspx"
KILLS_URL = "map/Kills.xml.aspx"
SOV_URL = "map/Sovereignty.xml.aspx"
STATION_URL = "eve/ConquerableStationList.xml.aspx"
SYSTEMS_TO_IGNORE = (30000326..30000432).to_a + (30001449..30001525).to_a + (30001598..30001643).to_a
TOTAL_NUMBER_OF_SYSTEMS = 5201.0

class Update

  #This method requires a set of CSV files containing all corresponding solar system information
  def self.base_seed
    puts "Begining Database Seed"
    print "0% Complete Seeding Solar Systems"
    count = 0
    CSV.foreach('./db/solarSystems.csv', {:headers => true, :header_converters => :symbol, :converters => :integer}) do |system|
      print "\e[0K\r" + "#{((count / TOTAL_NUMBER_OF_SYSTEMS) * 100).round(1)}% Complete Seeding Solar Systems"
      region = Region.find_or_create_by_name(system[:region])
      new_system = SolarSystem.create({name: system[:name], region: region, eve_id: system[:id], station: system[:station]})
      stat = new_system.stats.build
      stat.update_attributes(jumps: system[:jumps], ship_kills: system[:ship_kills], npc_kills: system[:npc_kills], pod_kills: system[:pod_kills])
      new_system.save
      stat.save
      count += 1
    end

    puts "\nSolar System Seeding Complete"

    print "0% Complete Seeding Solar System Links"
    count = 0
    CSV.foreach('./db/solarSystemMap.csv', {:headers => true, :header_converters => :symbol}) do |system|
      print "\e[0K\r" + "#{((count / TOTAL_NUMBER_OF_SYSTEMS) * 100).round(1)}% Complete Seeding Solar System Links"
      home_system = SolarSystem.where(eve_id: system[:fromsystem]).first
      neighbors = system[:tosystems].split(', ')
      neighbors.map! {|eve_id| SolarSystem.where(eve_id: eve_id).first}
      home_system.links = neighbors
      home_system.save
      count += 1
    end

    puts "\nSeeding complete!"
  end


  #This method will only update the following attributes: station, jumps, and kills
  def self.from_api
    kill_xml = Nokogiri::XML(open(BASE_URL + KILLS_URL))
    jump_xml = Nokogiri::XML(open(BASE_URL + JUMP_URL))
    station_xml = Nokogiri::XML(open(BASE_URL + STATION_URL))
    SolarSystem.all.each do |system|
      next if Time.now - system.stats.first.created_at <= 1800 #Cache on the API call is thirty minutes.
      system_xpath = "//row[@solarSystemID='#{system.eve_id}']"
      new_stats = Hash.new
      new_stats[:jumps], new_stats[:pod_kills], new_stats[:ship_kills], new_stats[:npc_kills] = 0,0,0,0
      new_stats[:jumps] = jump_xml.xpath(system_xpath).attr('shipJumps') if jump_xml.at(system_xpath)
      new_stats[:pod_kills], new_stats[:ship_kills], new_stats[:npc_kills] = kills_xml.xpath(system_xpath).attr('podKills').value, kills_xml.xpath(system_xpath).attr('shipKills').value, kills_xml.xpath(system_xpath).attr('factionKills').value if kills_xml.at(system_xpath)
      system.stats.create(new_stats)
      if system.station == false
        system.station = true if station_xml.at(system_xpath)
      end
      system.save
    end
  end

  #This method will only update the same attributes as it would from the API, but requires the information already be in CSV form
  def self.from_csv
    puts "Updating database"
    print "0% Complete"
    count = 0
    CSV.foreach('./db/solarSystems.csv', {:headers => true, :header_converters => :symbol, :converters => :integer}) do |system|
      print "\e[0K\r" + "#{((count / TOTAL_NUMBER_OF_SYSTEMS) * 100).round(1)}% Complete"
      solar_system = SolarSystem.where(eve_id: system[:eve_id])
      solar_system.stats.build(jumps: system[:jumps], ship_kills: system[:ship_kills], npc_kills: system[:npc_kills], pod_kills: system[:pod_kills])
      solar_system.station = system[:station]
      solar_system.save
      count += 1
    end

    puts "\nSolar System Update Complete"
    puts "\nUpdating complete!"
  end
end

#Uncomment the method you plan to use
Update.base_seed
#Update.from_api
#Update.from_csv
