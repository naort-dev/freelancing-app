# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :require_authorization, except: [:render_not_found]
  helper_method :current_user
  helper_method :logged_in?
  helper_method :client?
  helper_method :freelancer?
  helper_method :admin?

  rescue_from ActionController::RoutingError, with: :render_not_found

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    @current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def admin?
    current_user&.role == 'admin'
  end

  def client?
    current_user&.role == 'client'
  end

  def freelancer?
    current_user&.role == 'freelancer'
  end

  def require_admin
    redirect_to root_path, flash: { error: 'You are not authorized to view this page' } unless admin?
  end

  def require_authorization
    redirect_to new_session_path, flash: { error: 'Please sign in' } unless logged_in?
  end

  def redirect_logged_in_users
    redirect_to root_path, flash: { notice: 'You are already signed in' } if logged_in?
  end

  def render_not_found
    redirect_to root_path, flash: { error: 'The page you are looking for cannot be shown.' }
  end
end
