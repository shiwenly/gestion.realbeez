class CompaniesController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_company, only: [:edit, :show, :update, :destroy]

  def index
    @companies = policy_scope(Company.where("statut = ?", "active" ).order(created_at: :asc))
  end

  def show
    authorize @company
    @buildings = policy_scope(Building.where("statut = ? AND company_id = ?", "active", @company.id ).order(created_at: :asc))
    unless @buildings == []
      @company_building_sum_rent_ask = 0
      @company_building_sum_service_charge_ask = 0
      @company_building_sum_rent_paid = 0
      @company_building_sum_service_charge_paid = 0
      @company_building_solde = 0
      @company_building_loyer_annuel = 0
      @buildings.each do |building|
        unless building.apartments == []
          @building_sum_rent_ask = 0
          @building_sum_service_charge_ask = 0
          @building_sum_rent_paid = 0
          @building_sum_service_charge_paid = 0
          @building_solde = 0
          @building_loyer_annuel = 0
          building.apartments.each do |apartment|
            unless apartment.tenants == []
              @tenant = apartment.tenants.select { |t| t.current_tenant == true}[0]
              @rents_unorder = Rent.search_by_date(Date.today.year)
              @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id && a.tenant.apartment == apartment && a.tenant.apartment.building == building && a.tenant.apartment.building.company == @company }.sort_by { |b| b.period }
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
              @loyer_annuel = (@tenant.rent + @tenant.service_charge) *12
              @building_sum_rent_ask += @sum_rent_ask
              @building_sum_service_charge_ask += @sum_service_charge_ask
              @building_sum_rent_paid += @sum_rent_paid
              @building_sum_service_charge_paid += @sum_service_charge_paid
              @building_solde += @solde
              @building_loyer_annuel += @loyer_annuel
            end
          end
          @company_building_sum_rent_ask += @building_sum_rent_ask
          @company_building_sum_service_charge_ask += @building_sum_service_charge_ask
          @company_building_sum_rent_paid += @building_sum_rent_paid
          @company_building_sum_service_charge_paid += @building_sum_service_charge_paid
          @company_building_solde += @building_solde
          @company_building_loyer_annuel += @building_loyer_annuel
        end
      end
    end
  end

  def new
    authorize @company = Company.new
  end

  def create
    authorize @company = Company.new(company_params)
    @company.user_id = current_user.id
    @company.statut = "active"
    if @company.save
      redirect_to companies_path
    else
      render :new
    end
  end

  def edit
    authorize @company
  end

  def update
    authorize @company
    if @company.update(company_params)
      redirect_to companies_path
    else
      render :edit
    end
  end

  def destroy
    authorize @company
    @company.statut = "deleted"
    @company.save
    redirect_to companies_path
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :address,
      :corporate_tax,
      :vat,
      :associe
    )
  end

  def set_company
    @company = Company.find(params[:id])
  end

end
