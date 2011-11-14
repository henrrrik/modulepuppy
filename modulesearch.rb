require 'rubygems'
require 'sinatra'
require 'active_record'
require 'open-uri'
require 'uri'
require 'nokogiri'


configure do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

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
end


get '/' do
  'Hello world!'
end


get '/refresh' do

  doc = Nokogiri::XML(open("http://updates.drupal.org/release-history/project-list/all"))

  doc.xpath('/projects/project').each do |node|

    unless node.xpath('published').text == 'unpublished'
      Project.create ({:short_name => node.xpath('short_name').text,
                      :title => node.xpath('title').text,
                      :link => node.xpath('link').text,
                      :creator => node.xpath('dc:creator').text
      })
    end
  end

  '.. done!'
end



