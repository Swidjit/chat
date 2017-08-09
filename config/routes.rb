Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#home'
  post '/ask' => 'chat#filter'

  post '/chat' => 'phrases#autocomplete'
  post '/check-validity' => 'phrases#check_validity'

  post '/interpret' => 'intents#interpret'

end
