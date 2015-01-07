Rails.application.routes.draw do
  root 'index#index', as: 'index'
  get '/ep/:number' => 'index#show_ep'
  get '/ep/:number/:revised' => 'index#show_ep'
  get '/:id' => 'index#show', as: 'episode'
end
