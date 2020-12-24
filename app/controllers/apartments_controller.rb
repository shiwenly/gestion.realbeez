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
      # Paramters for Filter
      if params[:search] == nil || params[:search][:company] == "Toutes les sociétés"
        # Companies and Buildings list for filter
        authorize @buildings = policy_scope(Building.where("statut = ?", "active" ).order(created_at: :asc))
        @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
        @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
        @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
        @companies_array = ["Toutes les sociétés", "n/a - détention en nom propre"]
        @companies = []
        @buildings_array = ["Tous les immeubles", "n/a - aucun immeuble"]
        @buildings = []
        @companies_active.each do |c|
          associe = c.associe.downcase.split(",").map(&:strip)
          if associe.include?(current_user.email) || c.user == current_user
            @companies << c
            @companies_array << c.name
          end
        end
        @companies.each do |c|
          @buildings_active.each do |b|
            if b.company_name == c.name
              @buildings_array << b.name
              @buildings << b
            end
          end
        end
        @buildings_active.each do |b|
          if b.user == current_user
            if @buildings_array.include?(b.name) == false
              @buildings_array << b.name
              @buildings << b
            end
          end
        end
      else
        # Companies and Buildings list for filter
        authorize @buildings = policy_scope(Building.where("statut = ?", "active" ).order(created_at: :asc))
        @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
        @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
        @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
        @companies_array = ["Toutes les sociétés", "n/a - détention en nom propre"]
        @companies = []
        @buildings_array = ["Tous les immeubles", "n/a - aucun immeuble"]
        @buildings = []
        @companies_active.each do |c|
          associe = c.associe.downcase.split(",").map(&:strip)
          if associe.include?(current_user.email) || c.user == current_user
            @companies << c
            @companies_array << c.name
          end
        end
        @buildings_active.each do |b|
          if b.company_name == params[:search][:company]
            @buildings_array << b.name
            @buildings << b
          end
        end
      end
      # ------- Result of selection -------------
      if params[:search] == nil || (params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles")
        # List of companies created by user or where user is an associate
        @companies_list = []
        @companies_active.each do |c|
          associe = c.associe.downcase.split(",").map(&:strip)
          if associe.include?(current_user.email) || c.user == current_user
            @companies_list << c
          end
        end
        @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
        @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
        @buildings_list = []
        @apartments_list = []
        @companies_list.each do |c|
          # List of buildings in companies of user
          @buildings_active.each do |b|
            if b.company_name == c.name
              @buildings_list << b
            end
          end
          # List of apartment in companies of user
          @apartments_active.each do |a|
            if a.company_name == c.name
              @apartments_list << a
            end
          end
        end
        # List of buildings created by user
        @buildings_active.each do |b|
          if b.user == current_user
            if @buildings_list.include?(b.name) == false
              @buildings_list << b
            end
          end
        end
        # list of apartments created by the user
        @apartments_active.each do |a|
          if a.user == current_user
            if @apartments_list.include?(a) == false
              @apartments_list << a
            end
          end
        end
        # List of appartements in buildings of user
        @buildings_list.each do |b|
          @apartments_active.each do |a|
            if a.building_name == b.name
              if @apartments_list.include?(a) == false
                @apartments_list << a
              end
            end
          end
        end
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles"
        @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
        @apartments_list = @apartments_active.select{ |a| a.company_name == params[:search][:company] }
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "n/a - aucun immeuble"
        @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
        @apartments_list = @apartments_active.select{ |a| a.company_name == params[:search][:company] && a.building_name == "n/a - aucun immeuble" }
      else
        authorize @apartments_list = Apartment.search_by_building(params[:search][:building])
      end
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
      # List of buildings détenu en nom propre
      @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
      @buildings = []
      @companies.each do |c|
        @buildings_active.each do |b|
          if @buildings.include?(b) == false
            if b.company_name == "n/a - détention en nom propre"
              @buildings << b
            end
          end
        end
      end
    end
  end

  def create
    authorize @apartment = Apartment.new(apartment_params)
    # @building = Building.find(params[:building_id])
    unless @apartment.company_id == nil || @apartment.company_id == ""
      @apartment.company_name = Company.find(@apartment.company_id).name
    else
      @apartment.company_name = "n/a - détention en nom propre"
    end
    unless @apartment.building_id == nil || @apartment.building_id == ""
      @apartment.building_name = Building.find(@apartment.building_id).name
    else
      @apartment.building_name = "n/a - aucun immeuble"
    end
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
    # List of buildings of company chosen
    @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
    @buildings = []
    @companies.each do |c|
      @buildings_active.each do |b|
        if @buildings.include?(b) == false
          if b.company_name == @apartment.company_name
            @buildings << b
          end
        end
      end
    end
  end

  def update
    authorize @apartment
    unless params[:apartment][:company_id] == nil || params[:apartment][:company_id] == ""
      @apartment.company_name = Company.find(params[:apartment][:company_id]).name
    else
      @apartment.company_name = "n/a - détention en nom propre"
    end
    unless params[:apartment][:building_id] == nil || params[:apartment][:building_id] == ""
      @apartment.building_name = Building.find(params[:apartment][:building_id]).name
    else
      @apartment.building_name = "n/a - aucun immeuble"
    end
    if @apartment.update(apartment_params)
      # Update all tenants in the apartment
      @tenants = Tenant.where("apartment_id = ?", @apartment)
      @tenants.each do |t|
        unless @apartment.building_id == nil || @apartment.building_id == ""
          t.building_name = Building.find(@apartment.building_id).name
          t.building_id = Building.find(@apartment.building_id).id
        else
          t.building_name = "n/a - aucun immeuble"
          t.building_id = nil
        end
        unless @apartment.company_id == nil || @apartment.company_id == ""
          t.company_name = Company.find(@apartment.company_id).name
          t.company_id = Company.find(@apartment.company_id).id
        else
          t.company_name = "n/a - détention en nom propre"
          t.company_id = nil
        end
        t.save
      end
      redirect_to apartments_path
    else
      render :edit
    end
  end

  def destroy
    authorize @apartment
    @apartment.name = @apartment.name+" deleted #{@apartment.id}"
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
