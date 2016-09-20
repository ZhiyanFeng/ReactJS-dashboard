require 'api_constraints'
require 'sidekiq/web'

Expresso::Application.routes.draw do

  resources :file_uploads

  resources :post_types

  resources :safety_courses

  resources :sources

  mount Sidekiq::Web, at: "/sidekiq"

  post "zencoder-callback" => "zencoder_callback#create", :as => "zencoder_callback"
  get "twilio-callback" => "twilio_callback#sms_response", :as => "twilio_callback"
  post "twilio-callback-brett" => "twilio_callback#brett_response", :as => "twilio_callback_brett"
  post "plivo-callback" => "plivo_callback#sms_response", :as => "plivo_callback"

  get "password_resets/new"
  get "password_resets_complete" => "password_resets#complete", :as => "password_resets_complete"
  get "password_resets_expired" => "password_resets#expired", :as => "password_resets_expired"
  get "password_resets_sent" => "password_resets#sent", :as => "password_resets_sent"
  match "/reset_password/:id", :as => :reset_password, :via => :get, :controller => :password_resets, :action => :reset_password
  match "/admin_activation/:id", :as => :activate_admin, :via => :get, :controller => :channels, :action => :activate_admin
  #root :to => "errors#404"
  root :to => redirect('https://myshyft.com')

  get "test" => "static_pages#test", :as => "test"

  resources :sessions
  resources :password_resets
  resources :organizations
  resources :channels
  resources :subscriptions
  resources :videos
  resources :users
  #resources :locations

  get "user_search" => "users#search", :as => "user_search"
  get "location_search" => "locations#search", :as => "location_search"
  post "users/list_by_name" => "users#list_by_name", :as => "list_by_name"
  post "locations/list_search_result" => "locations#list_search_result", :as => "list_location_search_result"
  #get "locations/list_members" => "locations#list_members", :as => "list_location_members"
  get "locations/make_admin" => "locations#make_admin", :as => "location_make_admin"
  match "locations/list_members/:id", :as => :list_location_members, :via => :get, :controller => :locations, :action => :list_members
  #match 'organizations/list/:id', :as => :organizations_list, :via => :post, :controller => :organizations, :action => :list

  get "/404", :to => "errors#404"
  get "/422", :to => "errors#404"
  get "/500", :to => "errors#500"
  get "/505", :to => "errors#500"

  get "dashboard", :to => "errors#404"

  get "home" => "static_pages#home", :as => "home"
  get "terms" => "static_pages#terms", :as => "terms"
  get "privacy" => "static_pages#privacy", :as => "privacy"
  get "validated" => "static_pages#validated", :as => "validated"
  get "audio_upload" => "static_pages#audio_upload", :as => "audio_upload"
  get "forgot" => "users#forgot_password", :as => "forgot"
  get "logout" => "sessions#destroy", :as => "logout"
  get "signup" => 'invitations#continue', :as => "signup"
  post "register" => "invitations#send_invite", :as => "register"
  get "registered" => "static_pages#thankyou", :as => "registered"
  get "download" => "password_resets#download", :as => "download"
  get "resend" => "sessions#resend", :as => "resend"

  namespace :api do
    scope module: :ditto, constraints: ApiConstraints.new(version: 4) do
      resources :posts do
        post :post_shift, :on => :collection
        post :detail, :on => :member
      end

      resources :users do
        post :fetch_counters, :on => :member
        post :fetch_shifts, :on => :member
        post :fetch_subscriptions, :on => :member
        post :fetch_schedules, :on => :member
        post :fetch_sessions, :on => :member
        post :fetch_contacts, :on => :member
        post :fetch_more_notifications, :on => :member
        post :fetch_notifications, :on => :member
        post :fetch_posts, :on => :member
        post :fetch_more_posts, :on => :member
        post :fetch_messages, :on => :member
        post :fetch_more_messages, :on => :member
        post :fetch_public_channels, :on => :member
        post :fetch_region_channels, :on => :member
        post :join_channel, :on => :member
        get :logout, :on => :member
      end

      resources :schedule_elements do
        get :cleanup, :on => :collection
        post :update_tip, :on => :member
        post :cover, :on => :member
        post :approve, :on => :member
        post :reject, :on => :member
        post :uncover, :on => :member
        post :delete_shift, :on => :member
      end
    end

    scope module: :charmander, constraints: ApiConstraints.new(version: 3, default: true) do
      match 'users/reset_password/', :as => :user_reset_password_v2, :via => :post, :controller => :users, :action => :reset_password
      match 'users/change_password/', :as => :user_change_password_v2, :via => :post, :controller => :users, :action => :change_password
      match 'images/upload_image/', :as => :upload_image_v2, :via => :post, :controller => :images, :action => :upload_image

      resources :channels do
        post :i_am_admin, :on => :member
        post :profile, :on => :member
        post :list_subscribers, :on => :member
        post :list_admins, :on => :member
        post :add_subscriber, :on => :member
        post :remove_subscriber, :on => :member
        get :assign_latest_message, :on => :collection
        get :recount_members, :on => :collection
        get :fix_channel_posts, :on => :collection
        get :fix_channel_chats, :on => :collection
        post :set_require_shift_approval, :on => :member
        post :set_title, :on => :member
        post :fetch_location_member_count, :on => :collection
        get :recount_geo_region_channel, :on => :member
        get :recount_branded_geo_region_channel, :on => :member
        get :recount_location_region_channel, :on => :member
        get :recount_category_channel, :on => :member
        get :assign_shifs_to_channel, :on => :collection
      end

      resources :chat_sessions do
        post :archive, :on => :member
        post :delete, :on => :member
        post :message, :on => :member
        post :messages, :on => :member
        post :reset_counter, :on => :member
        post :add_participants, :on => :member
        post :change_title, :on => :member
      end

      resources :contact_dumps do
        get :process_contact_dump, :on => :collection
      end

      resources :images do
        post :process_image, :on => :collection
      end

      resources :invitations do
        post :verify_cell_number, :on => :collection
        post :re_verify_cell_number, :on => :collection
        post :complete_signup, :on => :member
        post :complete_signup_without_location, :on => :member
      end

      resources :locations do
        post :join_location, :on => :collection
        get :fix_location_coordinates, :on => :collection
      end

      resources :messions do
        post :sms_login_send, :on => :collection
        post :sms_login_validate, :on => :collection
        post :send_referral_message, :on => :member
        post :send_custom_noification, :on => :collection
        put :activate, :on => :member
        post :check_android_version, :on => :collection
        post :check_ios_version, :on => :collection
        post :update_push_id, :on => :member
      end

      resources :posts do
        post :compose, :on => :collection
        get :destroy_post, :on => :member
        post :tip, :on => :member
        post :comment, :on => :member
        post :like, :on => :member
        post :unlike, :on => :member
        post :flag, :on => :member
        post :detail, :on => :member
      end

      resources :subscriptions do
        post :set_subscription_stick_to_top, :on => :member
        post :set_subscription_nickname, :on => :member
        post :set_subscription_mute_notifications, :on => :member
        get :setup_existing_subscriptions, :on => :collection
        post :refresh_subscription, :on => :member
        post :load_more, :on => :member
        post :quit, :on => :member
        post :archive, :on => :member
      end

      resources :schedules do
        post :make_schedule_snapshot, :on => :collection
      end

      resources :schedule_elements do
        get :cleanup, :on => :collection
        post :update_tip, :on => :member
        post :cover, :on => :member
        post :approve, :on => :member
        post :reject, :on => :member
        post :uncover, :on => :member
        post :delete_shift, :on => :member
      end

      resources :users do
        get :reindex, :on => :collection
        post :create_referral_link, :on => :member
        post :claim_reward, :on => :member
        post :verify_claim, :on => :member
        post :invite_from_contact, :on => :member
        post :profile, :on => :member
        post :synchronize, :on => :member
        post :change_password, :on => :collection
        get :get_referral_code, :on => :member
        get :get_referred_users, :on => :member
        get :test_sidekiq, :on => :collection
        post :contact_dump, :on => :member
        post :flash_action, :on => :member
        get :deactivate, :on => :member
        post :update_badge_count, :on => :member
      end

      resources :user_privileges do
        get :fix_existing_subscriptions, :on => :collection
      end

      resources :chat_participants do
        get :reset, :on => :member
      end
    end

    scope module: :bumblebee, constraints: ApiConstraints.new(version: 2) do

      resources :safety_courses
      resources :messions

      resources :schedules do
        post :make_schedule_snapshot, :on => :collection
      end

      resources :posts do
        post :compose_mobile, :on => :member
      end

      resources :schedule_elements do
        post :cover, :on => :member
        post :uncover, :on => :member
        post :delete_shift, :on => :member
      end

      resources :users do
        post :announcements, :on => :member
        post :change_password, :on => :member
        post :trainings, :on => :member
        post :quizzes, :on => :member
        post :events, :on => :member
        get :notifications, :on => :member
        post :newsfeeds, :on => :member
        post :profile, :on => :member
        post :gallery, :on => :member
        post :join_org, :on => :member
        post :leave_org, :on => :member
        get :has_validated, :on => :member
        get :is_admin, :on => :member
        get :is_valid, :on => :member
        get :is_approved, :on => :member
        get :contact_list, :on => :member
        get :chat_list, :on => :member
        get :logout, :on => :member
        get :counters, :on => :member
        post :share, :on => :member
        post :update_badge_count, :on => :member
        post :invite_from_contact, :on => :member
        post :manage_user, :on => :member
        post :sync, :on => :member
        post :synchronize, :on => :member
        post :safety_trainings, :on => :member
        post :safety_quizzes, :on => :member
        post :zhu_xiao_zhang_hao, :on => :member
      end

      resources :invitations do
        post :send_invite, :on => :collection
        post :verify_email, :on => :collection
        post :re_verify_email, :on => :collection
        post :verify_cell_number, :on => :collection
        post :re_verify_cell_number, :on => :collection
        post :finish_signup, :on => :member
        post :complete_signup, :on => :member
      end

      resources :organizations do
        post :seek, :on => :collection
        get :toggle_secure_network, :on => :member
      end
    end

    scope module: :arcee, constraints: ApiConstraints.new(version: 1) do

      match '/systems/channel_subscriber_push/', :as => :channel_subscriber_push, :via => :post, :controller => :systems, :action => :channel_subscriber_push
      match '/systems/setup/', :as => :initialize_test_environment, :via => :get, :controller => :systems, :action => :setup_groups
      match '/systems/demo/', :as => :demo_training, :via => :get, :controller => :systems, :action => :sample_training
      match '/systems/push_apns_insert/', :as => :push_apns_insert, :via => :get, :controller => :systems, :action => :push_apns_insert
      match '/systems/push_gcm_insert/', :as => :push_gcm_insert, :via => :get, :controller => :systems, :action => :push_gcm_insert
      match '/systems/push_test/', :as => :push_test, :via => :post, :controller => :systems, :action => :push_test
      match '/systems/create_reference/', :as => :create_reference, :via => :get, :controller => :systems, :action => :create_reference
      match '/systems/create_source/', :as => :create_source, :via => :get, :controller => :systems, :action => :create_source
      match '/systems/create_post_type/', :as => :create_post_type, :via => :get, :controller => :systems, :action => :create_post_type
      match '/systems/create_image_type/', :as => :create_image_type, :via => :get, :controller => :systems, :action => :create_image_type
      match '/systems/add_type/', :as => :add_type, :via => :post, :controller => :systems, :action => :add_type
      match '/systems/add_source/', :as => :add_source, :via => :post, :controller => :systems, :action => :add_source
      match '/systems/create_gcm_service/', :as => :create_gcm_service, :via => :post, :controller => :systems, :action => :create_gcm_service
      match '/systems/create_apns_service/', :as => :create_apns_service, :via => :post, :controller => :systems, :action => :create_apns_service
      match '/systems/broadcast_gcm/', :as => :broadcast_gcm, :via => :post, :controller => :systems, :action => :broadcast_gcm
      match '/systems/broadcast_apns/', :as => :broadcast_apns, :via => :post, :controller => :systems, :action => :broadcast_apns
      match '/systems/fetch_url_meta/', :as => :fetch_url_meta, :via => :post, :controller => :systems, :action => :fetch_url_meta
      match '/systems/send_invitation/', :as => :send_invitation, :via => :post, :controller => :systems, :action => :send_invitation
      match '/systems/insert_post_type/', :as => :insert_post_type, :via => :post, :controller => :systems, :action => :insert_post_type

      get "test_email" => "systems#send_weekly_summary_by_location", :as => "test_email"
      get "view_email" => "systems#send_weekly_summary_by_location_test", :as => "view_email"

      resources :api_keys

      resources :invitations do
        post :send_pass_invitation_code, :on => :collection
        post :seek_domain, :on => :collection
        post :manage_group_invitee, :on => :collection
        post :manage_invitee, :on => :member
        post :resend_invitation, :on => :member
        post :invite_from_website, :on => :collection
        post :text_download_link, :on => :collection
      end

      resources :users do
        post :announcements, :on => :member
        post :change_password, :on => :member
        post :trainings, :on => :member
        post :quizzes, :on => :member
        post :events, :on => :member
        get :notifications, :on => :member
        post :newsfeeds, :on => :member
        post :profile, :on => :member
        post :gallery, :on => :member
        post :join_org, :on => :member
        post :leave_org, :on => :member
        get :has_validated, :on => :member
        get :is_admin, :on => :member
        get :is_valid, :on => :member
        get :is_approved, :on => :member
        get :contact_list, :on => :member
        get :chat_list, :on => :member
        get :logout, :on => :member
        get :counters, :on => :member
        post :share, :on => :member
        post :update_badge_count, :on => :member
        post :invite_from_contact, :on => :member
        post :manage_user, :on => :member
        post :mass_invite_from_dashboard, :on => :collection
        post :invite_from_dashboard, :on => :collection
        post :make_admin, :on => :member
        post :manage_group_user, :on => :collection
        post :revolk_users, :on => :collection
      end
      match 'users/activate/:hash/', :as => :user_activate, :via => :get, :controller => :users, :action => :validate_user
      match 'users/reset_password/', :as => :user_reset_password, :via => :post, :controller => :users, :action => :reset_password
      match 'users/change_password/', :as => :user_change_password, :via => :post, :controller => :users, :action => :change_password
      match 'users/resend_validation_email/', :as => :user_resend_validation_email, :via => :post, :controller => :users, :action => :resend_validation_email
      match 'users/get_contact_list/:org_id/:user_id/', :as => :get_contact_list, :via => :get, :controller => :users, :action => :get_contact_list
      #match 'users/get_profile/:user_id/', :as => :get_profile, :via => :get, :controller => :users, :action => :get_profile
      match 'users/set_admin/', :as => :user_set_admin, :via => :post, :controller => :users, :action => :set_admin
      match 'users/remove_admin/', :as => :user_remove_admin, :via => :post, :controller => :users, :action => :remove_admin
      #match 'users/change_password/', :as => :user_change_password, :via => :post, :controller => :users, :action => :change_password

      resources :user_privileges do
        put :grant_access, :on => :member
        get :revoke_access, :on => :member
      end

      resources :file_uploads do
        post :drop_file, :on => :collection
      end

      resources :organizations do
        post :enable_safety_course, :on => :member
        get :get_dashboard_select_info, :on => :collection
        get :get_dashboard_announcements_info, :on => :member
        get :get_dashboard_trainings_info, :on => :member
        get :get_dashboard_quizzes_info, :on => :member
        get :get_dashboard_settings_info, :on => :member
        get :get_dashboard_reports_info, :on => :member
        get :get_deactivated_management_info, :on => :member
        get :get_invitee_management_info, :on => :member
        get :get_group_management_info, :on => :member
        get :get_location_management_info, :on => :member
        get :get_user_management_info, :on => :member
        get :get_user_quiz_report, :on => :member
        get :get_organization_groups, :on => :member
        post :bulk_invitee_delete, :on => :member
        post :profile, :on => :member
        post :gallery, :on => :member
        get :list_applicants, :on => :member
        get :is_valid, :on => :member
        post :fetch_system_data, :on => :member
        post :fetch_org_data, :on => :member
        get :fetch_quizzes, :on => :member
        post :fetch_post_graph_data, :on => :member
        post :seek, :on => :collection
        post :set_secure_network, :on => :member
        post :set_profanity_filter, :on => :member
      end
      match 'organizations/list/:id', :as => :organizations_list, :via => :post, :controller => :organizations, :action => :list
      match 'organizations/web_create', :as => :organizations_web_create, :via => :post, :controller => :organizations, :action => :web_create

      resources :images do
        post :like, :on => :member
        post :unlike, :on => :member
        post :flag, :on => :member
        post :comment, :on => :member
        post :detail, :on => :member
      end
      match 'images/upload_image/', :as => :upload_image, :via => :post, :controller => :images, :action => :upload_image
      match 'images/drop_image/', :as => :drop_image, :via => :post, :controller => :images, :action => :drop_image
      match 'images/drop_profile/', :as => :drop_profile, :via => :post, :controller => :images, :action => :drop_profile

      resources :image_types

      resources :posts do
        post :update_training, :on => :member
        post :compose, :on => :collection
        post :compose_web, :on => :collection
        post :compose_announcement, :on => :collection
        post :compose_dashboard, :on => :collection
        get :add_comment, :on => :member
        get :newsfeed_post_since, :on => :member
        post :create_post, :on => :member
        get :destroy_post, :on => :member
        post :comment, :on => :member
        post :like, :on => :member
        post :unlike, :on => :member
        post :flag, :on => :member
        post :detail, :on => :member
        post :reorder, :on => :collection
        post :dashboard_update, :on => :collection
        post :swap_sorted_dates, :on => :member
      end
      match 'posts/create_post/', :as => :create_post, :via => :post, :controller => :posts, :action => :create_post
      resources :post_types

      resources :links
      resources :link_types
      resources :comments do
        post :like, :on => :member
        post :unlike, :on => :member
        post :flag, :on => :member
      end
      resources :attachments
      resources :references

      resources :messions do
        post :send_referral_message, :on => :member
        post :send_custom_noification, :on => :collection
        put :activate, :on => :member
        post :check_android_version, :on => :collection
        post :check_ios_version, :on => :collection
      end

      resources :chat_sessions do
        post :message, :on => :member
        post :messages, :on => :member
        post :reset_counter, :on => :member
        post :add_participants, :on => :member
      end

      resources :chat_participants do
        get :reset, :on => :member
      end

      resources :notifications do
        get :viewed, :on => :member
        post :viewed_all, :on => :collection
      end

      resources :polls do
        post :detail, :on => :member
        post :answer, :on => :member
      end
      resources :poll_questions
      resources :poll_answers
      resources :poll_results
      resources :locations

      resources :user_groups do
        get :setup_user_groups, :on => :collection
      end

      resources :events
      resources :videos
      match 'videos/swfupload/', :as => :swfupload, :via => :post, :controller => :videos, :action => :swfupload
      match 'videos/zencoder_callback/', :as => :zencoder_callback, :via => :post, :controller => :videos, :action => :encode_notify

      resources :schedules do
        post :make_schedule, :on => :collection
      end
      resources :schedule_elements

      resources :audios
      match 'audios/swfupload/', :as => :audio_swfupload, :via => :post, :controller => :audios, :action => :swfupload
    end
  end

  #Last route in routes.rb
  get '*a', :to => 'errors#404'
  post '*a', :to => 'errors#404'
end
