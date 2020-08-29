class UserPolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    true
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

end
