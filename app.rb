require 'sinatra'
require 'sqlite3'
require 'yaml'

set :public_folder, File.dirname(__FILE__) + '/public'
set :environment, :production

DB = SQLite3::Database.new "./pogom.db"
POKEMONS = YAML.load_file('pokemons.yml')

get '/' do
  total_views = DB.execute("SELECT  COUNT(pokemon_id) FROM pokemon").flatten.first
  @pokemons = DB.execute("SELECT pokemon_id, COUNT(pokemon_id) FROM pokemon GROUP BY pokemon_id ORDER BY pokemon_id").map do |pokemon|
    pokemon_count = pokemon.last
    chances_to_see = ((pokemon_count.to_f*100)/total_views.to_f).round(2)
    {id: pokemon.first, name: POKEMONS[pokemon.first], count: pokemon_count, chance: chances_to_see}
  end
  @sorted_pokemons = @pokemons.sort {|a, b| b[:count] <=> a[:count] }
  @total_counts = @pokemons.inject(0) {|sum, pokemon| sum + pokemon[:count]} 
  erb :index
end

get '/heat-map/:id' do |pokemon_id|
  pokemon_id = pokemon_id.to_i
  @pokemon = {id: pokemon_id, name: POKEMONS[pokemon_id]}
  @pokemons = POKEMONS.map {|index, pokemon| {id: index, name: pokemon} }
  @available_pokemons = DB.execute("SELECT DISTINCT(pokemon_id) FROM pokemon ORDER BY pokemon_id ASC").flatten
  @coords = DB.execute("SELECT * FROM pokemon WHERE pokemon_id = #{pokemon_id}").map do |coords|
    [coords[3], coords[4]]
  end
  erb :heatmap
end