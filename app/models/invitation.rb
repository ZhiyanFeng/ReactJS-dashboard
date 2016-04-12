class Invitation < ActiveRecord::Base
  self.primary_key = :id
  attr_accessible :org_id,
  :owner_id,
  :email,
  :phone_number,
  :first_name,
  :last_name,
  :location,
  :user_group,
  :registeration_step,
  :invite_url,
  :invite_code,
  :valid_until,
  :is_invited,
  :is_whitelisted,
  :is_valid

  before_create :generate_invite_code, :generate_invite_url

  before_save do
    if self.email.present?
      self.email = self.email.downcase
    end
  end

  validates_uniqueness_of :email, :case_sensitive => false, if: 'email.present?'
  validates_uniqueness_of :phone_number, if: 'phone_number.present?'

  def generate_invite_code
    begin
      #self[:invite_code] = SecureRandom.urlsafe_base64
      if Rails.env.production?
        self[:invite_code] = 999 + Random.rand(10000-1000)
      else
        self[:invite_code] = 9999
      end
    end
  end

  def generate_invite_url
    begin
      self[:invite_url] = SecureRandom.urlsafe_base64
    end
  end

  def check_location(params)

  end

  def setup_user_only(params)
    if params[:Email].present?
      setup_email = params[:Email]
    else
      #setup_email = params[:PhoneNumber].gsub(/[\+\-\(\)\s]/,'') + "@coffeemobile.com"
      setup_email = params[:PhoneNumber].gsub(/\W/,'') + "@coffeemobile.com"
    end
    transaction do

    end
  end

  def setup_new_user(params)
    if params[:Email].present?
      setup_email = params[:Email]
    else
      #setup_email = params[:PhoneNumber].gsub(/[\+\-\(\)\s]/,'') + "@coffeemobile.com"
      setup_email = params[:PhoneNumber].gsub(/\W/,'') + "@coffeemobile.com"
    end
    transaction do
      if Location.exists?(:four_sq_id => params[:LocationUniqueID])
        @location = Location.where(:four_sq_id => params[:LocationUniqueID]).first
        @user = User.new(
          :first_name => params[:FirstName],
          :last_name => params[:LastName],
          :email => setup_email,
          #:phone_number => params[:PhoneNumber].gsub(/[\+\-\(\)\s]/,''),
          :phone_number => params[:PhoneNumber].gsub(/\W/,''),
          :active_org => 1,
          :password => params[:Password],
          :user_group => 0,
          :location => @location[:id],
          :validated => true
        )
        if @user.save!
          # SETUP PROFILE & COVER
          if params[:profile_image].present?
            begin
              @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
              @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
            rescue
            end
          end
          if params[:cover_image].present?
            begin
              @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
              @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
            rescue
            end
          end
          # END

          @key = UserPrivilege.new(:org_id => @location[:org_id], :location_id => @location[:id], :owner_id => @user[:id])
          if @key.create_open_key
            @location.check_channel(@user)
            true
          else
            raise ActiveRecord::Rollback
            false
          end
        else
          raise ActiveRecord::Rollback
          false
        end
      elsif Location.exists?(:google_map_id => params[:LocationUniqueID])
        @location = Location.where(:google_map_id => params[:LocationUniqueID]).first
        @user = User.new(
          :first_name => params[:FirstName],
          :last_name => params[:LastName],
          :email => setup_email,
          :phone_number => params[:PhoneNumber],
          :active_org => @location[:org_id],
          :password => params[:Password],
          :user_group => 0,
          :location => @location[:id],
          :validated => true
        )
        if @user.save!
          # SETUP PROFILE & COVER
          if params[:profile_image].present?
            begin
              @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
              @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
            rescue
            end
          end
          if params[:cover_image].present?
            begin
              @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
              @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
            rescue
            end
          end
          # END

          @key = UserPrivilege.new(:org_id => @location[:org_id], :location_id => @location[:id], :owner_id => @user[:id])
          if @key.create_open_key
            @location.check_channel(@user)
            true
          else
            raise ActiveRecord::Rollback
            false
          end
        else
          raise ActiveRecord::Rollback
          false
        end
      else
        @location = Location.new(
          :org_id => 1,
          :owner_id => 134,
          :location_name => params[:LocationName],
          :address => params[:Address],
          :city => params[:City],
          :province => params[:Province],
          :country => params[:Country],
          :postal => params[:Postal],
          :formatted_address => params[:FormattedAddress],
          :is_hq => false,
          :lng => params[:Lng],
          :lat => params[:Lat]
        )
        if @location.save!
          @post = Post.new(
            :org_id => @location[:org_id],
            :location => @location[:id],
            :owner_id => 134,
            #:title => "Welcome to Shyft",
            #:content => "Begin trading shifts and messaging coworkers today! You now have an exclusive private network for your work location. Click on the 'Contacts' tab, then the '+' button to invite staff members. Have fun!. \nPlease contact hello@myshyft.com for assistance.",
            :title => "Welcome to your Shyft Channel - Earn 25$!",
            :content => "This is the main feed for your work location to swap shifts. Use the + button to post a shift, or make a post. You can set up private groups, post schedules, chat, have fun and communicate with your team! Your channel settings are in the top right corner (gear button). Earn 25$ - We want to send your location a gift! Grow this location to 10 team members and Shyft will send a $25 gift card of your choice (Starbucks, Best Buy, Etc.) to your store. All you have to do is invite your team, and submit your store name and address to hello@myshyft.com for our review! *New employee signups only - Ends April 16th at 12:00PM EST* #ShyftLife",
            :post_type => 1
          )
          @post.save!
          #SETUP THE DATA SOURCE OF THE LOCATION
          if params[:LocationSource] == "FourSquare"
            @location.update_attribute(:four_sq_id, params[:LocationUniqueID])
          elsif params[:LocationSource] == "GoogleMap"
            @location.update_attribute(:google_map_id, params[:LocationUniqueID])
          else
          end
          # END
          #SETUP THE ADMIN USER TO MANAGE THE LOCATION
            AdminPrivilege.grant_location_access(134, @location[:id])
          # END
          @user = User.new(
            :first_name => params[:FirstName],
            :last_name => params[:LastName],
            :email => setup_email,
            :phone_number => params[:PhoneNumber],
            :active_org => @location[:org_id],
            :password => params[:Password],
            :user_group => 0,
            :location => @location.id,
            :validated => true
          )
          if @user.save!
            # SETUP PROFILE & COVER
            if params[:profile_image].present?
              begin
                @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
                @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
              rescue
              end
            end
            if params[:cover_image].present?
              begin
                @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
                @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
              rescue
              end
            end
            # END

            @key = UserPrivilege.new(:org_id => @location[:org_id], :location_id => @location[:id], :owner_id => @user[:id])
            if @key.create_open_key
              @location.check_channel(@user)
              true
            else
              raise ActiveRecord::Rollback
              false
            end
          end
        else
          raise ActiveRecord::Rollback
          false
        end
      end
    end
  end

  def setup_user(params)
    if params[:Email].present?
      setup_email = params[:Email]
    else
      #setup_email = params[:PhoneNumber].gsub(/[\+\-\(\)\s]/,'') + "@coffeemobile.com"
      setup_email = params[:PhoneNumber].gsub(/\W/,'') + "@coffeemobile.com"
    end
    transaction do
      if Location.exists?(:four_sq_id => params[:LocationUniqueID])
        @location = Location.where(:four_sq_id => params[:LocationUniqueID]).first
        @user = User.new(
          :first_name => params[:FirstName],
          :last_name => params[:LastName],
          :email => setup_email,
          #:phone_number => params[:PhoneNumber].gsub(/[\+\-\(\)\s]/,''),
          :phone_number => params[:PhoneNumber].gsub(/\W/,''),
          :active_org => @location[:org_id],
          :password => params[:Password],
          :user_group => 0,
          :location => @location[:id],
          :validated => true
        )
        if @user.save!
          # SETUP PROFILE & COVER
          if params[:profile_image].present?
            begin
              @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
              @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
            rescue
            end
          end
          if params[:cover_image].present?
            begin
              @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
              @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
            rescue
            end
          end
          # END

          @key = UserPrivilege.new(:org_id => @location[:org_id], :location_id => @location[:id], :owner_id => @user[:id])
          if @key.create_open_key
            true
          else
            raise ActiveRecord::Rollback
            false
          end
        else
          raise ActiveRecord::Rollback
          false
        end
      elsif Location.exists?(:google_map_id => params[:LocationUniqueID])
        @location = Location.where(:google_map_id => params[:LocationUniqueID]).first
        @user = User.new(
          :first_name => params[:FirstName],
          :last_name => params[:LastName],
          :email => setup_email,
          :phone_number => params[:PhoneNumber],
          :active_org => @location[:org_id],
          :password => params[:Password],
          :user_group => 0,
          :location => @location[:id],
          :validated => true
        )
        if @user.save!
          # SETUP PROFILE & COVER
          if params[:profile_image].present?
            begin
              @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
              @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
            rescue
            end
          end
          if params[:cover_image].present?
            begin
              @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
              @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
            rescue
            end
          end
          # END

          @key = UserPrivilege.new(:org_id => @location[:org_id], :location_id => @location[:id], :owner_id => @user[:id])
          if @key.create_open_key
            #self.update_attribute(:is_valid, true)
            true
          else
            raise ActiveRecord::Rollback
            false
          end
        else
          raise ActiveRecord::Rollback
          false
        end
      else
        @location = Location.new(
          :org_id => 1,
          :owner_id => 134,
          :location_name => params[:LocationName],
          :address => params[:Address],
          :city => params[:City],
          :province => params[:Province],
          :country => params[:Country],
          :postal => params[:Postal],
          :formatted_address => params[:FormattedAddress],
          :is_hq => false,
          :lng => params[:Lng],
          :lat => params[:Lat]
        )
        if @location.save!
          @post = Post.new(
            :org_id => @location[:org_id],
            :location => @location[:id],
            :owner_id => 134,
            #:title => "Welcome to Shyft",
            #:content => "Begin trading shifts and messaging coworkers today! You now have an exclusive private network for your work location. Click on the 'Contacts' tab, then the '+' button to invite 10 staff members. Have fun!. \nPlease contact hello@myshyft.com for assistance.",
            :title => "Welcome to your Shyft Channel - Earn 25$!",
            :content => "This is the main feed for your work location to swap shifts. Use the + button to post a shift, or make a post. You can set up private groups, post schedules, chat, have fun and communicate with your team! Your channel settings are in the top right corner (gear button). Earn 25$ - We want to send your location a gift! Grow this location to 10 team members and Shyft will send a $25 gift card of your choice (Starbucks, Best Buy, Etc.) to your store. All you have to do is invite your team, and submit your store name and address to hello@myshyft.com for our review! *New employee signups only - Ends April 16th at 12:00PM EST* #ShyftLife",
            :post_type => 1
          )
          @post.save!
          #SETUP THE DATA SOURCE OF THE LOCATION
          if params[:LocationSource] == "FourSquare"
            @location.update_attribute(:four_sq_id, params[:LocationUniqueID])
          elsif params[:LocationSource] == "GoogleMap"
            @location.update_attribute(:google_map_id, params[:LocationUniqueID])
          else
          end
          # END
          #SETUP THE ADMIN USER TO MANAGE THE LOCATION
            AdminPrivilege.grant_location_access(134, @location[:id])
          # END
          @user = User.new(
            :first_name => params[:FirstName],
            :last_name => params[:LastName],
            :email => setup_email,
            :phone_number => params[:PhoneNumber],
            :active_org => @location[:org_id],
            :password => params[:Password],
            :user_group => 0,
            :location => @location.id,
            :validated => true
          )
          if @user.save!
            # SETUP PROFILE & COVER
            if params[:profile_image].present?
              begin
                @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
                @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
              rescue
              end
            end
            if params[:cover_image].present?
              begin
                @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
                @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
              rescue
              end
            end
            # END

            @key = UserPrivilege.new(:org_id => @location[:org_id], :location_id => @location[:id], :owner_id => @user[:id])
            if @key.create_open_key
              true
            else
              raise ActiveRecord::Rollback
              false
            end
          end
        else
          raise ActiveRecord::Rollback
          false
        end
      end
    end
  end

  def setup_new_users(params)
    transaction do
      if params[:NewNetwork] == "true"
        @organization = Organization.create!(
          :name => params[:NetworkName],
          :unit_number => params[:UnitNumber].present? ? params[:UnitNumber] : nil,
          :street_number => params[:StreetNumber],
          :address => params[:Address],
          :city => params[:City],
          :province => params[:Province],
          :country => params[:Country],
          :postal => params[:Postal]
        )

        @location = Location.create!(
          :org_id => @organization[:id],
          :owner_id => 0,
          :location_name => "First Location",
          :unit_number => params[:UnitNumber].present? ? params[:UnitNumber] : nil,
          :street_number => params[:StreetNumber],
          :address => params[:Address],
          :city => params[:City],
          :province => params[:Province],
          :country => params[:Country],
          :postal => params[:Postal],
          :formatted_address => params[:FormattedAddress],
          :is_hq => true,
          :lng => params[:Lng],
          :lat => params[:Lat]
        )
      else
        if self[:is_invited] || self[:is_whitelisted]
          @organization = Organization.find(self[:org_id])
        elsif params[:NetworkId].present?
          @organization = Organization.find(params[:NetworkId])
        else
          #@organization = Organization.find(:first, :conditions => ["lower(name) = ?", params[:NetworkName].downcase])
          @organization = Organization.where("lower(name) = ?", params[:NetworkName].downcase).first
        end
      end

      if params[:EmailDomain].present?
        begin
          WhitelistedDomain.create!(:org_id => @organization[:id], :domain => params[:EmailDomain])
        end
      end

      @user = User.new(
        :first_name => params[:FirstName],
        :last_name => params[:LastName],
        :email => params[:Email],
        :phone_number => self[:phone_number],
        :active_org => @organization[:id],
        :password => params[:Password],
        :user_group => self[:user_group],
        :location => self[:location],
        :validated => true
      )


      is_admin = self[:is_admin] == true || params[:NewNetwork] == "true" ? true : false
      is_invited = self[:is_invited] == true ? true : false
      if @user.save!

        if params[:NewNetwork] == "true"
          @post = Post.create!(
            :org_id => @organization[:id],
            :owner_id => @user[:id],
            :title => "Welcome to " + @organization[:name],
            #:content => "You have successfully created your network. Please contact hello@coffeemobile.com for assistance.",
            :content => "Begin trading shifts and messaging coworkers today! You now have an exclusive private network for your work location. Click on the 'Contacts' tab, then the '+' button to invite 10 staff members. Have fun!. \n\nPlease contact hello@myshyft.com for assistance.",
            :post_type => 1
          )
        end

        if params[:profile_image].present?
          begin
            @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
            @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
          rescue
          end
        end
        if params[:cover_image].present?
          begin
            @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
            @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
          rescue
          end
        end
        if params[:org_profile].present?
          begin
            @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
            @image.create_upload_and_set_organization_profile(@user[:active_org], params[:org_profile])
          rescue
          end
        end

        type = @user[:profile_id].blank? ? 5 : 6
        @post = Post.new(
          :org_id => @organization[:org_id],
          :owner_id => @user[:id],
          :title => "New Member!",
          :content => "Hello, I am the newest member of " + @organization[:name] + ".",
          :post_type => type
        )
        if type == 6
          @post.hello_with_image(@user[:profile_id])
        else
          @post.basic_hello
        end

        @location.update_attribute(:owner_id, @user[:id]) if is_admin
        @key = UserPrivilege.new(:org_id => @organization[:id], :owner_id => @user[:id])
        if @key.create_key_for(is_admin, is_invited)
          self.update_attribute(:is_valid, false)
          if params[:NewNetwork] == "true"
            2
          else
            1
          end
        else
          1
        end
      else
        -2
      end
    end
  end

  def setup_whitelisted_users(params)
    transaction do
      @organization = Organization.where(:id => self[:org_id]).first
      @user = User.new(
        :first_name => params[:FirstName],
        :last_name => params[:LastName],
        :email => params[:Email],
        :phone_number => self[:phone_number],
        :active_org => @organization[:id],
        :password => params[:Password],
        :validated => true
      )
      is_admin = self[:is_admin] == true ? true : false
      if @user.save!

        if params[:NewNetwork] == "true"
          @post = Post.create!(
            :org_id => @organization[:id],
            :owner_id => @user[:id],
            :title => "Welcome to " + @organization[:name],
            :content => "You have successfully created your network. Please contact hello@myshyft.com for assistance.",
            :post_type => 1
          )
        end

        if params[:profile_image].present?
          begin
            @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
            @image.create_upload_and_set_user_profile(@user[:id], params[:profile_image])
          rescue
          end
        end
        if params[:cover_image].present?
          begin
            @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
            @image.create_and_upload_user_cover_image(@user[:id], params[:cover_image])
          rescue
          end
        end
        if params[:org_profile].present?
          begin
            @image = Image.new(:org_id => @user[:active_org], :owner_id => @user[:id])
            @image.create_upload_and_set_organization_profile(@user[:active_org], params[:org_profile])
          rescue
          end
        end

        type = @user[:profile_id].blank? ? 5 : 6
        @post = Post.new(
          :org_id => @organization[:org_id],
          :owner_id => @user[:id],
          :title => "New Member!",
          :content => "Hello, I am the newest member of " + @organization[:name] + ".",
          :post_type => type
        )
        if type == 6
          @post.hello_with_image(@user[:profile_id])
        else
          @post.basic_hello
        end

        @key = UserPrivilege.new(:org_id => @organization[:id], :owner_id => @user[:id])
        if @key.create_key_for(is_admin, true)
          self[:is_valid] = false
          self.update_attribute(:is_valid, false)
          1
        else
          -1
        end
      else
        -2
      end
    end
  end

  def attach_images
    @image = Image.new(
      :org_id => self.org_id,
      :owner_id => self.owner_id,
      :image_type => 2
    )
    @image.save
    @image.update_attribute(:avatar, image)
    @image.update_attribute(:is_valid, true)
  end

  def attach_image(image)
    @image = Image.new(
      :org_id => self.org_id,
      :owner_id => self.owner_id,
      :image_type => 4
    )
    @image.save
    @image.update_attribute(:avatar, image)
    @image.update_attribute(:is_valid, true)
    Follower.follow(3, @image[:id], self.owner_id)
    if !@attachment = self.attached
      temp = '{"objects":[{"source":3, "source_id":' + @image.id.to_s + '}]}'
      @attachment = Attachment.new(
        :json => temp
      )
    else
      temp = ',{"source":3, "source_id":' + @image.id.to_s + '}'
      @attachment.json.insert(@attachment.json.length-2, temp)
    end
    @attachment.save
    self.update_attribute(:attachment_id, @attachment.id)
  end

end
