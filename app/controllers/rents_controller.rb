class RentsController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_rent, only: [:edit, :show, :update, :destroy]

  def index
    @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
    @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
    @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
    @tenants_active = Tenant.where("statut = ?", "active" ).order(created_at: :asc)
    @companies_list = []
    @buildings_list = []
    @apartments_list = []
    @tenants_list = []
    @years = [Date.today.year-3, Date.today.year-2, Date.today.year-1, Date.today.year, Date.today.year+1, Date.today.year+2]
    # List of companies created by user or where user is an associate
    @companies_active.each do |c|
      associe = c.associe.downcase.split(",").map(&:strip)
      if associe.include?(current_user.email) || c.user == current_user
        @companies_list << c
      end
    end
    # ------------- Filter -------------
    if params[:search] == nil || params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles"
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
        # List of tenants in companies of user
        @tenants_active.each do |t|
          if t.company_name == c.name
            @tenants_list << t
          end
        end
      end
      # List of buildings created by user
      @buildings_active.each do |b|
        if b.user == current_user
          if @buildings_list.include?(b) == false
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
      # list of tenants created by the user
      @tenants_active.each do |t|
        if t.user == current_user
          if @tenants_list.include?(t) == false
            @tenants_list << t
          end
        end
      end
      @buildings_list.each do |b|
        # List of appartements in buildings of user
        @apartments_active.each do |a|
          if a.building_name == b.name
            if @apartments_list.include?(a) == false
              @apartments_list << a
            end
          end
        end
        # List of tenants in buildings of user
        @tenants_active.each do |t|
          if t.building_name == b.name
            if @tenants_list.include?(t) == false
              @tenants_list << t
            end
          end
        end
      end
      # List of tenant in apartment of user
      @apartments_list.each do |a|
        @tenants_active.each do |t|
          if t.building_name == a.name
            if @tenants_list.include?(t) == false
              @tenants_list << t
            end
          end
        end
      end
    elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles"
      @companies_list.each do |c|
        # List of buildings in companies of user
        @buildings_active.each do |b|
          if b.company_name == c.name
            @buildings_list << b
          end
        end
      end
      # List of buildings created by user
      @buildings_active.each do |b|
        if b.user == current_user
          if @buildings_list.include?(b) == false
            @buildings_list << b
          end
        end
      end
      @tenants_list = @tenants_active.select{ |t| t.building_name == params[:search][:building]}
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles"
      @buildings_list = @buildings_active.select{ |b| b.company_name == params[:search][:company]}
      @tenants_list = @tenants_active.select{ |t| t.company_name == params[:search][:company] && t.building_name == params[:search][:building]}
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles"
      @buildings_list = @buildings_active.select{ |b| b.company_name == params[:search][:company]}
      @tenants_list = @tenants_active.select{ |t| t.company_name == params[:search][:company]}
    end
    # =========== Sort tenant list by alphabetic order ==========
    @tenants = @tenants_list.sort_by { |t| t.last_name }
    @tenants_array = ["Tous les locataires"]
    @tenants.each do |t|
      @tenants_array << t.name
    end
    # Company array
    @companies = @companies_list.sort_by { |c| c.name }
    @companies_array = ["Toutes les sociétés", "n/a - détention en nom propre"]
    @companies.each do |c|
      @companies_array << c.name
    end
    # Building array
    @buildings = @buildings_list.sort_by { |b| b.name }
    @buildings_array = ["Tous les immeubles", "n/a - aucun immeuble"]
    @buildings.each do |b|
      if @buildings_array.include?(b.name) == false
        @buildings_array << b.name
      end
    end
    # --------- Result of selection -----------
    @rents_active = Rent.where("statut = ?", "active" ).order(created_at: :asc)
    # If params is nil
    if params[:search] == nil || params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:tenant] == "Tous les locataires"
      @rents = policy_scope(Rent.all)
      @rents_list_unsorted = []
      # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      @tenants.each do |t|
        @rents_active.each do |r|
          if r.name == t.name
            @rents_list_unsorted << r
          end
        end
      end
      # if params = Tous companies/immeuble/locataires
      # elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:tenant] == "Tous les locataires"
      #   @rents = policy_scope(Rent.all)
      #   @rents_list_unsorted = []
      #   # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      #   @tenants.each do |t|
      #     @rents_active.each do |r|
      #       if r.name == t.name
      #         @rents_list_unsorted << r
      #       end
      #     end
      #   end
      # @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.name, b.period] }
      # @rents_list = []
      # @rents_sorted.each do |r|
      #   if r.period.strftime("%Y").to_i == params[:search][:year].to_i
      #     @rents_list << r
      #   end
      # end
      # if params not toutes les sociétés + tous immeubles/locataires
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:tenant] == "Tous les locataires"
      @rents = policy_scope(Rent.all)
      @rents_list_unsorted = []
      # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      @tenants.each do |t|
        if t.company_name == params[:search][:company]
          @rents_active.each do |r|
            if r.name == t.name
              @rents_list_unsorted << r
            end
          end
        end
      end
      # @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.name, b.period] }
      # @rents_list = []
      # @rents_sorted.each do |r|
      #   if r.period.strftime("%Y") == params[:search][:year]
      #     @rents_list << r
      #   end
      # end
      # if not tous immeubles + tous locataires
    elsif params[:search][:building] != "Tous les immeubles" && params[:search][:tenant] == "Tous les locataires"
      @rents = policy_scope(Rent.all)
      @rents_list_unsorted = []
      # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      @tenants.each do |t|
        if t.building_name == params[:search][:building]
          @rents_active.each do |r|
            if r.name == t.name
              @rents_list_unsorted << r
            end
          end
        end
      end
      # @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.name, b.period] }
      # @rents_list = []
      # @rents_sorted.each do |r|
      #   if r.period.strftime("%Y") == params[:search][:year]
      #     @rents_list << r
      #   end
      # end
    else
      @tenants_list
      @rents = policy_scope(Rent.all)
      @rents_list_unsorted = policy_scope(Rent.search_by_tenant(params[:search][:tenant]))
    end
    # ------------------ Filter by date -----------------
    if params[:search] == nil
      @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.tenant.last_name, b.period] }
      @rents_list = []
      @rents_sorted.each do |r|
        if r.date_payment.strftime("%Y").to_i == Date.today.year
          @rents_list << r
        end
      end
    else
      @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.tenant.last_name, b.period] }
      @rents_list = []
      @rents_sorted.each do |r|
        if r.date_payment.strftime("%Y") == params[:search][:year]
          @rents_list << r
        end
      end
    end
    @rent_list = @rents_list.sort_by{ |r| [r.period, r.name] }
    # if params[:search] == nil
    #   @expenses_unorder = Expense.search_by_date_expense(Date.today.year)
    #   @expenses = @expenses_unorder.select{|a| a.statut == "active" && a.building_id == @building.id}.sort_by { |b| b.date }
    #   @sum_ttc = @expenses.map{|a| a.amount_ttc}.sum
    #   @sum_vat = @expenses.map{|a| a.amount_vat}.sum
    # else
    #   @expenses_unorder = Expense.search_by_date_expense(params[:search][:date].to_i)
    #   @expenses = @expenses_unorder.select{|a| a.statut == "active" && a.building_id == @building.id}.sort_by { |b| b.date }
    #   @sum_ttc = @expenses.map{|a| a.amount_ttc}.sum
    #   @sum_vat = @expenses.map{|a| a.amount_vat}.sum
    # end
    @sum_rent_ask = @rents_list.map{|a| a.rent_ask}.sum
    @sum_service_charge_ask = @rents_list.map{|a| a.service_charge_ask}.sum
    @sum_rent_paid = @rents_list.map{|a| a.rent_paid}.sum
    @sum_service_charge_paid = @rents_list.map{|a| a.service_charge_paid}.sum
    @solde = (@sum_rent_paid + @sum_service_charge_paid) - (@sum_rent_ask + @sum_service_charge_ask)
  end

  def show
    authorize @rent
  end

  def new
    if params[:tenant_id] != nil
      authorize @rent = Rent.new
      @tenant = Tenant.find(params[:tenant_id])
    else
      authorize @rent = Rent.new
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
      @buildings = ["n/a - aucun immeuble"]
      # @companies.each do |c|
      @buildings_active.each do |b|
        if @buildings.include?(b) == false
          if b.company_name == "n/a - détention en nom propre"
            @buildings << b.name
          end
        end
      end
      # end
      # List of apartment détenu en nom propre in aucun immeuble
      @tenants_active = Tenant.where("statut = ?", "active" ).order(created_at: :asc)
      @tenants_list = []
      @tenants_active.each do |t|
        if @tenants_list.include?(t) == false
          if t.building_name == "n/a - aucun immeuble" && t.company_name == "n/a - détention en nom propre"
            @tenants_list << t
          end
        end
      end
      # List of companies created by user or where user is an associate
      # @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
      # @companies_list = []
      # @companies_active.each do |c|
      #   associe = c.associe.downcase.split(",").map(&:strip)
      #   if associe.include?(current_user.email) || c.user == current_user
      #     @companies_list << c
      #   end
      # end
      # @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
      # @tenants_active = Tenant.where("statut = ?", "active" ).order(created_at: :asc)
      # @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
      # @buildings_list = []
      # @apartments_list = []
      # @tenants_list = []
      # @companies_list.each do |c|
      #   # List of buildings in companies of user
      #   @buildings_active.each do |b|
      #     if b.company_name == c.name
      #       @buildings_list << b
      #     end
      #   end
      #   # List of apartment in companies of user
      #   @apartments_active.each do |a|
      #     if a.company_name == c.name
      #       @apartments_list << a
      #     end
      #   end
      #   # List of tenants in companies of user
      #   @tenants_active.each do |t|
      #     if t.company_name == c.name
      #       @tenants_list << t
      #     end
      #   end
      # end
      # # List of buildings created by user
      # @buildings_active.each do |b|
      #   if b.user == current_user
      #     if @buildings_list.include?(b) == false
      #       @buildings_list << b
      #     end
      #   end
      # end
      # # list of apartments created by the user
      # @apartments_active.each do |a|
      #   if a.user == current_user
      #     if @apartments_list.include?(a) == false
      #       @apartments_list << a
      #     end
      #   end
      # end
      # # list of tenants created by the user
      # @tenants_active.each do |t|
      #   if t.user == current_user
      #     if @tenants_list.include?(t) == false
      #       @tenants_list << t
      #     end
      #   end
      # end
      # @buildings_list.each do |b|
      #   # List of appartements in buildings of user
      #   @apartments_active.each do |a|
      #     if a.building_name == b.name
      #       if @apartments_list.include?(a) == false
      #         @apartments_list << a
      #       end
      #     end
      #   end
      #   # List of tenants in buildings of user
      #   @tenants_active.each do |t|
      #     if t.building_name == b.name
      #       if @tenants_list.include?(t) == false
      #         @tenants_list << t
      #       end
      #     end
      #   end
      # end
      # # List of tenant in apartment of user
      # @apartments_list.each do |a|
      #   @tenants_active.each do |t|
      #     if t.building_name == a.name
      #       if @tenants_list.include?(t) == false
      #         @tenants_list << t
      #       end
      #     end
      #   end
      # end
      @tenants = @tenants_list.sort_by { |b| b.last_name }
    end
  end

  def create
    authorize @rent = Rent.new(rent_params)
    # @tenant = Tenant.find(params[:tenant_id])
    # @rent.tenant = Tenant.find(params[:s])
    @rent.user_id = current_user.id
    if @rent.tenant_id != nil
      @rent.name = Tenant.find(@rent.tenant_id).name
    end
    @rent.statut = "active"
    if @rent.save
      redirect_to rents_path
    else
      render :new
    end
  end

  def edit
    authorize @rent
    if params[:tenant_id] != nil
      @tenant = Tenant.find(params[:tenant_id])
    else
      # List of companies of the user and where user is an associate
      @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
      @companies = ["n/a - détention en nom propre"]
      @companies_active.each do |c|
        associe = c.associe.downcase.split(",").map(&:strip)
        if associe.include?(current_user.email) || c.user == current_user
          @companies << c.name
        end
      end
      # List of buildings détenu en nom propre
      @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
      @buildings = ["n/a - aucun immeuble"]
      # @companies.each do |c|
      @buildings_active.each do |b|
        if @buildings.include?(b.name) == false
          if b.company_name == @rent.tenant.company_name
            @buildings << b.name
          end
        end
      end
      # end
      # List of apartment détenu en nom propre in aucun immeuble
      @tenants_active = Tenant.where("statut = ?", "active" ).order(created_at: :asc)
      @tenants_list = []
      @tenants_active.each do |t|
        if @tenants_list.include?(t) == false
          if t.building_name == @rent.tenant.building_name && t.company_name == @rent.tenant.company_name
            @tenants_list << t
          end
        end
      end
      @tenants = @tenants_list.sort_by { |b| b.last_name }
    end
  end

  def update
    authorize @rent
    @rent.name = Tenant.find(params[:rent][:tenant_id]).name
    if @rent.update(rent_params)
      redirect_to rents_path
    else
      render :edit
    end
  end

  def destroy
    authorize @rent
    @rent.statut = "deleted"
    @rent.save
    redirect_to rents_path
  end

  private

  def rent_params
    params.require(:rent).permit(
      :period,
      :rent_ask,
      :service_charge_ask,
      :rent_paid,
      :service_charge_paid,
      :date_payment,
      :tenant_id
    )
  end

  def set_rent
    @rent = Rent.find(params[:id])
  end
end
