class WatersController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_water, only: [:edit, :show, :update, :destroy]

  def index
    @waters = policy_scope(Water.all)
  end

end
