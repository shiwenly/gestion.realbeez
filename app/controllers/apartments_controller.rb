class ApartmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_apartment, only: [:edit, :show, :update, :destroy]

  def show
    authorize @apartment
    @tenants = policy_scope(Tenant.where("statut = ? AND apartment_id = ?", "active", @apartment.id ).order(created_at: :asc))

    unless @tenants == []
      @tenant = @apartment.tenants.select { |t| t.current_tenant == true}[0]
      @rents_unorder = Rent.search_by_date(Date.today.year)
      @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id && a.tenant.apartment == @apartment}.sort_by { |b| b.period }
      @sum_rent_ask = 0
      @sum_service_charge_ask = 0
      @sum_rent_paid = 0
      @sum_service_charge_paid = 0
      @rents.each do |rent|
        @sum_rent_ask += rent.rent_ask
        @sum_service_charge_ask += rent.service_charge_ask
        @sum_rent_paid += rent.rent_paid
        @sum_service_charge_paid += rent.service_charge_paid
      end
      @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
      unless @tenant.rent == nil
        @loyer_annuel = (@tenant.rent + @tenant.service_charge) *12
      end
    end
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
