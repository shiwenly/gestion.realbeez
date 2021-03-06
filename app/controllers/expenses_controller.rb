class ExpensesController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_expense, only: [:edit, :show, :update, :destroy]

  def index
    @companies_active = Company.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
    @buildings_active = Building.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
    @apartments_active = Apartment.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
    @tenants_active = Tenant.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
    @companies_list = @companies_active
    @years = [Date.today.year-3, Date.today.year-2, Date.today.year-1, Date.today.year, Date.today.year+1, Date.today.year+2]
    @tenants_list = @tenants_active
    # List of companies created by user or where user is an associate
    # @companies_active.each do |c|
    #   associe = c.associe.downcase.split(",").map(&:strip)
    #   if associe.include?(current_user.email) || c.user == current_user
    #     @companies_list << c
    #   end
    # end
    # ------------- Filter -------------
    if params[:search] == nil || params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles"
      @buildings_list = @buildings_active
      @apartments_list = @apartments_active

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
    elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles"
      @buildings_list = @buildings_active
      @apartments_list = @apartments_active.select{ |t| t.building_name == params[:search][:building]}
      # @companies_list.each do |c|
      #   # List of buildings in companies of user
      #   @buildings_active.each do |b|
      #     if b.company_name == c.name
      #       @buildings_list << b
      #     end
      #   end
      # end
      # List of buildings created by user
      # @buildings_active.each do |b|
      #   if b.user == current_user
      #     if @buildings_list.include?(b) == false
      #       @buildings_list << b
      #     end
      #   end
      # end
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles"
      @buildings_list = @buildings_active.select{ |b| b.company_name == params[:search][:company]}
      @apartments_list = @apartments_active.select{ |t| t.company_name == params[:search][:company] && t.building_name == params[:search][:building]}
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles"
      @buildings_list = @buildings_active.select{ |b| b.company_name == params[:search][:company]}
      @apartments_list = @apartments_active.select{ |t| t.company_name == params[:search][:company]}
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
    # Appartment array
    @apartments = @apartments_list.sort_by { |a| a.name }
    @apartments_array = ["Tous les appartements"]
    @apartments.each do |a|
      if @apartments_array.include?(a.name) == false
        @apartments_array << a.name
      end
    end
    # @expenses = policy_scope(Expense.where("statut = ?", "active").order(created_at: :asc))

    # --------- Result of selection -----------
    @expenses_active = Expense.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
    @expenss = policy_scope(Expense.all)
    # If params is nil
    if params[:search] == nil || params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
      @expenses_list_unsorted = @expenses_active
      # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      # @apartments.each do |t|
      #   @expenses_active.each do |r|
      #     if r.apartment_name == t.name
      #       if @expenses_list_unsorted.include?(r) == false
      #         @expenses_list_unsorted << r
      #       end
      #     end
      #   end
      # end
      # @buildings.each do |t|
      #   @expenses_active.each do |r|
      #     if r.building_name == t.name
      #       if @expenses_list_unsorted.include?(r) == false
      #         @expenses_list_unsorted << r
      #       end
      #     end
      #   end
      # end
      # @companies.each do |t|
      #   @expenses_active.each do |r|
      #     if r.company_name == t.name
      #       if @expenses_list_unsorted.include?(r) == false
      #         @expenses_list_unsorted << r
      #       end
      #     end
      #   end
      # end
      # @expenses_active.each do |r|
      #   if r.user == current_user
      #     if @expenses_list_unsorted.include?(r) == false
      #       @expenses_list_unsorted << r
      #     end
      #   end
      # end
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| [b.date] }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y").to_i == Date.today.year
      #     @expenses_list << r
      #   end
      # end
      # if params = Tous companies/immeuble/locataires
      # elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
      #   @expenss = policy_scope(Expense.all)
      #   @expenses_list_unsorted = []
      #   # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      #   @apartments.each do |t|
      #     @expenses_active.each do |r|
      #       if r.apartment_name == t.name
      #         if @expenses_list_unsorted.include?(r) == false
      #           @expenses_list_unsorted << r
      #         end
      #       end
      #     end
      #   end
      #   @buildings.each do |t|
      #     @expenses_active.each do |r|
      #       if r.building_name == t.name
      #         if @expenses_list_unsorted.include?(r) == false
      #           @expenses_list_unsorted << r
      #         end
      #       end
      #     end
      #   end
      #   @companies.each do |t|
      #     @expenses_active.each do |r|
      #       if r.company_name == t.name
      #         if @expenses_list_unsorted.include?(r) == false
      #           @expenses_list_unsorted << r
      #         end
      #       end
      #     end
      #   end
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| [b.date] }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y") == params[:search][:year]
      #     @expenses_list << r
      #   end
      # end
      # if params not toutes les sociétés + tous immeubles/locataires
    elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
      @expenses_list_unsorted = @expenses_active.select{ |e| e.building_name == params[:search][:building]}
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y") == params[:search][:year]
      #     @expenses_list << r
      #   end
      # end
    elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] != "Tous les appartements"
      @expenses_list_unsorted = @expenses_active.select{ |e| e.apartment_name == params[:search][:apartment]}
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y") == params[:search][:year]
      #     @expenses_list << r
      #   end
      # end
    elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles" && params[:search][:apartment] != "Tous les appartements"
      @expenses_list_unsorted = @expenses_active.select{ |e| e.building_name == params[:search][:building] && e.apartment_name == params[:search][:apartment]}
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y") == params[:search][:year]
      #     @expenses_list << r
      #   end
      # end
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles" && params[:search][:apartment] != "Tous les appartements"
      @expenses_list_unsorted = @expenses_active.select{ |e| e.company_name == params[:search][:company] && e.building_name == params[:search][:building] && e.apartment_name == params[:search][:apartment]}
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y") == params[:search][:year]
      #     @expenses_list << r
      #   end
      # end
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
      @expenses_list_unsorted = @expenses_active.select{ |e| e.company_name == params[:search][:company]}
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y") == params[:search][:year]
      #     @expenses_list << r
      #   end
      # end
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
      @expenses_list_unsorted = @expenses_active.select{ |e| e.company_name == params[:search][:company] && e.building_name == params[:search][:building]}
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y") == params[:search][:year]
      #     @expenses_list << r
      #   end
      # end
    elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] != "Tous les appartements"
      @expenses_list_unsorted = @expenses_active.select{ |e| e.company_name == params[:search][:company] && e.apartment_name == params[:search][:apartment]}
      # @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
      # @expenses_list = []
      # @expenses_sorted.each do |r|
      #   if r.date.strftime("%Y") == params[:search][:year]
      #     @expenses_list << r
      #   end
      # end
      # if not tous immeubles + tous locataires
      # elsif params[:search][:building] != "Tous les immeubles" && params[:search][:tenant] == "Tous les locataires"
      #   @rents = policy_scope(Rent.all)
      #   @rents_list_unsorted = []
      #   # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      #   @tenants.each do |t|
      #     if t.building_name == params[:search][:building]
      #       @rents_active.each do |r|
      #         if r.name == t.name
      #           @rents_list_unsorted << r
      #         end
      #       end
      #     end
      #   end
      # @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.name, b.period] }
      # @rents_list = []
      # @rents_sorted.each do |r|
      #   if r.period.strftime("%Y") == params[:search][:year]
      #     @rents_list << r
      #   end
      # end
      # else
      #   @tenants_list
      #   @rents = policy_scope(Rent.all)
      #   @rents_list_unsorted = policy_scope(Rent.search_by_tenant(params[:search][:tenant]))
      #   @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.name, b.period] }
      #   @rents_list = []
      #   @rents_sorted.each do |r|
      #     if r.period.strftime("%Y") == params[:search][:year]
      #       @rents_list << r
      #     end
      #   end
    end
    if @expenses_list_unsorted != nil
      if params[:search] != nil
        @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
        @expenses_list = []
        @expenses_sorted.each do |r|
          if r.date.strftime("%Y") == params[:search][:year]
            @expenses_list << r
          end
        end
      else
        @expenses_sorted = @expenses_list_unsorted.sort_by { |b| b.date }
        @expenses_list = []
        @expenses_sorted.each do |r|
          if r.date.strftime("%Y").to_i == Date.today.year
            @expenses_list << r
          end
        end
      end
    end
    # ========== Sum calculation ==============
    # if params[:search] == nil
    #   @expenses_unorder = Expense.search_by_date_expense(Date.today.year)
    #   @expenses = @expenses_unorder.select{|a| a.statut == "active" && a.building_id == @building.id}.sort_by { |b| b.date }
    #   @sum_ttc = @expenses.map{|a| a.amount_ttc}.sum
    #   @sum_vat = @expenses.map{|a| a.amount_vat}.sum
    # else
    #   @expenses_unorder = Expense.search_by_date_expense(params[:search][:date].to_i)
    #   @expenses = @expenses_unorder.select{|a| a.statut == "active" && a.building_id == @building.id}.sort_by { |b| b.date }
    #   @sum_vat = @expenses.map{|a| a.amount_vat}.sum
    # end
    @sum_vat = @expenses_list.map{|a| a.amount_vat}.sum
    @sum_ttc = @expenses_list.map{|a| a.amount_ttc}.sum
  end

  def show
    authorize @expense

  end

  def new
    authorize @expense = Expense.new
    if params[:building_id] != nil
      @building = Building.find(params[:building_id])
      @apartment_name = ["Tous"]
      @apartments_name = @building.apartments.each do |apartment|
        if apartment.statut == "active"
          @apartment_name  << apartment.name.to_s
        end
      end
    else
      # List of companies of the user and where user is an associate
      @companies = Company.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
      # @companies = []
      # @companies_active.each do |c|
      #   associe = c.associe.downcase.split(",").map(&:strip)
      #   if associe.include?(current_user.email) || c.user == current_user
      #     @companies << c
      #   end
      # end
      # List of buildings détenu en nom propre
      @buildings = Building.where("statut = ? AND user_id = ? AND company_name = ?", "active", current_user.id, "n/a - détention en nom propre" ).order(created_at: :asc)
      # @buildings = []
      # @companies.each do |c|
      # @buildings_active.each do |b|
      #   if @buildings.include?(b) == false
      #     if b.company_name == "n/a - détention en nom propre"
      #       @buildings << b
      #     end
      #   end
      # end
      # end
      # List of apartment détenu en nom propre in aucun immeuble
      @apartments = Apartment.where("statut = ? AND user_id = ? AND building_name = ? AND company_name = ?", "active", current_user.id, "n/a - aucun immeuble", "n/a - détention en nom propre" ).order(name: :asc)
      # @apartments = @apartments_list.sort_by { |b| b.name }
      # @apartments_list = []
      # @apartments_active.each do |t|
      #   if @apartments_list.include?(t) == false
      #     if t.building_name == "n/a - aucun immeuble" && t.company_name == "n/a - détention en nom propre"
      #       @apartments_list << t
      #     end
      #   end
      # end
    end
  end

  def create
    authorize @expense = Expense.new(expense_params)
    # @building = Building.find(params[:building_id])
    # @expense.building = @building
    unless @expense.company_id == nil || @expense.company_id == "" || @expense.company_id == 0
      @expense.company_name = Company.find(@expense.company_id).name
    else
      @expense.company_name = "n/a - détention en nom propre"
    end
    unless @expense.building_id == nil || @expense.building_id == "" || @expense.building_id == 0
      @expense.building_name = Building.find(@expense.building_id).name
    else
      @expense.building_name = "n/a - aucun immeuble"
    end
    unless @expense.apartment_id == nil || @expense.apartment_id == "" || @expense.apartment_id == 0
      @expense.apartment_name = Apartment.find(@expense.apartment_id).name
    else
      @expense.apartment_name = "Tous les appartements"
    end
    @expense.user_id = current_user.id
    @expense.statut = "active"
    if @expense.save
      redirect_to expenses_path
    else
      render :new
    end
  end

  def edit
    authorize @expense
    if params[:building_id] != nil
      @apartment_name = ["Tous"]
      @apartments_name = @expense.building.apartments.each do |apartment|
        if apartment.statut == "active"
          @apartment_name  << apartment.name.to_s
        end
      end
    else
      # List of companies of the user and where user is an associate
      @companies = Company.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
      # @companies = []
      # @companies_active.each do |c|
      #   associe = c.associe.downcase.split(",").map(&:strip)
      #   if associe.include?(current_user.email) || c.user == current_user
      #     @companies << c
      #   end
      # end
      # List of buildings
      @buildings = Building.where("statut = ? AND user_id = ? AND company_name = ?" , "active", current_user.id, @expense.company_name ).order(created_at: :asc)
      # @buildings = []
      # # @companies.each do |c|
      # @buildings_active.each do |b|
      #   if @buildings.include?(b) == false
      #     if b.company_name == @expense.company_name
      #       @buildings << b
      #     end
      #   end
      # end
      # end
      # List of apartments
      @apartments = Apartment.where("statut = ? AND user_id = ? AND building_name = ? AND company_name = ?", "active", current_user.id, @expense.building_name, @expense.company_name ).order(name: :asc)
      # @apartments_list = []
      # @apartments_active.each do |t|
      #   if @apartments_list.include?(t) == false
      #     if t.building_name == @expense.building_name && t.company_name == @expense.company_name
      #       @apartments_list << t
      #     end
      #   end
      # end
      # @apartments = @apartments_list.sort_by { |b| b.name }
    end
  end

  def update
    authorize @expense
    unless params[:expense][:company_id] == nil || params[:expense][:company_id] == "" || params[:expense][:company_id] == 0
      @expense.company_name = Company.find(params[:expense][:company_id]).name
    else
      @expense.company_name = "n/a - détention en nom propre"
    end
    unless params[:expense][:building_id] == nil || params[:expense][:building_id] == "" || params[:expense][:building_id] == 0
      @expense.building_name = Building.find(params[:expense][:building_id]).name
    else
      @expense.building_name = "n/a - aucun immeuble"
    end
    unless params[:expense][:apartment_id] == nil || params[:expense][:apartment_id] == "" || params[:expense][:apartment_id] == 0
      @expense.apartment_name = Apartment.find(params[:expense][:apartment_id]).name
    else
      @expense.apartment_name = "Tous les appartements"
    end
    if @expense.update(expense_params)
      redirect_to expenses_path
    else
      render :edit
    end
  end

  def destroy
    authorize @expense
    @expense.statut = "deleted"
    @expense.save
    redirect_to expenses_path
  end

  private

  def expense_params
    params.require(:expense).permit(
      :apartment_id,
      :building_id,
      :company_id,
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
