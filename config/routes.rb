Rails.application.routes.draw do
  get 'presenter', to: 'presenter#index'
  get 'screen', to: 'screen#index'
  get 'atendee', to: 'atendee#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
