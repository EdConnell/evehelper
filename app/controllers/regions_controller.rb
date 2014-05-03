class RegionsController < ApplicationController
  def index

  end

  def show
    @region = Region.find_by_name(params[:region_name])
    @data = SolarSystem.where(region_id: @region.id).to_json(:methods => [:jumps, :npc_kills, :ship_kills, :pod_kills], :except => [:region_id, :created_at, :updated_at, :id])
  end
end
