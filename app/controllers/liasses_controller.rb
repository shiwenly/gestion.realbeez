class LiassesController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_liasse, only: [:edit, :show, :update, :destroy]

  def index
    if params[:building_id] != nil
      @building = Building.find(params[:building_id])
      @liasses = policy_scope(Liasse.where("statut = ? AND building_id = ?", "active", @building.id).order(year: :asc))
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
      end
    else
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
        @apartments_list = @apartments_active.select{ |t| t.building_name == params[:search][:building]}
        @tenants_list = @tenants_active.select{ |t| t.building_name == params[:search][:building]}
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles"
        @buildings_list = @buildings_active.select{ |b| b.company_name == params[:search][:company]}
        @apartments_list = @apartments_active.select{ |t| t.company_name == params[:search][:company] && t.building_name == params[:search][:building]}
        @tenants_list = @tenants_active.select{ |t| t.company_name == params[:search][:company] && t.building_name == params[:search][:building]}
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles"
        @buildings_list = @buildings_active.select{ |b| b.company_name == params[:search][:company]}
        @apartments_list = @apartments_active.select{ |t| t.company_name == params[:search][:company]}
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
      # Appartment array
      @apartments = @apartments_list.sort_by { |a| a.name }
      @apartments_array = ["Tous les appartements"]
      @apartments.each do |a|
        if @apartments_array.include?(a.name) == false
          @apartments_array << a.name
        end
      end
      @liasses = policy_scope(Liasse.all.order(year: :asc))
      # ================== Revenue (rent) ========================
      @rents_active = Rent.where("statut = ?", "active")
      @rent_paid = []
      if params[:search] == nil || params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
        @tenants.each do |t|
          @rents_active.each do |r|
            if t.name == r.name
              if @rent_paid.include?(r) == false
                @rent_paid << r
              end
            end
          end
        end
      elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
        @tenants_list = @tenants_active.select { |t| t.building_name == params[:search][:building]  }
        @tenants_list.each do |t|
          @rents_active.each do |r|
            if t.name == r.name
              if @rent_paid.include?(r) == false
                @rent_paid << r
              end
            end
          end
        end
      elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] != "Tous les appartements"
        @tenants_list = @tenants_active.select { |t| t.apartment_name == params[:search][:apartment]  }
        @tenants_list.each do |t|
          @rents_active.each do |r|
            if t.name == r.name
              if @rent_paid.include?(r) == false
                @rent_paid << r
              end
            end
          end
        end
      elsif params[:search][:company] == "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles" && params[:search][:apartment] != "Tous les appartements"
        @tenants_list = @tenants_active.select { |t| t.building_name == params[:search][:building] && t.apartment_name == params[:search][:apartment]  }
        @tenants_list.each do |t|
          @rents_active.each do |r|
            if t.name == r.name
              if @rent_paid.include?(r) == false
                @rent_paid << r
              end
            end
          end
        end
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles" && params[:search][:apartment] != "Tous les appartements"
        @tenants_list = @tenants_active.select { |t| t.company_name == params[:search][:company] && t.building_name == params[:search][:building] && t.apartment_name == params[:search][:apartment]  }
        @tenants_list.each do |t|
          @rents_active.each do |r|
            if t.name == r.name
              if @rent_paid.include?(r) == false
                @rent_paid << r
              end
            end
          end
        end
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
        @tenants_list = @tenants_active.select { |t| t.company_name == params[:search][:company] }
        @tenants_list.each do |t|
          @rents_active.each do |r|
            if t.name == r.name
              if @rent_paid.include?(r) == false
                @rent_paid << r
              end
            end
          end
        end
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] != "Tous les immeubles" && params[:search][:apartment] == "Tous les appartements"
        @tenants_list = @tenants_active.select { |t| t.company_name == params[:search][:company] && t.building_name == params[:search][:building] }
        @tenants_list.each do |t|
          @rents_active.each do |r|
            if t.name == r.name
              if @rent_paid.include?(r) == false
                @rent_paid << r
              end
            end
          end
        end
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles" && params[:search][:apartment] != "Tous les appartements"
        @tenants_list = @tenants_active.select { |t| t.company_name == params[:search][:company] && t.apartment_name == params[:search][:apartment]  }
        @tenants_list.each do |t|
          @rents_active.each do |r|
            if t.name == r.name
              if @rent_paid.include?(r) == false
                @rent_paid << r
              end
            end
          end
        end
      end
      # ---------filter by date and calculate sum---------
      if params[:search] != nil
        @rent_paid_unsorted = @rent_paid.select{ |a| a.period.strftime("%Y").to_i == params[:search][:year].to_i }.sort_by{ |b| b.date_payment}
        @sum_rent_paid = @rent_paid_unsorted.map{ |r| r.rent_paid}.sum
      else
        @rent_paid_unsorted = @rent_paid.select{ |a| a.period.strftime("%Y").to_i == Date.today.year }.sort_by{ |b| b.date_payment}
        @sum_rent_paid = @rent_paid_unsorted.map{ |r| r.rent_paid}.sum
      end
      # ================== ALL Expenses ========================
      @expenses_active = Expense.where("statut = ?", "active")
      @expenses_array = []
      @companies.each do |c|
        @expenses_active.each do |e|
          if c.name == e.company_name
            if @expenses_array.include?(e) == false
              @expenses_array << e
            end
          end
        end
      end
      @buildings.each do |b|
        @expenses_active.each do |e|
          if b.name == e.building_name
            if @expenses_array.include?(e) == false
              @expenses_array << e
            end
          end
        end
      end
      @apartments.each do |a|
        @expenses_active.each do |e|
          if a.name == e.apartment_name
            if @expenses_array.include?(e) == false
              @expenses_array << e
            end
          end
        end
      end
      @expenses_active.each do |e|
        if e.user == current_user
          if @expenses_array.include?(e) == false
            @expenses_array << e
          end
        end
      end
      @expenses_array = @expenses_array.sort_by { |e| e.date }
      @expenses = []
      if params[:search] != nil
        @expenses_array.each do |r|
          if r.date.strftime("%Y") == params[:search][:year]
            @expenses << r
          end
        end
      else
        @expenses_array.each do |r|
          if r.date.strftime("%Y").to_i == Date.today.year
            @expenses << r
          end
        end
      end
      @sum_ttc = @expenses.map{|a| a.amount_ttc}.sum
      @sum_vat = @expenses.map{|a| a.amount_vat}.sum
      # Assurance
      @assurance = @expenses.select{|a| a.expense_type == "Assurance" && a.deductible == true }
      @sum_assurance = @assurance.map{|a| a.amount_ttc}.sum
      # Eau
      @eau = @expenses.select{|a| a.expense_type == "Eau" && a.deductible == true}
      @sum_eau = @eau.map{|a| a.amount_ttc}.sum
      # Eléctricité
      @electricite = @expenses.select{|a| a.expense_type == "Eléctricité" && a.deductible == true}
      @sum_electricite = @electricite.map{|a| a.amount_ttc}.sum
      # Frais bancaire
      @frais_bancaire = @expenses.select{|a| a.expense_type == "Frais bancaire" && a.deductible == true}
      @sum_frais_bancaire = @frais_bancaire.map{|a| a.amount_ttc}.sum
      # Honoraire
      @honoraire = @expenses.select{|a| a.expense_type == "Honoraire de gestion" && a.deductible == true}
      @sum_honoraire = @honoraire.map{|a| a.amount_ttc}.sum
      # Frais de nettoyage
      @frais_nettoyage = @expenses.select{|a| a.expense_type == "Frais de nettoyage" && a.deductible == true}
      @sum_frais_nettoyage = @frais_nettoyage.map{|a| a.amount_ttc}.sum
      # Maintenance chaudiere
      @maintenance_chaudiere = @expenses.select{|a| a.expense_type == "Maintenance chaudière" && a.deductible == true}
      @sum_maintenance_chaudiere = @maintenance_chaudiere.map{|a| a.amount_ttc}.sum
      # Remplacement chaudiere
      @remplacement_chaudiere = @expenses.select{|a| a.expense_type == "Remplacement chaudière" && a.deductible == true}
      @sum_remplacement_chaudiere = @remplacement_chaudiere.map{|a| a.amount_ttc}.sum
      # Réparation
      @reparation = @expenses.select{|a| a.expense_type == "Réparation, entretien et amélioration" && a.deductible == true}
      @sum_reparation = @reparation.map{|a| a.amount_ttc}.sum
      # Inreret
      @interet = @expenses.select{|a| a.expense_type == "Intérêt d'emprunt" && a.deductible == true}
      @sum_interet = @interet.map{|a| a.amount_ttc}.sum
      # Taxe
      @taxe = @expenses.select{|a| a.expense_type == "Taxe foncière" && a.deductible == true}
      @sum_taxe = @taxe.map{|a| a.amount_ttc}.sum
      # Notaire
      @notaire = @expenses.select{|a| a.expense_type == "Frais de notaire" && a.deductible == true}
      @sum_notaire = @notaire.map{|a| a.amount_ttc}.sum
      # Frais de dossier et caution
      @dossier = @expenses.select{|a| a.expense_type == "Frais de dossiers et caution" && a.deductible == true}
      @sum_dossier = @dossier.map{|a| a.amount_ttc}.sum
      # Charge non payé
      @non_paye = @expenses.select{|a| a.expense_type == "Charges non payées au départ du locataire" && a.deductible == true}
      @sum_non_paye = @non_paye.map{|a| a.amount_ttc}.sum
      # Frais admin
      @frais_admin = @sum_frais_bancaire + @sum_honoraire + @sum_dossier
      # Autre frais non deductible
      # @autre_frais_non_deductible = 20 * @building.number_of_flat
      @autre_frais_non_deductible = 20
      # Depense de réparataion
      @depense_de_reparation = @sum_frais_nettoyage + @sum_remplacement_chaudiere + @sum_reparation
      # Total deduction
      @total_deduction = @frais_admin + @autre_frais_non_deductible + @depense_de_reparation + @sum_assurance + @sum_taxe + @sum_non_paye
      # Total revenus
      @revenus = @sum_rent_paid - @total_deduction - @sum_interet
    end
  end

  def show
    authorize @liasse
    @building = @liasse.building
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
            @rents_unorder = Rent.search_by_date(@liasse.year.strftime("%Y").to_i)
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
    end
    # Expense
    # @expenses = policy_scope(Expense.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
    @expenses_unorder = Expense.search_by_date_expense(@liasse.year.strftime("%Y").to_i)
    @expenses = @expenses_unorder.select{|a| a.statut == "active" && a.building_id == @building.id}.sort_by { |b| b.date }
    @sum_ttc = @expenses.map{|a| a.amount_ttc}.sum
    @sum_vat = @expenses.map{|a| a.amount_vat}.sum
    # Assurance
    @assurance = @expenses.select{|a| a.expense_type == "Assurance" && a.deductible == true }
    @sum_assurance = @assurance.map{|a| a.amount_ttc}.sum
    # Eau
    @eau = @expenses.select{|a| a.expense_type == "Eau" && a.deductible == true}
    @sum_eau = @eau.map{|a| a.amount_ttc}.sum
    # Eléctricité
    @electricite = @expenses.select{|a| a.expense_type == "Eléctricité" && a.deductible == true}
    @sum_electricite = @electricite.map{|a| a.amount_ttc}.sum
    # Frais bancaire
    @frais_bancaire = @expenses.select{|a| a.expense_type == "Frais bancaire" && a.deductible == true}
    @sum_frais_bancaire = @frais_bancaire.map{|a| a.amount_ttc}.sum
    # Honoraire
    @honoraire = @expenses.select{|a| a.expense_type == "Honoraire de gestion" && a.deductible == true}
    @sum_honoraire = @honoraire.map{|a| a.amount_ttc}.sum
    # Frais de nettoyage
    @frais_nettoyage = @expenses.select{|a| a.expense_type == "Frais de nettoyage" && a.deductible == true}
    @sum_frais_nettoyage = @frais_nettoyage.map{|a| a.amount_ttc}.sum
    # Maintenance chaudiere
    @maintenance_chaudiere = @expenses.select{|a| a.expense_type == "Maintenance chaudière" && a.deductible == true}
    @sum_maintenance_chaudiere = @maintenance_chaudiere.map{|a| a.amount_ttc}.sum
    # Remplacement chaudiere
    @remplacement_chaudiere = @expenses.select{|a| a.expense_type == "Remplacement chaudière" && a.deductible == true}
    @sum_remplacement_chaudiere = @remplacement_chaudiere.map{|a| a.amount_ttc}.sum
    # Réparation
    @reparation = @expenses.select{|a| a.expense_type == "Réparation, entretien et amélioration" && a.deductible == true}
    @sum_reparation = @reparation.map{|a| a.amount_ttc}.sum
    # Inreret
    @interet = @expenses.select{|a| a.expense_type == "Intérêt d'emprunt" && a.deductible == true}
    @sum_interet = @interet.map{|a| a.amount_ttc}.sum
    # Taxe
    @taxe = @expenses.select{|a| a.expense_type == "Taxe foncière" && a.deductible == true}
    @sum_taxe = @taxe.map{|a| a.amount_ttc}.sum
    # Notaire
    @notaire = @expenses.select{|a| a.expense_type == "Frais de notaire" && a.deductible == true}
    @sum_notaire = @notaire.map{|a| a.amount_ttc}.sum
    # Frais de dossier et caution
    @dossier = @expenses.select{|a| a.expense_type == "Frais de dossiers et caution" && a.deductible == true}
    @sum_dossier = @dossier.map{|a| a.amount_ttc}.sum
    # Charge non payé
    @non_paye = @expenses.select{|a| a.expense_type == "Charges non payées au départ du locataire" && a.deductible == true}
    @sum_non_paye = @non_paye.map{|a| a.amount_ttc}.sum
    # Frais admin
    @frais_admin = @sum_frais_bancaire + @sum_honoraire + @sum_dossier
    # Autre frais non deductible
    @autre_frais_non_deductible = 20 * @building.number_of_flat
    # Depense de réparataion
    @depense_de_reparation = @sum_frais_nettoyage + @sum_remplacement_chaudiere + @sum_reparation
    # Total deduction
    @total_deduction = @frais_admin + @autre_frais_non_deductible + @depense_de_reparation + @sum_assurance + @sum_taxe + @sum_non_paye
    # Total revenus
    @revenus = @building_sum_rent_paid - @total_deduction - @sum_interet
  end

  def new
    authorize @liasse = Liasse.new
    @building = Building.find(params[:building_id])
    # @apartment_name = ["Tous"]
    # @apartments_name = @building.apartments.each do |apartment|
    #   @apartment_name  << apartment.name.to_s
    # end
  end

  def create
    authorize @liasse = Liasse.new(liasse_params)
    @building = Building.find(params[:building_id])
    @liasse.building = @building
    @liasse.user_id = current_user.id
    @liasse.statut = "active"
    @liasse.year2 = @liasse.year.strftime("%Y").to_i
    if @liasse.save
      redirect_to building_liasses_path(@building)
    else
      render :new
    end
  end

  def edit
    authorize @liasse
    # @apartment_name = ["Tous"]
    # @apartments_name = @liasse.building.apartments.each do |apartment|
    #   @apartment_name  << apartment.name.to_s
    # end
  end

  def update
    authorize @liasse
    if @liasse.update(liasse_params)
      redirect_to building_liasses_path(@liasse.building)
    else
      render :edit
    end
  end

  def destroy
    authorize @liasse
    @liasse.statut = "deleted"
    @liasse.save
    redirect_to building_liasses_path(@liasse.building)
  end

  private

  def liasse_params
    params.require(:liasse).permit(
      :year
    )
  end

  def set_liasse
    @liasse = Liasse.find(params[:id])
  end

end
