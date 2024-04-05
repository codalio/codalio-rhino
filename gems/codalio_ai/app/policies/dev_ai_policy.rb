# frozen_string_literal: true

class DevAiPolicy < ::Rhino::BasePolicy
  def show?
    authorize_action(true)
  end

  def create?
    authorize_action(true)
  end
end
