class HomeController < ApplicationController
  def index
    redirect_to main_path if logged_in?
  end
end
