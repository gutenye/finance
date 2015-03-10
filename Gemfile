#source "https://rubygems.org"
source "http://ruby.taobao.org"

gem "rails", "3.2.2"
gem "pd"
gem "mongoid"
#gem "mongoid", :git => "git://github.com/mongoid/mongoid.git" # 2.x to 3.0 break changes
gem "bson_ext"
gem "jquery-rails"
gem "unicron"
gem "slim-rails"
gem "twitter-bootstrap-rails"
gem "ember-rails", :git => "https://github.com/emberjs/ember-rails.git"
gem "d3_rails"
gem "irbtools"
gem "ffi-rzmq"
# ¤js
gem "momentjs-rails"
gem "guten-mtgox", :path => "/home/guten/dev/one/mtgox", :require => "mtgox"
# gem "emberjs-rails"
gem "rufus-scheduler"
gem "d3-tagen", :path => "/home/guten/dev/one/d3-tagen"

group :assets do
  gem "sass-rails",   "~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem "therubyracer"

  gem "uglifier", ">= 1.0.3"
end

group :development, :test do
	gem "rspec-rails"
  gem "factory_girl_rails", :require => false
end
