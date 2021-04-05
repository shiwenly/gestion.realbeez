class Api::V1::TenantsController < ActionController::Base

  # skip_before_action :authenticate_user!, only: []
  before_action :set_water, only: [:edit, :show, :update, :destroy]
  skip_before_action :verify_authenticity_token

  def index
    @tenants = Tenant.where("statut = ?", "active").order(name: :asc)
    render json: @tenants
  end

end
