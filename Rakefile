require 'bundler'
Bundler.require

desc "Migrate the database through scripts in db/migrate."
task :migrate do
  ActiveRecord::Base.establish_connection(YAML.load(File.read(File.join('config','database.yml')))[ENV['ENV'] ? ENV['ENV'] : 'development'])
  ActiveRecord::Migrator.migrate("db/migrate/")
end
