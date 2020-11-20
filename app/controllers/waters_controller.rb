class WatersController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_water, only: [:edit, :show, :update, :destroy]

  def show
    authorize @water
  end

  def new
    authorize @water = Water.new
    @tenant = Tenant.find(params[:tenant_id])
  end

  def create
    authorize @water = Water.new(water_params)
    @tenant = Tenant.find(params[:tenant_id])
    @water.tenant = @tenant
    @water.user_id = current_user.id
    @water.statut = "active"
    if @water.save
      redirect_to apartment_path(@tenant.apartment)
    else
      render :new
    end
  end

  def edit
    authorize @water
  end

  def update
    authorize @water
    if @water.update(water_params)
      redirect_to apartment_path(@water.tenant.apartment)
    else
      render :edit
    end
  end

  def destroy
    authorize @water
    @water.statut = "deleted"
    @water.save
    redirect_to tenant_path(@water.tenant)
  end

  private

  def water_params
    params.require(:water).permit(
      :submission_date,
      :quantity,
      :photo
    )
  end

  def set_water
    @water = Water.find(params[:id])
  end
end
