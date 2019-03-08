Rails.application.routes.draw do
  get 'presenter/index'
  get 'atendee/index'
  get 'presentor/index'
  get 'screen', to: 'screen#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
