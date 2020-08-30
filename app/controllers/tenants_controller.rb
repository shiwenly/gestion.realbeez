class TenantsController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_tenant, only: [:edit, :show, :update, :destroy]

  def show
    authorize @tenant

  end

  def new
    authorize @tenant = Tenant.new
    @apartment = Apartment.find(params[:apartment_id])
  end

  def create
    authorize @tenant = Tenant.new(tenant_params)
    @apartment = Apartment.find(params[:apartment_id])
    @tenant.apartment = @apartment
    @tenant.user_id = current_user.id
    @tenant.statut = "active"
    if @tenant.save
      redirect_to apartment_path(@apartment)
    else
      render :new
    end
  end

  def edit
    authorize @tenant
  end

  def update
    authorize @tenant
    if @tenant.update(tenant_params)
      redirect_to apartment_path(@tenant.apartment)
    else
      render :edit
    end
  end

  def destroy
    authorize @tenant
    @tenant.statut = "deleted"
    @tenant.save
    redirect_to apartment_path(@tenant.apartment)
  end

  private

  def tenant_params
    params.require(:tenant).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :rent,
      :service_charge,
      :deposit,
      :contract,
      :inventory,
      :move_in_date,
      :move_out_date,
      :current_tenant
    )
  end

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end

end
