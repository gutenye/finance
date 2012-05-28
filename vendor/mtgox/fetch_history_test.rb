#!/usr/bin/env ruby

require File.expand_path("../../../config/application", __FILE__)
require "#{Rails.root}/config/environment"
require_relative "./fetch_history"

App::FetchHistory.start
