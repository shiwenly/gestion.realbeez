class ApartmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_apartment, only: [:edit, :show, :update, :destroy]

  def index
    # Appartments
    if params[:building_id] != nil
      @building = Building.find(params[:building_id])
      authorize @apartments = policy_scope(Apartment.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
      unless @apartments == []
        @building_sum_rent_ask = 0
        @building_sum_service_charge_ask = 0
        @building_sum_rent_paid = 0
        @building_sum_service_charge_paid = 0
        @building_solde = 0
        @building_loyer_annuel = 0
        @apartments.each do |apartment|
          unless apartment.tenants == []
            @apartment_sum_rent_ask = 0
            @apartment_sum_service_charge_ask = 0
            @apartment_sum_rent_paid = 0
            @apartment_sum_service_charge_paid = 0
            @apartment_solde = 0
            @loyer_annuel = (apartment.tenants.last.rent + apartment.tenants.last.service_charge) *12
            # Calculation
            apartment.tenants.each do |tenant|
              @rents_unorder = Rent.search_by_date(Date.today.year)
              @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == tenant.id && a.tenant.statut == "active" && a.tenant.apartment == apartment && a.tenant.apartment.building == @building }.sort_by { |b| b.period }
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
            @building_sum_rent_ask += @apartment_sum_rent_ask
            @building_sum_service_charge_ask += @apartment_sum_service_charge_ask
            @building_sum_rent_paid += @apartment_sum_rent_paid
            @building_sum_service_charge_paid += @apartment_sum_service_charge_paid
            @building_solde += @apartment_solde
            @building_loyer_annuel += @loyer_annuel
          end
        end
        # Expense
        # @expenses = policy_scope(Expense.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
      end
      if params[:search] == nil
        @expenses_unorder = Expense.search_by_date_expense(Date.today.year)
        @expenses = @expenses_unorder.select{|a| a.statut == "active" && a.building_id == @building.id}.sort_by { |b| b.date }
        @sum_ttc = @expenses.map{|a| a.amount_ttc}.sum
        @sum_vat = @expenses.map{|a| a.amount_vat}.sum
      else
        @expenses_unorder = Expense.search_by_date_expense(params[:search][:date].to_i)
        @expenses = @expenses_unorder.select{|a| a.statut == "active" && a.building_id == @building.id}.sort_by { |b| b.date }
        @sum_ttc = @expenses.map{|a| a.amount_ttc}.sum
        @sum_vat = @expenses.map{|a| a.amount_vat}.sum
      end
      # Liasse
      @liasses = policy_scope(Liasse.where("statut = ? AND building_id = ?", "active", @building.id).order(year: :asc))
    else
      authorize @apartments = policy_scope(Apartment.where("statut = ?", "active").order(created_at: :asc))
    end
  end

  def show
    authorize @apartment
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
  end

  def new
    @companies_user = Company.where("user_id = ? AND statut = ?", current_user.id, "active" ).order(created_at: :asc)
    # create company détenu en nom propre if doesnt exist
    if @companies_user.one? { |c| c.name == "n/a - détention en nom propre"} == false
      create_société_nom_propre
    end
    if params[:building_id] != nil
      authorize @apartment = Apartment.new
    else
      authorize @apartment = Apartment.new
      # List of companies of the user and where user is an associate
      @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
      @companies = []
      @companies_active.each do |c|
        associe = c.associe.downcase.split(",").map(&:strip)
        if associe.include?(current_user.email) || c.user == current_user
          @companies << c
        end
      end
      @buildings = []
      @companies.each do |c|
        c.buildings.each do |b|
          if b.statut == "active"
            @buildings << b
          end
        end
      end
    end
  end

  def create_société_nom_propre
    @company = Company.new(name: "n/a - détention en nom propre", user_id: current_user.id, statut: "active", associe: "")
    @company.save
  end

  def create
    authorize @apartment = Apartment.new(apartment_params)
    # @building = Building.find(params[:building_id])
    @apartment.company = Company.find(params[:apartment][:company_id])
    @apartment.building_id = params[:apartment][:building_id]
    @apartment.user_id = current_user.id
    @apartment.statut = "active"
    if @apartment.save
      redirect_to apartments_path
    else
      render :new
    end
  end

  def edit
    authorize @apartment
    # List of companies of the user and where user is an associate
    @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
    @companies = []
    @companies_active.each do |c|
      associe = c.associe.downcase.split(",").map(&:strip)
      if associe.include?(current_user.email) || c.user == current_user
        @companies << c
      end
    end
    @buildings = []
    @companies.each do |c|
      c.buildings.each do |b|
        if b.statut == "active"
          @buildings << b
        end
      end
    end
  end

  def update
    authorize @apartment
    if @apartment.update(apartment_params)
      redirect_to apartments_path
    else
      render :edit
    end
  end

  def destroy
    authorize @apartment
    @apartment.statut = "deleted"
    @apartment.save
    redirect_to apartments_path
  end

  private

  def apartment_params
    params.require(:apartment).permit(
      :name,
      :water,
      :building_id,
      :company_id
    )
  end

  def set_apartment
    @apartment = Apartment.find(params[:id])
  end

end
