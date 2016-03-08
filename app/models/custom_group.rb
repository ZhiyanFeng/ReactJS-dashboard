class CustomGroup < ActiveRecord::Base

  attr_accessible :group_nickname, :owner_id, :location_id, :members, :is_valid, :is_public

  private

 	def add_user(id)
 		if self.members.length > 0
 			self.members = self.members + ",#{id}"
 		else
 			self.members = "#{id}"
 		end
 	end

 	def remove_user(id)
 		if self.members.include? ",#{id}"
 			self.members.gsub(",#{id}",'')
 		elsif self.members.include? "#{id}"
 			self.members.gsub("#{id}",'')
 		else

 		end
 	end

 	def set_nickname(nickname)
 		self.group_nickname = nickname
 	end

end
