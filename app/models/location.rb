class Location < ActiveRecord::Base
  belongs_to :organization, :class_name => "Organization", :foreign_key => "org_id"

  attr_accessible :org_id, :owner_id, :location_name, :lng, :longitude, :lat, :latitude, :unit_number, :street_number, :four_sq_id,  :google_map_id,
  :address, :city, :province, :country, :postal, :formatted_address, :member_count, :is_valid, :is_hq, :category, :swift_code

  after_create :manage_coordinates, :compile_swift_code

  def member_add
      self.update_attribute(:member_count, self.member_count + 1)
      self.save
  end

  def self.distance_between(loc1, loc2)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c / 1000 # Delta in meters
  end

  def member_minus
    if self.member_count <= 0
      count = User.where(:active_org => self.org_id, :location => self.id).count
      self.update_attribute(:member_count, count - 1)
    else
      self.update_attribute(:member_count, self.member_count - 1)
      self.save
    end
  end

  def destroy_this
    transaction do
      User.where(:location => self.id).update_all(:location => 0)
      self.update_attribute(:is_valid, false)
    end
  end

  def check_channel(user)
    if !Subscription.exists?(:user_id => user[:id], :channel_id => 1)
      coffee_channel = Channel.where(:channel_type => "coffee_feed").first
      coffee_subscription = Subscription.create(
        :user_id => user[:id],
        :channel_id => coffee_channel[:id],
        :is_active => true
      )
      coffee_channel.recount
    end
    if Channel.exists?(:channel_type => "location_feed", :channel_frequency => self[:id].to_s)
      location_channel = Channel.where(:channel_type => "location_feed", :channel_frequency => self[:id].to_s).first
    else
      location_channel = Channel.create(
        :channel_type => "location_feed",
        :channel_frequency => self[:id].to_s,
        :channel_name => self[:location_name],
        :owner_id => 134
      )
    end
    is_active = location_channel[:is_public] ? true : false
    location_subscription = Subscription.create(
      :user_id => user[:id],
      :channel_id => location_channel[:id],
      :is_active => is_active
    )
    location_channel.recount
  end

  def self.create_new_location(params)
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
      :lat => params[:Lat],
      :category => params[:category]
    )
    if @location.save
      if params[:LocationSource] == "FourSquare"
        @location.update_attribute(:four_sq_id, params[:LocationUniqueID])
      elsif params[:LocationSource] == "GoogleMap"
        @location.update_attribute(:google_map_id, params[:LocationUniqueID])
      else
      end

      @location
    else
      false
    end
  end

  def compile_swift_code
    o = [('A'..'Z'),(0..9)].map { |i| i.to_a }.flatten
    s = (0..5).map { o[rand(o.length)] }.join
    if Location.exists?(:swift_code => s)
      compile_swift_code
    else
      s
    end
  end

  def mergeable

    begin
      t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
      t_token = '81eaed486465b41042fd32b61e5a1b14'

      @client = Twilio::REST::Client.new t_sid, t_token

      location_query = "SELECT id, location_name, similarity(location_name, "+Location.sanitize(self[:location_name])+") AS sml FROM locations WHERE location_name % "+Location.sanitize(self[:location_name])+" AND similarity(location_name, "+Location.sanitize(self[:location_name])+") >= 0.2 ORDER BY sml DESC, location_name"
      @similar_locations = ActiveRecord::Base.connection.execute(location_query)
      #similar_locations = Location.where("location_name ILIKE '%#{Location.sanitize(self[:location_name])})%'").count
      if @similar_locations.count > 0
        #have similar locations
        organization_query = "SELECT id, name, similarity(name, "+Location.sanitize(self[:location_name])+") AS sml FROM organizations WHERE name % "+Location.sanitize(self[:location_name])+" AND similarity(name, "+Location.sanitize(self[:location_name])+") >= 0.2 ORDER BY sml DESC, name"
        @existing_organization = ActiveRecord::Base.connection.execute(organization_query)
        if @existing_organization.count > 0
          message = @client.account.messages.create(
            :body => "Location with ID: #{self[:id]}) --> Can be sorted into Organization with ID: #{@existing_organization.first[:id]} - #{@existing_organization.first[:name]}",
            :to => "+16472977830",
            :from => "+16137028842"
          )
        else
          message = @client.account.messages.create(
            :body => "Location with ID: #{self[:id]}) --> Can be bounded together with other locations",
            :to => "+16472977830",
            :from => "+16137028842"
          )
        end
        #existing_organization = Organization.where("name ILIKE '%#{Location.sanitize(self[:location_name])})%'").first
      else
        #have no new locations
        message = @client.account.messages.create(
          :body => "Location with ID: #{self[:id]}) is the first of its name",
          :to => "+16472977830",
          :from => "+16137028842"
        )
      end
    rescue
    ensure
    end
  end

  def manage_coordinates
    if self.lng.present?
      self.longitude = self.lng.to_f
    end

    if self.lat.present?
      self.latitude = self.lat.to_f
    end
    self.save
  end
end
