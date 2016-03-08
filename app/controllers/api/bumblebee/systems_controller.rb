module Api
  module Bumblebee
    class SystemsController < ApplicationController
      http_basic_authenticate_with :name => "theboat", :password => "bigcheese", :except => [:fetch_url_meta]
      
      before_filter :set_headers
      
      respond_to :json

      def fetch_url_meta
        #object = LinkThumbnailer.generate(params[:url])
        #render json: object
        @user = User.find(134)
        AdminPrivilege.grant_system_access(@user)
      end

      def push_test
        @results = PollResult.all
        @results.each do |result|
          result.save
        end
      end
      
      def push_apns_insert
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
    	n.device_token = "0956f50c4e5fbf092fc45b269a683007cb37498344a83dfd4acabc507472d568"
        n.alert = "This is your test push!"
        n.data = {:foo => :bar}
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
        app.certificate = File.read("ck.pem")
        app.environment = "sandbox"
        app.password = "Unn7td90"
        app.connections = 1
        app.save

        render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
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
      
      def broadcast
        @messions = Mession.where("is_active")
        @messions.each do |p|
          begin
            if p[:push_to] == "GCM"
              n = Rpush::Gcm::Notification.new
              n.app = Rpush::Gcm::App.find_by_name("coffee_enterprise")
              n.registration_ids = p[:push_id]
              n.data = {
                :category => "open_app",
                :message => params[:message],
                :action => "random",
                :org_id => 3,
                :source => 4,
                :source_id => 4
              }
              n.save!
            else
              n = Rpush::Apns::Notification.new
              n.app = Rpush::Apns::App.find_by_name("coffee_enterprise")
              n.device_token = p[:push_id]
              n.alert = "Coffee Mobile: Hi iOS users, we've just released an update with important bug fixes. Check it out!"
              n.sound = "default"
              n.data = {
                :category => "open_app",
                :org_id => 1,
                :source => 1,
                :source_id => 7,
                
              }
              n.save!
            end
          rescue
          ensure
          end
        end
        Rpush.push
        Rpush.apns_feedback

        render json: { "eXpresso" => { "code" => 1, "message" => "Success" } }
      end
      
      def demo
        @posts = []
        @post = {
          'org_id' => 1,
          'title' => "Patronpaint Training Video One",
          'content' => "Please take the quiz after the training to ensure best results.",
          'comments_count' => 0,
          'likes_count' => 0,
          'settings' => {
            'includes_image' => true,
            'includes_video' => false,
            'includes_survey' => false,
            'includes_shift' => false,
            'is_overlay' => true,
            'allow_comments' => false,
            'allow_likes' => false,
            'allow_flags' => false,
            'allow_delete' => false
          },
          'image' => {
            'thumb_url' => "http://192.155.94.183/assets/placeholder.png",
            'gallery_url' => "http://192.155.94.183/assets/placeholder.png",
            'full_url' => "http://192.155.94.183/assets/placeholder.png"
          }
        }
        
        @posts.insert(0,@post)
        
        @post = {
          'org_id' => 1,
          'title' => "Patronpaint Training Video One",
          'content' => "",
          'comments_count' => 0,
          'likes_count' => 0,
          'settings' => {
            'includes_image' => false,
            'includes_video' => true,
            'includes_survey' => false,
            'includes_shift' => false,
            'is_overlay' => false,
            'allow_comments' => false,
            'allow_likes' => false,
            'allow_flags' => false,
            'allow_delete' => false
          },
          'video' => {
            'host' => "youtube",
            'video_url' => "http://youtu.be/xllZ21L9RU0"
          }
        }
        
        @posts.insert(1,@post)
        
        @post = {
          'org_id' => 1,
          'title' => "Patronpaint Training Video One",
          'content' => "",
          'comments_count' => 0,
          'likes_count' => 0,
          'settings' => {
            'includes_image' => false,
            'includes_video' => true,
            'includes_survey' => false,
            'includes_shift' => false,
            'is_overlay' => false,
            'allow_comments' => false,
            'allow_likes' => false,
            'allow_flags' => false,
            'allow_delete' => false
          },
          'video' => {
            'host' => "youtube",
            'video_url' => "http://youtu.be/UbroWiPMR8g"
          }
        }
        
        @posts.insert(2,@post)
        
        @post = {
          'org_id' => 1,
          'title' => "Patronpaint Training Video One",
          'content' => "",
          'comments_count' => 0,
          'likes_count' => 0,
          'settings' => {
            'includes_image' => true,
            'includes_video' => false,
            'includes_survey' => false,
            'includes_shift' => false,
            'is_overlay' => false,
            'allow_comments' => false,
            'allow_likes' => false,
            'allow_flags' => false,
            'allow_delete' => false
          },
          'image' => {
            'thumb_url' => "http://coffeemobile.com/assets/coffee-main-hero.jpg",
            'gallery_url' => "http://coffeemobile.com/assets/coffee-main-hero.jpg",
            'full_url' => "http://coffeemobile.com/assets/coffee-main-hero.jpg"
          }
        }
        
        @posts.insert(3,@post)
        
        @post = {
          'org_id' => 1,
          'title' => "Patronpaint Training Video One",
          'content' => "Quiz",
          'comments_count' => 0,
          'likes_count' => 0,
          'settings' => {
            'includes_image' => false,
            'includes_video' => false,
            'includes_survey' => true,
            'includes_shift' => false,
            'is_overlay' => false,
            'allow_comments' => false,
            'allow_likes' => false,
            'allow_flags' => false,
            'allow_delete' => false
          },
          'survey' => {
            'item' => {
              'question' => "Where are you from?",
              'answers' => {
                'unique' => "Canada",
                'unique' => "United States",
                'unique_input' => "Other"
              }
            }
          }
        }
        
        @posts.insert(4,@post)
        
        @post = {
          'org_id' => 1,
          'title' => "Patronpaint Training Video One",
          'content' => "Thank you for your time.",
          'comments_count' => 0,
          'likes_count' => 0,
          'settings' => {
            'includes_image' => true,
            'includes_video' => false,
            'includes_survey' => false,
            'includes_shift' => false,
            'is_overlay' => true,
            'allow_comments' => false,
            'allow_likes' => false,
            'allow_flags' => false,
            'allow_delete' => false
          },
          'image' => {
            'thumb_url' => "http://coffeemobile.com/assets/sub-employee-announcement-f332c4df0a8853bdadeb876220d69130.png",
            'gallery_url' => "http://coffeemobile.com/assets/sub-employee-announcement-f332c4df0a8853bdadeb876220d69130.png",
            'full_url' => "http://coffeemobile.com/assets/sub-employee-announcement-f332c4df0a8853bdadeb876220d69130.png"
          }
        }
        
        @posts.insert(5,@post)
        render json: @posts
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
          :description => "org_gallery",  
          :allow_comments => false,
          :allow_likes => false, 
          :allow_flags => false, 
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save
        
        @imagetype = ImageType.new(
          :base_type => "image",  
          :description => "organization_cover",  
          :allow_comments => false,
          :allow_likes => false, 
          :allow_flags => false, 
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save
        
        @imagetype = ImageType.new(
          :base_type => "image", 
          :description => "user_cover",  
          :allow_comments => false,
          :allow_likes => false, 
          :allow_flags => false, 
          :allow_delete => false,
          :allow_enlarge => false
        )
        @imagetype.save
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
          :allow_comments => true,
          :allow_likes => true,
          :allow_flags => false,
          :allow_delete => false
        )
        @posttype.save
      end
    end
  end
end
