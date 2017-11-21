Rails.application.routes.draw do
  devise_for :users, path: '', path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'registration' }
  resources :portfolios, except: [:show, :edit, :destroy]
  get 'portfolio/:id', to: 'portfolios#show', as: 'portfolio_show'
  get 'portfolio/:id/edit', to: 'portfolios#edit', as: 'portfolio_edit'
  get 'portfolio/:id', to: 'portfolios#destroy', as: 'portfolio_destroy'
  resources :blogs do
    member do
      get :toggle_status
    end
  end
  
  root to: 'pages#home'
  get 'about', to: 'pages#about'
  get 'contact', to: 'pages#contact'


end
