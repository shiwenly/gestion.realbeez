class BuildingsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_building, only: [:edit, :show, :update, :destroy]


  def index
    authorize @buildings = policy_scope(Building.where("statut = ?", "active" ).order(created_at: :asc))
    if params[:company_id] != nil
      @company = Company.find(params[:company_id])
      authorize @buildings = policy_scope(Building.where("statut = ? AND company_id = ?", "active", @company.id ).order(name: :asc))
      @rents_active = Rent.where("statut = ? AND user_id = ?", "active", current_user.id)
      @rent_ask = @rents_active.select{ |r| r.tenant.company_id == @company.id && r.date_payment.strftime("%Y").to_i == Date.today.year }.map{ |r| r.rent_ask}.sum
      @service_charge_ask = @rents_active.select{ |r| r.tenant.company_id == @company.id && r.date_payment.strftime("%Y").to_i == Date.today.year }.map{ |r| r.service_charge_ask}.sum
      @rent_paid = @rents_active.select{ |r| r.tenant.company_id == @company.id && r.date_payment.strftime("%Y").to_i == Date.today.year }.map{ |r| r.rent_paid}.sum
      @service_charge_paid = @rents_active.select{ |r| r.tenant.company_id == @company.id && r.date_payment.strftime("%Y").to_i == Date.today.year}.map{ |r| r.service_charge_paid}.sum
      @solde = @rent_ask + @service_charge_ask - @rent_paid - @service_charge_paid
    else
      @companies_active = Company.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
      @companies = ["Toutes les sociétés", "n/a - détention en nom propre"]
      @companies_active.each do |c|
        # associe = c.associe.downcase.split(",").map(&:strip)
        # if associe.include?(current_user.email) || c.user == current_user
        #   @companies << c.name
        # end
        @companies << c.name
      end
      if params[:search] == nil || params[:search][:company] == "Toutes les sociétés"
        @companies_list = Company.where("statut = ? AND user_id = ?", "active", current_user.id)
        @buildings = Building.where("statut = ? AND user_id = ?", "active", current_user.id)
        # authorize @buildings = policy_scope(Building.where("statut = ?", "active" ).order(created_at: :asc))
        # @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
        # @companies_active.each do |c|
        #   associe = c.associe.downcase.split(",").map(&:strip)
        #   if associe.include?(current_user.email) || c.user == current_user
        #     @companies_list << c
        #   end
        # end
        # List of buildings where the user is an associate of the company or the user created the buildings
        # @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
        # @companies_list.each do |c|
        #   @buildings_active.each do |b|
        #     if b.company_name == c.name
        #       @buildings << b
        #     end
        #   end
        # end
        # @buildings_active.each do |b|
        #   if b.user == current_user
        #     if @buildings.include?(b) == false
        #       @buildings << b
        #     end
        #   end
        # end
      elsif params[:search][:company] == "n/a - détention en nom propre"
        authorize @buildings = Building.where("statut = ? AND user_id = ? AND company_name = ?", "active", current_user.id, "n/a - détention en nom propre" ).order(created_at: :asc)
      else
        authorize @buildings = Building.where("statut = ? AND user_id = ? AND company_name = ?", "active", current_user.id, params[:search][:company] ).order(created_at: :asc)
        # authorize @buildings = Building.search_by_company(params[:search][:company])
      end
      @buildings_list = @buildings.sort_by{ |b| b.name}
    end
  end

  def show
    # Appartments
    authorize @building
    @apartments = policy_scope(Apartment.where("statut = ? AND building_id = ? AND user_id = ?", "active", @building.id, current_user.id).order(created_at: :asc))
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
    # @companies_user = Company.where("user_id = ? AND statut = ?", current_user.id, "active" ).order(created_at: :asc)
    # @companies = @companies_active.select { |c| c.user_id == current_user || c.associe }
    # create company détenu en nom propre if doesnt exist
    # if @companies_user.one? { |c| c.name == "n/a - détention en nom propre"} == false
    #   create_société_nom_propre
    # end
    if params[:company_id] != nil
      authorize @building = Building.new
      @company = Company.find(params[:company_id])
    else
      authorize @building = Building.new
      @companies = Company.where("user_id = ? AND statut = ?", current_user.id, "active" ).order(created_at: :asc)
      # @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
      # @companies_active.each do |c|
      #   associe = c.associe.downcase.split(",").map(&:strip)
      #   if associe.include?(current_user.email) || c.user == current_user
      #     @companies << c
      #   end
      # end
    end
  end

  # def create_société_nom_propre
  #   @company = Company.new(name: "n/a - détention en nom propre", user_id: current_user.id, statut: "active", associe: "")
  #   @company.save
  # end

  def create
    authorize @building = Building.new(building_params)
    if params[:company_id] != nil
      @company = Company.find(params[:company_id])
      @building.company_name = @company.name
      @building.company_id = @company.id
      @building.user_id = current_user.id
      @building.statut = "active"
      if @building.save
        redirect_to company_buildings_path(@company)
      else
        render :new
      end
    else
      unless @building.company_id == nil || @building.company_id == ""
        @building.company_name = Company.find(@building.company_id).name
      else
        @building.company_name = "n/a - détention en nom propre"
      end
      @building.user_id = current_user.id
      @building.statut = "active"
      if @building.save
        redirect_to buildings_path
      else
        render :new
      end
    end
  end

  def edit
    authorize @building
    @companies = Company.where("user_id = ? AND statut = ?", current_user.id, "active" ).order(created_at: :asc)
    # @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
    # @companies_active.each do |c|
    #   associe = c.associe.downcase.split(",").map(&:strip)
    #   if associe.include?(current_user.email) || c.user == current_user
    #     @companies << c
    #   end
    # end
  end

  def update
    authorize @building
    unless params[:building][:company_id] == nil || params[:building][:company_id] == ""
      @building.company_name = Company.find(params[:building][:company_id]).name
    else
      @building.company_name = "n/a - détention en nom propre"
    end
    if @building.update(building_params)
      # Update all appartment with the correct company
      @apartments = Apartment.where("building_id = ?", @building)
      @apartments.each do |t|
        unless @building.company_id == nil || @building.company_id == ""
          t.company_name = Company.find(@building.company_id).name
          t.company_id = Company.find(@building.company_id).id
        else
          t.company_name = "n/a - détention en nom propre"
          t.company_id = nil
        end
        t.building_name = @building.name
        t.save
      end
      # Update all tenants with the correct company
      @tenants = Tenant.where("building_id = ?", @building)
      @tenants.each do |t|
        unless @building.company_id == nil || @building.company_id == ""
          t.company_name = Company.find(@building.company_id).name
          t.company_id = Company.find(@building.company_id).id
        else
          t.company_name = "n/a - détention en nom propre"
          t.company_id = nil
        end
        t.building_name = @building.name
        t.save
      end
      # Update all tenants with the correct company
      @expenses = Expense.where("building_id = ?", @building)
      @expenses.each do |t|
        unless @building.company_id == nil || @building.company_id == ""
          t.company_name = Company.find(@building.company_id).name
          t.company_id = Company.find(@building.company_id).id
        else
          t.company_name = "n/a - détention en nom propre"
          t.company_id = nil
        end
        t.building_name = @building.name
        t.save
      end
      redirect_to buildings_path
    else
      render :edit
    end
  end

  def destroy
    authorize @building
    @building.name = @building.name+" deleted #{@building.id}"
    @building.statut = "deleted"
    @building.save
    # flag as deleted all appartment from this building
    @apartments = Apartment.where("building_id = ?", @building)
    @apartments.each do |t|
      t.statut = "deleted"
      t.save
    end
    # flag as deleted all tenants from this building
    @tenants = Tenant.where("building_id = ?", @building)
    @tenants.each do |t|
      t.statut = "deleted"
      # flag as deleted all rents from this building
      t.rents.each do |r|
        r.statut = "deleted"
        r.save
      end
      t.save
    end
    # flag as deleted all expenses from this building
    @expenses = Expense.where("building_id = ?", @building)
    @expenses.each do |t|
      t.statut = "deleted"
      t.save
    end
    redirect_to buildings_path
  end

  private

  def building_params
    params.require(:building).permit(
      :name,
      :address,
      :number_of_flat,
      :company_id
    )
  end

  def set_building
    @building = Building.find(params[:id])
  end

end
