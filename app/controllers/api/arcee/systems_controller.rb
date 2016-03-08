module Api
  module Arcee
    class SystemsController < ApplicationController
      http_basic_authenticate_with :name => "theboat", :password => "whosyourdaddy", :except => [:fetch_url_meta]

      before_filter :set_headers

      respond_to :json

      def send_weekly_summary
        @user = User.find_by_email(params[:email])
        @admin_keys = AdminPrivilege.where(:owner_id => @user[:id])
        if @admin_keys.count > 0
          @admin_keys.each do |key|
            @user_list = UserPrivilege.where(:location_id => key[:location_id], :is_coffee => false, :is_invisible => false)
            user_id_list = @user_list.pluck(:id)
          end
        end
      end

      def send_weekly_summary_by_location
        if NotificationsMailer.weekly_statistics(params[:email], params[:location_id]).deliver
          render json: "Success"
        else
          render json: "Failed"
        end
      end

      def send_weekly_summary_by_location_test
        @user = User.find_by_email(params[:email])

        if UserPrivilege.exists?(:owner_id => @user[:id], :location_id => params[:location_id], :is_admin => true, :is_valid => true)
          year = Time.now.year

          week_num = Time.now.strftime("%U").to_i
          week_start = Date.commercial( year, week_num, 1 )
          week_end = Date.commercial( year, week_num, 7 )

          if week_num == 1
            week_num_minus = 53
            week_minus_start = Date.commercial( year-1, week_num_minus, 1 )
            week_minus_end = Date.commercial( year-1, week_num_minus, 7 )
          else
            week_num_minus = Time.now.strftime("%U").to_i-1
            week_minus_start = Date.commercial( year, week_num_minus, 1 )
            week_minus_end = Date.commercial( year, week_num_minus, 7 )
          end

          @week_dates = week_start.strftime( "%A, %B %e" ) + ' - ' + week_end.strftime("%A, %B %e" )

          @key = UserPrivilege.where(:owner_id => @user[:id], :location_id => params[:location_id], :is_admin => true, :is_valid => true).first

          @location = Location.find(params[:location_id])

          @user_list = UserPrivilege.where(:location_id => params[:location_id], :is_coffee => false, :is_invisible => false, :is_valid => true)
          @removed_user_list = UserPrivilege.where(:location_id => params[:location_id], :is_coffee => false, :is_invisible => false, :is_valid => false)
          user_id_list = @user_list.pluck(:owner_id)

          @channels = Channel.where("owner_id in (#{user_id_list.join(", ")}) OR (channel_type = 'location_feed' AND channel_frequency = '#{@location[:id]}')")
          channel_id_list = @channels.pluck(:id)
          @post = Post.where("owner_id != 134 AND channel_id in (#{channel_id_list.join(", ")}) AND is_valid AND created_at > '#{week_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_end.strftime('%Y-%m-%d')}'")
          @post_count = @post.count
          last_week_post_count = Post.where("channel_id in (#{channel_id_list.join(", ")}) AND is_valid AND created_at > '#{week_minus_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_minus_end.strftime('%Y-%m-%d')}'").count

          @schedule_count = Post.where("channel_id in (#{channel_id_list.join(", ")}) AND post_type = 19 AND is_valid AND created_at > '#{week_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_end.strftime('%Y-%m-%d')}'").count
          last_week_schedule_count = Post.where("channel_id in (#{channel_id_list.join(", ")}) AND post_type = 19 AND is_valid AND created_at > '#{week_minus_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_minus_end.strftime('%Y-%m-%d')}'").count

          @user_count = ChatParticipant.where("user_id in (#{user_id_list.join(", ")}) AND is_valid AND is_active").count
          @msg = ChatMessage.where("sender_id in (#{user_id_list.join(", ")}) AND is_valid AND is_active AND created_at > '#{week_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_end.strftime('%Y-%m-%d')}'")
          @msg_count = @msg.count
          last_week_msg_count = ChatMessage.where("sender_id in (#{user_id_list.join(", ")}) AND is_valid AND is_active AND created_at > '#{week_minus_start.strftime('%Y-%m-%d')}' AND created_at < '#{week_minus_end.strftime('%Y-%m-%d')}'").count

          message_users_list = @msg.pluck(:sender_id)
          post_user_list = @post.pluck(:owner_id)
          user_appearance = message_users_list + post_user_list

          freq = user_appearance.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
          @active_user = User.find(user_appearance.max_by { |v| freq[v] })

          @active_msg = @msg.where(:sender_id => @active_user[:id]).count
          @active_post = @post.where(:owner_id => @active_user[:id]).count

          #@admins = User.where("id in (#{@user_list.where(:is_admin => true).pluck(:owner_id).join(", ")})")
          @admins = User.where("id in (#{@user_list.where(:is_admin => true).pluck(:owner_id).join(", ")})")

          if (@msg_count + @post_count) > (last_week_msg_count + last_week_post_count)
            diff = (@msg_count + @post_count) - (last_week_msg_count + last_week_post_count)
            @compare_msg = "that's #{diff} more than the week before"
          elsif (@msg_count + @post_count) == (last_week_msg_count + last_week_post_count)
            @compare_msg = "that's exactly the same as the week before"
          else
            diff = (last_week_msg_count + last_week_post_count) - (@msg_count + @post_count)
            @compare_msg = "that's #{diff} fewer than the week before"
          end

          if @schedule_count > last_week_schedule_count
            diff = @schedule_count - last_week_schedule_count
            @schedule_message = "that's #{diff} more than the week before"
          elsif @schedule_count == last_week_schedule_count
            @schedule_message = "that's exactly the same as the week before"
          else
            diff = last_week_schedule_count - @schedule_count
            @schedule_message = "that's #{diff} fewer than the week before"
          end

          #Week dates in format Monday, September 1st
          #@week_dates = week_dates(week_num)

          render "users/email", :layout => false
        else
          render "404"
        end

      end

      def send_invitation
        t_sid = 'AC69f03337f35ddba0403beab55af5caf3'
        t_token = '81eaed486465b41042fd32b61e5a1b14'

        @client = Twilio::REST::Client.new t_sid, t_token

        sent_id = []
        miss_id = []
        @locations = Location.where("lower(location_name) like '%starbucks%' AND created_at > '2015-10-20 12:00:00' AND created_at < '2015-11-03 23:51:30' AND is_valid")
        @locations.each do |location|
          if UserPrivilege.where("location_id = #{location.id} AND is_valid = 't'").count <= 2
            process_these = UserPrivilege.where("location_id = #{location.id} AND is_valid = 't'")
            process_these.each do |upri|
              if !upri[:owner_id].in?(sent_id)
                @user = User.find(upri[:owner_id])
                message = @client.account.messages.create(
                  :body => "Hey #{@user[:first_name]}, thanks for trying Coffee Mobile for your location! We noticed you havent added any of your team to join in with you and the app works much better when you have others to trade shifts with! We also track your invites so you can earn rewards for inviting them - here is the link to access the app to invite: goo.gl/isddrw",
                  :to => @user[:phone_number],
                  :from => "+16473605496"
                )
                if message
                  sent_id << upri[:owner_id]
                else
                  miss_id << upri[:owner_id]
                end
              end
            end
          end
        end
        render json: { "eXpresso" => { "missed" => miss_id.count, "sent" => sent_id.count} }
      end

      def fetch_url_meta
        added = 0
        skipped = 0
        @users = User.where("id in (10501,11534,10049,10058,4648,6051,9383,14125,8242,11015,10813,10011,4990,9970,10266,10772,8259,4987,15059,5635,13620,14060,6336,11424,12478,14569,6958,10738,3996,8233,14054,3933,4927,10335,9964,10916,10101,6619,13621,3953,4841,10694,11234,14525,12004,3981,4059,10816,8235,3929,10434,13610,13594,15263,5638,10115,10711,15245,4068,10063,11068,8243,10253,9930,10713,3949,10943,13591,14983,10351,13605,12073,10903,3984,3989,15744,5633,12129,3927,10617,11821,13602,6053,10118,13641,15555,8229,11665,6641,11123,10054,11115,10374,10127,11292,10978,11114,8333,11825,14115,11541,9418,11118,4023,11445,11293,10384,14519,10383,10463,10770,11137,12498,8192,11661,11095,10096,10691,3924,11408,10814,13635,10111,10809,15774,7046,10661,10688,13606,10474,12121,10268,10747,11141,10885,4043,10338,11623,6862,11288,7377,13618,12452,8241,10823,14117,14126,10715,11126,12131,11154,6847,10685,5654,10910,11650,10743,11147,13649,9961,14280,11512,13784,13596,11002,11133,10719,11310,13615,10904,10050,4025,5640,10748,12044,8565,10940,12124,11256,10052,10791,13600,10443,10057,10933,5725,8232,11110,10789,11164,11535,11929,10698,10979,3969,10242,13613,134,4038,8295,7078,3950,10563,11121,4985,11021,11009,10853,10817,6774,8133,14139,9968,9866,13598,4561,10946,10811,15278,13590,10485,13332,10771,12174,9841,13608,10244,10866,8238,9971,10382,13619,11663,10786,3923,10718,12112,7335,5889,6091,14120,8227,11201,11986,10147,6629,12342,14776,4470,10947,11921,4136,10938,10894,3988,4360,10788,11532,8244,14373,15282,6850,10739,10869,11758,12133,9685,11117,14591,13644,14965,7379,11752,12136,1140,5064,10836,13650,11119,11238,10709,12331,8328,8271,10686,10819,4842,11674,11120,10225,11513,11094,6858,8246,10902,11482,8247,11113,6631,3926,10948,10047,13216,10741,11420,12999,11146,11481,10820,10260,10802,10906,4783,6795,10825,12169,9937,12123,12171,13490,11342,11519,10818,12340,10476,10707,9725,3979,10017,13776,5641,6187,8234,9664,11713,11403,4944,10697,13631,10935,10976,3932,11152,10048,13611,3947,7058,12147,4112,5030,13779,15169,10511,11134,11295,11085,14227,10403,11775,9106,15011,10475,10541,3976,13959,3990,10950,11545,13589,15038,5256,9836,12177,3983,14689,9683,6397,3997,11235,10341,15160,3955,3959,10744,8254,5648,8237,10930,3921,6854,13612,10716,10737,10732,13601,10687,14147,10967,10742,5123,13603,10790,10445,11116,13624,10969,6913,15052,13630,7606,6856,11294,10831,11124,10109,10764,12153,13604,3945,14155,8230,10081,6781,13599,10473,10821,10126,10810,7462,10381,10957,4610,8029,11646,9591,12130,11494,11111,11711,14108,7324,11144,13622,5141,11419,6746,10390,13683,10630,7040,3934,12388,3954,3994,8119,10195,15384,3951,10731,10352,10953,11122,6615,11125,4278,10705,13820,4285,14058,7386,9843,11127,10740,11524,3986,9593,11158,2297,14792,10354,3956,10150,10154,5636,10681,10942,14752,5110,10734,3992,4070,10684,11764,10977,11656,5642,12409,13595,10812,9834,11150,11360,11897,5637,5634,9920,11161,10785,12152,4468,3936)")
        @users.each do |u|
          begin
            @sub = Subscription.new(
              :user_id => u[:id],
              :channel_id => 5866,
              :is_active => true
            )
            if @sub.save
              added = added + 1
            else
              skipped = skipped + 1
            end
          rescue => e
            ErrorLog.create(
              :file => "systems_controller.rb",
              :function => "manually adding subscriptions",
              :error => "User with ID #{u[:id]} probably have subscription to this channel already")
          end
        end
        render json: { "eXpresso" => { "skipped" => skipped, "added" => added} }
      end

      def push_test
        #@users = User.where("active_org IN (8,14,98,17,6,85)")
        @users = User.where("id IN (1115)")
        @users.each do |user|
          @mession = Mession.where("user_id = #{user[:id]}").last
          begin
            user.update_attribute(:push_count, user[:push_count] + 1)
            if @mession.push_to == "GCM"
              n = Rpush::Gcm::Notification.new
              n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
              n.registration_ids = @mession.push_id
              #n.attributes_for_device =
              n.data = {
                :action => "open_app",
                :category => "open_app",
                :message => "Update your app to access Shift Trading and Schedule Snap & Save. More new features coming soon!",
                :org_id => user.active_org,
                :source => 1,
                :source_id => 7367
              }
              n.save!
            end

            if @mession.push_to == "APNS"
              n = Rpush::Apns::Notification.new
              n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
              n.device_token = @mession.push_id
              n.alert = "Update your app to access Shift Trading and Schedule Snap & Save. More new features coming soon!"
              n.badge = user[:push_count]
              #n.attributes_for_device
              n.data = {
                :act => "open_app",
                :cat => "open_app",
                :oid => user.active_org,
                :src => 1,
                :sid => 7367
              }
              n.save!
            end
          rescue
          ensure
          end
        end
        render json: "Finished"
      end

      def channel_subscriber_push
        apns_count = 0
        gcm_count = 0
        if Channel.exists?(:id => params[:channel_id])
          @subscribers = Subscription.where(:channel_id => params[:channel_id], :is_valid => true, :is_active => true, :subscription_mute_notifications => false)
          @subscribers.each do |sub|
            if Mession.exists?(:user_id => sub[:user_id], :is_active => true)
              @user = User.find(sub[:user_id])
              @mession = Mession.where(:user_id => sub[:user_id], :is_active => true).first
              begin
                @user.update_attribute(:push_count, @user[:push_count] + 1)
                if @mession.push_to == "GCM"
                  n = Rpush::Gcm::Notification.new
                  n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
                  n.registration_ids = @mession.push_id
                  n.data = {
                    :action => params[:category],
                    :category => params[:category],
                    :message => params[:message],
                    :org_id => params[:org_id],
                    :source => params[:source],
                    :source_id => params[:source_id],
                    :channel_id => params[:channel_id]
                  }
                  n.save!
                  gcm_count = gcm_count + 1
                end

                if @mession.push_to == "APNS"
                  n = Rpush::Apns::Notification.new
                  n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
                  n.device_token = @mession.push_id
                  n.alert = params[:message].truncate(100)
                  n.badge = @user[:push_count]
                  n.data = {
                    :act => params[:category],
                    :cat => params[:category],
                    :oid => params[:org_id],
                    :src => params[:source],
                    :sid => params[:source_id]
                  }
                  n.save!
                  apns_count = apns_count + 1
                end
              rescue
              ensure
              end
            end
          end
          render json: { "eXpresso" => { "code" => -1, "message" => "Sent #{apns_count} APNS push | #{gcm_count} GCM push."} }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => "Channel #{params[:channel_id]} does nto exist."} }
        end
      end

      def push_apns_insert
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
        #n.device_token = "0956f50c4e5fbf092fc45b269a683007cb37498344a83dfd4acabc507472d568"
        #n.device_token = "db726b2933649d129251cb24b1ee620bacd309b2510d8cc1e4b1529f308bbb21"
        n.device_token = "6795d9bb07bb104dfa8cb669986def7f63532c2696a7882b9a274f54c9616b7e"
        n.alert = "This is your test push! For Kyle"
        # These structures worked during testing with my device & downloaded from app store, first line is a simple push, second is open an announcement
        #n.data = {:cat  => "chat",:sid => '32'}
        n.data = {:cat  => "open_detail",:sid => '32',:act => 'announcement'}
        n.save!
      end

      def push_gcm_insert
          n = Rpush::Gcm::Notification.new
          n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
          n.registration_ids = "APA91bGXyiAGHJ_JtSD4fmaC5VdMdrKLOKXuyrxUY9ATUKgLS3kRuoUIjooH-RyrXE9gQtqRx7pgjCDvzlO8Ozeod7MbOA5ztax9SG5w21eZIHvlEb1B0T2XP4nQ0T5Iuz0HdlrgMKX-MW6c6U6h7M1U-OrQZ0dPlg"
          n.data = {:category => "open_app", :action => "join", :org_id => 13, :source => 4, :source_id => 114, :sender => "Daniel Chan", :content => null, :recipient => "家园"}
          n.save!
      end

      def create_gcm_service
        app = Rpush::Gcm::App.new
        app.name = "coffee_enterprise"
        app.auth_key = "AIzaSyCl3uqmJB02WAo-2SixxZ9aS8q-hrHQ2Vs"
        app.connections = 1
        app.save

        render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
      end

      def create_apns_service
        app = Rpush::Apns::App.new
        app.name = "coffee_enterprise"
        app.certificate = File.read("ShyftTest.pem")
        app.environment = "production"
        app.password = "c3chensi"
        app.connections = 1
        if app.save
          render json: { "eXpresso" => { "code" => 1, "message" => "Success", "response" => app } }
        else
          render json: { "eXpresso" => { "code" => 1, "message" => "Success", "response" => app.errors } }
        end
      end

      def setup_groups

        @apikey = ApiKey.new(:app_version => "1.0.0", :app_platform => "TEST")
        self.create_source
        self.create_image_type
        self.create_post_type
        self.create_user
        self.create_organization
        @apikey.save

        respond_to do |format|
          format.html { render json: @apikey, status: 200 }
          format.json { render json: @apikey, status: 200 }
        end
      end

      def broadcast_gcm
        @messions = Mession.where("is_active AND push_to = 'GCM'")
        @messions.each do |p|
          begin
            n = Rpush::Gcm::Notification.new
            n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
            n.registration_ids = p[:push_id]
            n.data = {
              :category => "open_app",
              :message => params[:message],
              :action => "open_app",
              :org_id => 1,
              :source => 4,
              :source_id => 3386
            }
            n.save!
          rescue
          ensure
          end
        end
        Rpush.push
        Rpush.apns_feedback

        render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
      end

      def broadcast_apns
        @messions = Mession.where("is_active AND push_to = 'APNS'")
        @messions.each do |p|
          begin
            n = Rpush::Apns::Notification.new
            n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
            n.device_token = p[:push_id]
            n.alert = params[:message]
            n.data = {
              :act => "open_app",
              :cat => "open_app",
              :oid => 1,
              :src => 4,
              :sid => 3386
            }
            n.save!
          rescue
          ensure
          end
        end
        Rpush.push
        Rpush.apns_feedback

        render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
      end

      def add_type
        if(params[:table] == "post_type")
          @posttype = PostType.new(
            :base_type => params[:base_type],
            :description => params[:description],
            :image_count => 0,
            :includes_video => false,
            :includes_survey => false,
            :includes_shift => false,
            :includes_layover => false,
            :allow_comments => false,
            :allow_likes => false,
            :allow_flags => false,
            :allow_delete => false
          )
          @posttype.save
        else
        end
      end

      def add_source
        @source = Source.new(:table_name => params[:table])
        @source.save
      end

      def create_source
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE sources RESTART IDENTITY")
        @source = Source.new(:table_name => "organization")
        @source.save
        @source = Source.new(:table_name => "user")
        @source.save
        @source = Source.new(:table_name => "image")
        @source.save
        @source = Source.new(:table_name => "post")
        @source.save
        @source = Source.new(:table_name => "comment")
        @source.save
        @source = Source.new(:table_name => "video")
        @source.save
        @source = Source.new(:table_name => "event")
        @source.save
        @source = Source.new(:table_name => "quiz")
        @source.save
        @source = Source.new(:table_name => "schedule")
        @source.save
        @source = Source.new(:table_name => "safety_course")
        @source.save
      end

      def create_organization
        @organization = Organization.new(
          :name => "The V2 Test Organization",
          :address => "Downtown",
          :city => "Montreal",
          :province => "QC",
          :country => "Canada"
        )
        @organization.save
      end

      def create_user
        @user = User.new(
          :password => "1234qwer",
          :first_name => "daniel",
          :last_name => "chen",
          :email => "ios@coffeemobile.com"
        )
        @user.save

        @user = User.new(
          :password => "1234qwer",
          :first_name => "daniel",
          :last_name => "chen",
          :email => "daniel@coffeemobile.com"
        )
        @user.save
      end

      def create_image_type
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE image_types RESTART IDENTITY")
        @imagetype = ImageType.new(
          :base_type => "image",
          :description => "organization_profile",
          :allow_comments => false,
          :allow_likes => false,
          :allow_flags => false,
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save

        @imagetype = ImageType.new(
          :base_type => "image",
          :description => "user_profile",
          :allow_comments => false,
          :allow_likes => false,
          :allow_flags => false,
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save

        @imagetype = ImageType.new(
          :base_type => "image",
          :description => "announcement_image",
          :allow_comments => false,
          :allow_likes => false,
          :allow_flags => false,
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save

        @imagetype = ImageType.new(
          :base_type => "image",
          :description => "post_image",
          :allow_comments => false,
          :allow_likes => false,
          :allow_flags => false,
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save

        @imagetype = ImageType.new(
          :base_type => "image",
          :description => "user_gallery",
          :allow_comments => false,
          :allow_likes => false,
          :allow_flags => false,
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save

        @imagetype = ImageType.new(
          :base_type => "image",
          :description => "group_cover",
          :allow_comments => false,
          :allow_likes => false,
          :allow_flags => false,
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save
      end



      def insert_post_type
        @post_type = PostType.new(params[:post_type])

        if @post_type.save
          render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
        else
          render json: { "eXpresso" => { "code" => -1, "message" => @post_type.errors } }
        end
      end

      def create_post_type
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE post_types RESTART IDENTITY")
        @posttype = PostType.new(
          :base_type => "announcement",
          :description => "basic_announcement",
          :image_count => 0,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "announcement",
          :description => "announcement_with_image",
          :image_count => 1,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "announcement",
          :description => "announcement_with_video",
          :image_count => 0,
          :includes_video => true,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "announcement",
          :description => "announcement_with_9_images",
          :image_count => 9,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "post",
          :description => "basic_post",
          :image_count => 0,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => true,
          :allow_delete => true
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "post",
          :description => "post_with_image",
          :image_count => 1,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => true,
          :allow_delete => true
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "post",
          :description => "post_with_9_images",
          :image_count => 9,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => true,
          :allow_delete => true
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "post",
          :description => "post_with_video",
          :image_count => 0,
          :includes_video => true,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "post",
          :description => "post_with_event",
          :image_count => 0,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => true,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "announcement",
          :description => "announcement_with_event",
          :image_count => 0,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => true,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "training",
          :description => "basic_training",
          :image_count => 0,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "training",
          :description => "training_with_image",
          :image_count => 1,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "training",
          :description => "training_with_video",
          :image_count => 0,
          :includes_video => true,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "quiz",
          :description => "basic_quiz",
          :image_count => 0,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => true,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "quiz",
          :description => "quiz_with_image",
          :image_count => 1,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => true,
          :includes_shift => false,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "announcement",
          :description => "announcement_with_shift",
          :image_count => 0,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => true,
          :includes_schedule => false,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "announcement",
          :description => "announcement_with_schedule",
          :image_count => 0,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => true,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save

        @posttype = PostType.new(
          :base_type => "announcement",
          :description => "announcement_with_schedule_image",
          :image_count => 1,
          :includes_video => false,
          :includes_audio => false,
          :includes_event => false,
          :includes_survey => false,
          :includes_shift => false,
          :includes_schedule => true,
          :includes_layover => false,
          :includes_url => false,
          :includes_safety_course => false,
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save
      end

      def week_dates( week_num )
        year = Time.now.year
        week_start = Date.commercial( year, week_num, 1 )
        week_end = Date.commercial( year, week_num, 7 )
        week_start.strftime( "%A, %B %e" ) + ' - ' + week_end.strftime("%A, %B %e" )
      end

    end
  end
end
