class PortfoliosController < ApplicationController
    before_action :portfolio_item_find, only: [:edit, :show, :destroy, :update]
    
    def index
        @portfolio_items = Portfolio.all 
    end
    
    def new
        @portfolio_item = Portfolio.new
    end
    
    def create
        @portfolio_item = Portfolio.new(params[portfolio_params])
        if @portfolio_item.save
            redirect_to @portfolio_item
        else
            redirect_to root
        end
    end
        
    def edit

    end
    
    def update
        if @portfolio_item.update(portfolio_params)
            redirect_to @portfolio_item
        else
            redirect_to portfolios_path
        end
    end
    
    def show

    end
    
    def destroy
        @portfolio_item.destroy
        redirect_to portfolios_path
    end
    
    private
    def portfolio_params
        params.require(:portfolio).permit(:title, :subtitle, :body)
    end
    def portfolio_item_find
        @portfolio_item = Portfolio.find(params[:id]) 
    end
end

