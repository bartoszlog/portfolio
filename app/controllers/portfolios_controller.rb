class PortfoliosController < ApplicationController
    before_action :portfolio_item_find, only: [:edit, :show, :destroy, :update]
    layout "portfolio"
    
    def index
        @portfolios = Portfolio.all 
    end
    
    def java
        @java_item = Portfolio.java_portfolio_items
    end
    
    def rails_porfolio
        @portfolio = Portfolio.rails_portfolio_items
    end
    
    def new
        @portfolio = Portfolio.new
        3.times { @portfolio.technologies.build }
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
        @portfolio.destroy
        redirect_to portfolios_path
    end
    
    private
    def portfolio_params
        params.require(:portfolio).permit(:title,
                                          :subtitle,
                                          :body,
                                          technologies_attributes: [:name])
    end
    def portfolio_item_find
        @portfolio = Portfolio.find(params[:id]) 
    end
end

