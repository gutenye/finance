scheduler = Rufus::Scheduler.start_new
scheduler.every "1d", :first_in => "1s" do
  App.gen_db_mtgox
end
