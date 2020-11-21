class BuildingsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_building, only: [:edit, :show, :update, :destroy]

  def index
    @company = Company.find(params[:company_id])
    authorize @buildings = policy_scope(Building.where("statut = ? AND company_id = ?", "active", @company.id ).order(created_at: :asc))

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
              @apartment_sum_rent_ask = 0
              @apartment_sum_service_charge_ask = 0
              @apartment_sum_rent_paid = 0
              @apartment_sum_service_charge_paid = 0
              @apartment_solde = 0
              @loyer_annuel = (apartment.tenants.last.rent + apartment.tenants.last.service_charge) *12
              # Calculation
              apartment.tenants.each do |tenant|
                @rents_unorder = Rent.search_by_date(Date.today.year)
                @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == tenant.id && a.tenant.statut == "active" && a.tenant.apartment == apartment && a.tenant.apartment.statut == "active"  && a.tenant.apartment.building == building && a.tenant.apartment.building.company == @company }.sort_by { |b| b.period }
                # @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == tenant.id && a.tenant.apartment == apartment && a.tenant.apartment.building == @building }.sort_by { |b| b.period }
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

  def show
    # Appartments
    authorize @building
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
    # Liasse
    @liasses = policy_scope(Liasse.where("statut = ? AND building_id = ?", "active", @building.id).order(year: :asc))

    # unless @apartments == []
    #   @building_sum_rent_ask = 0
    #   @building_sum_service_charge_ask = 0
    #   @building_sum_rent_paid = 0
    #   @building_sum_service_charge_paid = 0
    #   @building_solde = 0
    #   @building_loyer_annuel = 0
    #   @apartments.each do |apartment|
    #     unless apartment.tenants == []

    # @rents_unorder = Rent.search_by_date(Date.today.year)
    # @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id && a.tenant.apartment == apartment && a.tenant.apartment.building == @building }.sort_by { |b| b.period }
    #       @sum_rent_ask = 0
    #       @sum_service_charge_ask = 0
    #       @sum_rent_paid = 0
    #       @sum_service_charge_paid = 0
    #       @rents.each do |rent|
    #         @sum_rent_ask += rent.rent_ask
    #         @sum_service_charge_ask += rent.service_charge_ask
    #         @sum_rent_paid += rent.rent_paid
    #         @sum_service_charge_paid += rent.service_charge_paid
    #       end
    #       @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
    #       @loyer_annuel = (@tenant.rent + @tenant.service_charge) *12
    #       @building_sum_rent_ask += @sum_rent_ask
    #       @building_sum_service_charge_ask += @sum_service_charge_ask
    #       @building_sum_rent_paid += @sum_rent_paid
    #       @building_sum_service_charge_paid += @sum_service_charge_paid
    #       @building_solde += @solde
    #       @building_loyer_annuel += @loyer_annuel
    #     end
    #   end
    # end
  end

  def new
    authorize @building = Building.new
    @company = Company.find(params[:company_id])
  end

  def create
    authorize @building = Building.new(building_params)
    @company = Company.find(params[:company_id])
    @building.company = @company
    @building.user_id = current_user.id
    @building.statut = "active"
    if @building.save
      redirect_to company_buildings_path(@company)
    else
      render :new
    end
  end

  def edit
    authorize @building
  end

  def update
    authorize @building
    if @building.update(building_params)
      redirect_to company_buildings_path(@building.company)
    else
      render :edit
    end
  end

  def destroy
    authorize @building
    @building.statut = "deleted"
    @building.save
    redirect_to company_buildings_path(@building.company)
  end

  private

  def building_params
    params.require(:building).permit(
      :address,
      :number_of_flat
    )
  end

  def set_building
    @building = Building.find(params[:id])
  end

end
