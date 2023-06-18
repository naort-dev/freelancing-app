class BidsController < ApplicationController
  before_action :check_rejected_or_awarded, only: %i[edit update]

  def index
    @recent_bids = Bid.recent_by_user(current_user)
    @recent_projects = Project.recent
  end

  def new
    @project = Project.find(params[:project_id])
    @bid = @project.bids.new
  end

  def create
    @bid = Bid.new(bid_params)
    if @bid.save
      redirect_to @bid.project, flash: { success: 'Bid was successfully created' }
    else
      flash.now[:error] = 'Bid could not be created. Please try again.'
      render :new
    end
  end

  def show
    @bid = Bid.find_by(id: params[:id])
  end

  def edit
    @bid = Bid.find_by(id: params[:id])
  end

  def update
    @bid = current_user.bids.find(params[:id])

    if @bid&.update(bid_params)
      redirect_to bids_path, flash: { success: 'Bid was successfully updated' }
    else
      flash.now[:error] = 'Please enter the information correctly'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bid = Bid.find_by(id: params[:id])
    @bid.destroy
    redirect_to bids_path, flash: { notice: 'Bid was successfully deleted' }
  end

  def accept
    bid = Bid.find(params[:id])
    bid.accept
    redirect_to bid.project, flash: { notice: 'Bid accepted' }
  end

  def reject
    bid = Bid.find(params[:id])
    bid.reject
    redirect_to bid.project, flash: { notice: 'Bid rejected' }
  end

  def hold
    bid = Bid.find(params[:id])
    bid.hold
    redirect_to bid.project, flash: { notice: 'Bid put on hold' }
  end

  def award
    bid = Bid.find(params[:id])
    bid.award
    redirect_to bid.project, flash: { sucess: 'Bid accepted' }
  end

  private

  def check_rejected_or_awarded
    @bid = Bid.find(params[:id])
    redirect_to bids_path, flash: { error: 'Bid cannot be modified' } unless @bid.modifiable?
  end

  def bid_params
    params.require(:bid).permit(:bid_name, :bid_description, :bid_status, :bid_amount, :project_id, :user_id)
  end
end
