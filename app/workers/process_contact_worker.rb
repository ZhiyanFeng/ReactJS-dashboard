class ProcessContactWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  # sidekiq_options retry: false
  
  #def perform(contact_id)
  #  	@contact = ContactDump.find(contact_id)
  #  	@contact.process
  #end

  def perform(phone_numbers, user_id, first_name, last_name, emails, social_links)
  	numbers = phone_numbers.delete('\"').split(',')
  	numbers.each do |number|
  		if User.exists?(:id => user_id) && !([134,6307,6321,6327,1112,1140,1139,1115,1141].include? user_id)
	  		@referer = User.find(user_id)
  			if UserPrivilege.exists?(:owner_id => user_id)
  				@referer_location = UserPrivilege.where(:owner_id => user_id)
  				@referer_location_id = @referer_location.pluck(:location_id)
  				#(#{channels.join(", ")})
  				@referer_location_list = "#{@referer_location_id.join(",")}"
  			else
  				@referer_location = []
  				@referer_location_list = ""
  			end
        if ProcessedContactDump.exists?(['phone_number = ? OR phone_number = ?', number, "1#{number}"])
          pcd = ProcessedContactDump.where('phone_number = ? OR phone_number = ?', number, "1#{number}").first
          if pcd.referenced_user_ids.split(',').include? user_id.to_s
          else
            pcd.update_attributes(
              :user_reference_count => pcd[:user_reference_count] + 1, 
              :referenced_user_ids => pcd[:referenced_user_ids] + ",#{user_id}", 
            )
            pcd.update_attributes(
              :location_reference_count => pcd[:location_reference_count] + @referer_location.count, 
              :referenced_location_ids => pcd[:referenced_location_ids] + "#{@referer_location_list},"
            ) 
          end

          if ProcessedContactDump.check_name_for_exclusion(first_name, last_name) != 1
            pcd.update_attributes(:first_name => first_name, :last_name => last_name)
          end

          pcd.calculate_score
        else
          pcd = ProcessedContactDump.create(
              :phone_number => number,
              :user_reference_count => 1,
              :referenced_user_ids => "#{user_id}",
              :location_reference_count => @referer_location.count,
              :referenced_location_ids => @referer_location_list + ",",
              :lead_score => 0,
              :first_name => first_name,
              :last_name => last_name,
              :emails => emails,
              :social_links => social_links
            )
          pcd.calculate_score
        end
  		else
  			
  		end
  	end

  end
end