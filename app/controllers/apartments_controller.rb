class ApartmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_apartment, only: [:edit, :show, :update, :destroy]

  def show
    authorize @apartment
    @tenants = policy_scope(Tenant.where("statut = ? AND apartment_id = ?", "active", @apartment.id ).order(created_at: :asc))
  end

  def new
    authorize @apartment = Apartment.new
    @building = Building.find(params[:building_id])
  end

  def create
    authorize @apartment = Apartment.new(apartment_params)
    @building = Building.find(params[:building_id])
    @apartment.building = @building
    @apartment.user_id = current_user.id
    @apartment.statut = "active"
    if @apartment.save
      redirect_to building_path(@building)
    else
      render :new
    end
  end

  def edit
    authorize @apartment
  end

  def update
    authorize @apartment
    if @apartment.update(apartment_params)
      redirect_to building_path(@apartment.building)
    else
      render :edit
    end
  end

  def destroy
    authorize @apartment
    @apartment.statut = "deleted"
    @apartment.save
    redirect_to building_path(@apartment.building)
  end

  private

  def apartment_params
    params.require(:apartment).permit(
      :name,
      :water
    )
  end

  def set_apartment
    @apartment = Apartment.find(params[:id])
  end

end
