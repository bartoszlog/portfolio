class PortfoliosController < ApplicationController
    before_action :portfolio_item_find, only: [:edit, :show, :destroy, :update]
    
    def index
        @portfolio_items = Portfolio.all 
    end
    
    def java
        @java_item = Portfolio.java_portfolio_items
    end
    
    def rails_porfolio
        @portfolio_item = Portfolio.rails_portfolio_items
    end
    
    def new
        @portfolio_item = Portfolio.new
        3.times { @portfolio_item.technologies.build }
    end
    
    def create
        @portfolio_item = Portfolio.new(portfolio_params)
        if @portfolio_item.save
            redirect_to portfolios_path
        else
            redirect_to portfolios_path
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
        params.require(:portfolio).permit(:title,
                                          :subtitle,
                                          :body,
                                          technologies_attributes: [:name])
    end
    def portfolio_item_find
        @portfolio_item = Portfolio.find(params[:id]) 
    end
end

