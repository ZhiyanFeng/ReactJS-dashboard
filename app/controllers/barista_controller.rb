class BaristaController < ApplicationController
  def new
    regex_new_users = /\[(\d{4}\-\d{2}\-\d{2})\s(\d{2}\:\d{2}\:\d{2})\.\d{3}\]\s\[INFO\]\s\[users.join_org\]\s(\d*)\sjoined\s(\d*)./
    File.open( thefile ).each do |line|
      regex_new_users =~ line
      puts line
    end
  end
  
  def parse_half_hour(file)
    regex_new_users = /\[(\d{4}\-\d{2}\-\d{2})\s(\d{2}\:\d{2}\:\d{2})\.\d{3}\]\s\[INFO\]\s\[users.join_org\]\s(\d*)\sjoined\s(\d*)./
    File.open( thefile ).each do |line|
      regex_new_users =~ line
      puts line
    end
  end
  
end
