class BuildingsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_building, only: [:edit, :show, :update, :destroy]

  def show
    authorize @building
    @apartments = policy_scope(Apartment.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
  end

  def new
    authorize @building = Building.new
    @company = Company.find(params[:company_id])
  end

  def create
    authorize @building = Building.new(building_params)
    @company = Company.find(params[:company_id])
    @building.company = @company
    @building.user_id = current_user.id
    @building.statut = "active"
    if @building.save
      redirect_to company_path(@company)
    else
      render :new
    end
  end

  def edit
    authorize @building
  end

  def update
    authorize @building
    if @building.update(building_params)
      redirect_to company_path(@building.company)
    else
      render :edit
    end
  end

  def destroy
    authorize @building
    @building.statut = "deleted"
    @building.save
    redirect_to company_path(@building.company)
  end

  private

  def building_params
    params.require(:building).permit(
      :address,
      :number_of_flat
    )
  end

  def set_building
    @building = Building.find(params[:id])
  end

end
