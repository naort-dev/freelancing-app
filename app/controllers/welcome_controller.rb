# frozen_string_literal: true

class WelcomeController < ApplicationController
  skip_before_action :require_authorization, only: %i[index]
  def index; end
end
