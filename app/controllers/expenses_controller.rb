class ExpensesController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_expense, only: [:edit, :show, :update, :destroy]

  def index
    @building = Building.find(params[:building_id])
    @expenses = policy_scope(Expense.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
    # Appartments
    @apartments = policy_scope(Apartment.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
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
  end

  def show
    authorize @expense

  end

  def new
    authorize @expense = Expense.new
    @building = Building.find(params[:building_id])
    @apartment_name = ["Tous"]
    @apartments_name = @building.apartments.each do |apartment|
      if apartment.statut == "active"
        @apartment_name  << apartment.name.to_s
      end
    end
  end

  def create
    authorize @expense = Expense.new(expense_params)
    @building = Building.find(params[:building_id])
    @expense.building = @building
    @expense.user_id = current_user.id
    @expense.statut = "active"
    if @expense.save
      redirect_to building_path(@building)
    else
      render :new
    end
  end

  def edit
    authorize @expense
    @apartment_name = ["Tous"]
    @apartments_name = @expense.building.apartments.each do |apartment|
      if apartment.statut == "active"
        @apartment_name  << apartment.name.to_s
      end
    end
  end

  def update
    authorize @expense
    if @expense.update(expense_params)
      redirect_to building_path(@expense.building)
    else
      render :edit
    end
  end

  def destroy
    authorize @expense
    @expense.statut = "deleted"
    @expense.save
    redirect_to building_path(@expense.building)
  end

  private

  def expense_params
    params.require(:expense).permit(
      :apartment_name,
      :expense_type,
      :date,
      :supplier,
      :amount_ttc,
      :amount_vat,
      :photo,
      :deductible
    )
  end

  def set_expense
    @expense = Expense.find(params[:id])
  end

end
