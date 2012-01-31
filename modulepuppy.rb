require 'rubygems'
require 'sinatra'
require 'active_record'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'texticle/searchable'


ActiveRecord::Base.extend(Texticle)

configure do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/modulesearch')

  ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
  )
  begin
    ActiveRecord::Schema.define do
      create_table :projects do |t|
        t.text :title
        t.text :short_name
        t.text :creator
        t.text :link
      end
    end
  rescue ActiveRecord::StatementInvalid
    # Do nothing, since the schema already exists
  end

end


class Project < ActiveRecord::Base
  validates_uniqueness_of :short_name

  extend Searchable(:short_name, :title)
end


get '/' do
  erb :index
end


get '/module/:name.:format' do

  unless params[:name] and params[:format]
    throw :halt, [400, 'Bad Request']
  end

  project = Project.find_by_short_name(params[:name])
  content_type :json
  project.to_json(only: [:creator, :link, :short_name, :title])
end

get '/search.:format' do

  unless params[:query] and params[:format]
    throw :halt, [400, 'Bad Request']
  end

  project = Project.search params[:query]
  content_type :json
  project.to_json(only: [:creator, :link, :short_name, :title])
end


get '/' do
  erb :index
end

__END__

@@ index

<html>
  <head>
    <meta charset="utf-8" />
    <title>module puppy</title>
  </head>
  <body>
    <pre>
                       __
                     .'  `.
                 _.-'/  |  \/-._
    ,        _.-"  ,|  /  a `-._'-._
    |\    .-"       `--""-.__.' '-._'-._
    \ `-'`        .___.--._)========'-._]
     \            .'      |             |
      |     /,_.-'        |             |
    _/   _.'(             |             |
   /  ,-' \  \            |             |
   \  \    `-'            |             |
    `-'              jgs  '-------------'


    Module Puppy is a simple API for finding Drupal modules.

    Examples:

    /search.json?query=something
    /module/modulename.json


    --------------------------------------
    (c) <%=Time.now.year %> <a href="http://henriksjokvist.net/">Henrik Sjökvist</a> - <a href="https://github.com/henrrrik/modulepuppy">View source</a>

    </pre>
  </body>
</html>
