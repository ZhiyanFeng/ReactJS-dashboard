class SafetyCourse < ActiveRecord::Base
	attr_accessor :check_this_org

  attr_accessible :title, 
  :url, 
  :icon, 
  :size, 
  :folder, 
  :version

  def check_org(id)
    self.check_this_org = id 
  end
end
