Rails.application.routes.draw do
  get 'presenter', to: 'main#presenter'
  get 'screen', to: 'main#screen'
  get 'atendee', to: 'main#atendee'
  get 'print', to: 'main#print'
  get 'slides', to: 'main#slides'
  root to: 'main#atendee'

  resources :user_sessions
  get 'login' => 'user_sessions#new', :as => :login
  delete 'logout' => 'user_sessions#destroy', :as => :logout
end
