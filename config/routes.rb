Rails.application.routes.draw do

  #Como o nome do parâmetro json é "action", é necessário fazer essa gambiarra porque ele será sobrescrito pela acao do rails...
  post '/quote', to: 'quote#buy', constraints: { query_string: /.buy/ } 
  post '/quote', to: 'quote#sell', constraints: { query_string: /.sell/ } 
  

end
