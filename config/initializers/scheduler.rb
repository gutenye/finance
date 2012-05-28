scheduler = Rufus::Scheduler.start_new
scheduler.every "1d", :first_in => "1s" do
  pd "App.gen"
  App.gen_db_mtgox
end
