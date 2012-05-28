namespace :db do
  task :testseed => :environment do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)

    seed_file = "#{Rails.root}/db/testseeds.rb"
    load(seed_file) if File.exist?(seed_file)
  end
end
