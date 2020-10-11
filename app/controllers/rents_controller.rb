class RentsController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_rent, only: [:edit, :show, :update, :destroy]

  def show
    authorize @rent
  end

  def new
    authorize @rent = Rent.new
    @tenant = Tenant.find(params[:tenant_id])
  end

  def create
    authorize @rent = Rent.new(rent_params)
    @tenant = Tenant.find(params[:tenant_id])
    @rent.tenant = @tenant
    @rent.user_id = current_user.id
    @rent.statut = "active"
    if @rent.save
      redirect_to tenant_path(@tenant)
    else
      render :new
    end
  end

  def edit
    authorize @rent
  end

  def update
    authorize @rent
    if @rent.update(rent_params)
      redirect_to tenant_path(@rent.tenant)
    else
      render :edit
    end
  end

  def destroy
    authorize @rent
    @rent.statut = "deleted"
    @rent.save
    redirect_to tenant_path(@rent.tenant)
  end

  private

  def rent_params
    params.require(:rent).permit(
      :period,
      :rent_ask,
      :service_charge_ask,
      :rent_paid,
      :service_charge_paid,
      :date_payment
    )
  end

  def set_rent
    @rent = Rent.find(params[:id])
  end
end
