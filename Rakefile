# require your app file first
require './modulepuppy'
require 'sinatra/activerecord/rake'

task :refresh do
  desc 'Refresh all projects, purging old data in the process.'

  puts 'Refreshing projects...'

  puts 'Deleting stale data...'
  Project.delete_all
  puts "done!"

  doc = Nokogiri::XML(open("http://updates.drupal.org/release-history/project-list/all"))

  puts 'Parsing XML...'
  doc.xpath('/projects/project').each do |node|

    unless node.xpath('published').text == 'unpublished'
      Project.create ({:short_name => node.xpath('short_name').text,
                      :title => node.xpath('title').text,
                      :link => node.xpath('link').text,
                      :creator => node.xpath('dc:creator').text
      })
    end
  end
  puts 'All done!'
end

task :cron => [:refresh] do
  puts "Cron done!"
end
