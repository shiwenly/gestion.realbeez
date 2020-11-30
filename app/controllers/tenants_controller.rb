class TenantsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_tenant, only: [:edit, :show, :update, :destroy]

  def index
    if params[:apartment_id] != nil
      authorize @apartment = Apartment.find(params[:apartment_id])
      @tenants = policy_scope(Tenant.where("statut = ? AND apartment_id = ?", "active", @apartment.id ).order(created_at: :desc))
      @tenants_actuel = policy_scope(Tenant.where("statut = ? AND apartment_id = ? AND current_tenant = ?", "active", @apartment.id, true ).order(created_at: :desc))
      @tenants_passé = policy_scope(Tenant.where("statut = ? AND apartment_id = ? AND current_tenant = ?", "active", @apartment.id, false ).order(created_at: :desc))
      @waters = policy_scope(Water.where("statut = ?", "active").order(submission_date: :desc).limit(10))
      unless @tenants == []
        @apartment_sum_rent_ask = 0
        @apartment_sum_service_charge_ask = 0
        @apartment_sum_rent_paid = 0
        @apartment_sum_service_charge_paid = 0
        @apartment_solde = 0
        @loyer_annuel = (@apartment.tenants.last.rent + @apartment.tenants.last.service_charge) *12
        # Calculation
        @tenants.each do |tenant|
          @rents_unorder = Rent.search_by_date(Date.today.year)
          @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == tenant.id }.sort_by { |b| b.period }
          @sum_rent_ask = @rents.map{|a| a.rent_ask}.sum
          @sum_service_charge_ask = @rents.map{|a| a.service_charge_ask }.sum
          @sum_rent_paid = @rents.map{|a| a.rent_paid}.sum
          @sum_service_charge_paid = @rents.map{|a| a.service_charge_paid }.sum
          @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
          # add to appartment sum
          @apartment_sum_rent_ask += @sum_rent_ask
          @apartment_sum_service_charge_ask += @sum_service_charge_ask
          @apartment_sum_rent_paid += @sum_rent_paid
          @apartment_sum_service_charge_paid += @sum_service_charge_paid
          @apartment_solde += @solde
        end
      end
    else
      @tenants = policy_scope(Tenant.where("statut = ?", "active",).order(created_at: :desc))
    end
  end

  def show
    authorize @tenant
    @waters = policy_scope(Water.where("statut = ? AND tenant_id = ?", "active", @tenant.id ).order(submission_date: :desc).limit(10))
    # @rents = policy_scope(Rent.where("statut = ? AND tenant_id = ?", "active", @tenant.id ).order(period: :asc))
    if params[:search] == nil
      @rents_unorder = Rent.search_by_date(Date.today.year)
      @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id}.sort_by { |b| b.period }
      @sum_rent_ask = @rents.map{|a| a.rent_ask}.sum
      @sum_service_charge_ask = @rents.map{|a| a.service_charge_ask }.sum
      @sum_rent_paid = @rents.map{|a| a.rent_paid}.sum
      @sum_service_charge_paid = @rents.map{|a| a.service_charge_paid }.sum
      @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
    else
      @rents_unorder = Rent.search_by_date(params[:search][:date].to_i)
      @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id}.sort_by { |b| b.period }
      @sum_rent_ask = @rents.map{|a| a.rent_ask}.sum
      @sum_service_charge_ask = @rents.map{|a| a.service_charge_ask }.sum
      @sum_rent_paid = @rents.map{|a| a.rent_paid}.sum
      @sum_service_charge_paid = @rents.map{|a| a.service_charge_paid }.sum
      @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
    end
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
    @tenant.current_tenant = true
    if @tenant.save
      redirect_to apartment_tenants_path(@tenant.apartment)
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
      redirect_to apartment_tenants_path(@tenant.apartment)
    else
      render :edit
    end
  end

  def destroy
    authorize @tenant
    @tenant.statut = "deleted"
    @tenant.save
    redirect_to apartment_tenants_path(@tenant.apartment)
  end

  def search_by_date

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
