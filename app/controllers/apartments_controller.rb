class ApartmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_apartment, only: [:edit, :show, :update, :destroy]

  def index
    # Appartments
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
      redirect_to building_apartments_path(@apartment.building)
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
      redirect_to building_apartments_path(@apartment.building)
    else
      render :edit
    end
  end

  def destroy
    authorize @apartment
    @apartment.statut = "deleted"
    @apartment.save
    redirect_to building_apartments_path(@apartment.building)
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
