class System < ActiveRecord::Base
  
  def self.push_all
	  begin
      Rpush.push
      #Rpush.apns_feedback
    rescue
      puts "Push error"
    ensure
      
    end
  end
end
