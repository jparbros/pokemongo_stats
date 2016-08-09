require 'sinatra'
require 'sequel'
require 'yaml'

set :public_folder, File.dirname(__FILE__) + '/public'
set :environment, :development

DB = Sequel.connect(ENV['URL_SERVER'])
POKEMONS = YAML.load_file('pokemons.yml')

get '/' do
  @pokemons = get_pokemons
  @sorted_pokemons = @pokemons.sort {|a, b| b[:count] <=> a[:count] }
  @total_counts = @pokemons.inject(0) {|sum, pokemon| sum + pokemon[:count]} 
  erb :index
end

get '/heat-map/:id' do |pokemon_id|
  pokemon_id = pokemon_id.to_i
  @pokemon = {id: pokemon_id, name: POKEMONS[pokemon_id]}
  @pokemons = POKEMONS.map {|index, pokemon| {id: index, name: pokemon} }
  @available_pokemons = DB["SELECT DISTINCT(pokemon_id) FROM pokemon ORDER BY pokemon_id ASC"].map {|pokemon| pokemon[:pokemon_id]}
  @coords = DB["SELECT * FROM pokemon WHERE pokemon_id = #{pokemon_id}"].map do |coords|
    [coords[:latitude], coords[:longitude]]
  end
  erb :heatmap
end

def get_pokemons
  total_views = DB["SELECT COUNT(pokemon_id) as total_views FROM pokemon"].first[:total_views]
  
  DB["SELECT pokemon_id, COUNT(pokemon_id) as pokemon_count FROM pokemon GROUP BY pokemon_id ORDER BY pokemon_id"].map do |pokemon|
    pokemon_count = pokemon[:pokemon_count]
    chances_to_see = ((pokemon_count.to_f*100)/total_views.to_f).round(2)
    {id: pokemon[:pokemon_id], name: POKEMONS[pokemon[:pokemon_id]], count: pokemon_count, chance: chances_to_see}
  end
end

def order_by_sql(order_by)
  case order_by
  when 'number'
    
  end
end

helpers do
  def order_helper(order_by)
    case order_by
    when 'number'
      'Numero'
    end
  end
end