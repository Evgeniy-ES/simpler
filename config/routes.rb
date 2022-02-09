Simpler.application.routes do
  get '/tests/:id', 'tests#show'

  get '/tests', 'tests#index'
  post '/tests', 'tests#create'

  get '/not_found_page', 'tests#not_found_page'
  post '/not_found_page', 'tests#not_found_page'


end
