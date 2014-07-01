class RegionsController < ApplicationController
  def index
  end

  def show
    @region = Region.find_by_given_name(params[:region_name])
    @data = SolarSystem.where(region_id: @region.id).to_json(:methods => [:jumps, :npc_kills, :ship_kills, :pod_kills], :except => [:region_id, :created_at, :updated_at])
    @links = SolarSystem.where(region_id: @region.id).map{|system| system.linked_systems}.flatten.to_json
  end

  # Edit and Update methods/routes to be removed once database has all x/y values

  def edit
    @region = Region.find_by_given_name(params[:region_name])
    @data = SolarSystem.where(region_id: @region.id).to_json(:except => [:region_id, :created_at, :updated_at])
  end

  def update
    @region = Region.find_by_given_name(params[:region_name])
    @region.update_solar_systems(params[:solarSystemData])
    render :js => "/region/#{@region.name}"
  end

end
