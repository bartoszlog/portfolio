class PortfoliosController < ApplicationController
    before_action :portfolio_item_find, only: [:edit, :show, :destroy, :update]
    access all: [:show, :index], user: {except: [:destroy, :new, :update, :edit, :create]}, site_admin: :all

    layout "portfolio"
    
    def sort
      params[:order].each do |key, value|
        Portfolio.find(value[:id]).update(position: value[:position])
      end
  
      render nothing: true
    end
    
    def index
      @portfolios = Portfolio.change_position
    end
    
    def new
      @portfolio = Portfolio.new
    end
    
    def create
      @portfolio = Portfolio.new(portfolio_params)
      if @portfolio.save
        redirect_to portfolios_path
      else
        redirect_to portfolios_path
      end
    end
        
    def edit

    end
    
    def update
      if @portfolio.update(portfolio_params)
        redirect_to portfolio_show_path
      else
        redirect_to root_path
      end
    end
    
    def show

    end
    
    def destroy
      @portfolio.destroy!
      redirect_to portfolios_path
    end
    
    private
    def portfolio_params
      params.require(:portfolio).permit(:title,
                                        :subtitle,
                                        :body,
                                        technologies_attributes: [:id, :_destroy, :name])
    end
    def portfolio_item_find
      @portfolio = Portfolio.find(params[:id]) 
    end
end

