Rails.application.routes.draw do
  get 'presenter', to: 'main#presenter'
  get 'screen', to: 'main#screen'
  get 'atendee', to: 'main#atendee'
  get 'print', to: 'main#print'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
