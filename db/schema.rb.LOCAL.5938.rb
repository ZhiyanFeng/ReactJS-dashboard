# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150707160055) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_privileges", force: true do |t|
    t.integer   "owner_id",                                 null: false
    t.integer   "org_id",                                   null: false
    t.integer   "location_id",                              null: false
    t.integer   "master_key"
    t.integer   "parent_key"
    t.string    "key_hash"
    t.boolean   "is_valid",                  default: true
    t.timestamp "created_at",  precision: 6
    t.timestamp "updated_at",  precision: 6
  end

  create_table "api_keys", force: true do |t|
    t.string    "access_token", limit: 64,                              null: false
    t.string    "app_platform", limit: 64,                              null: false
    t.string    "app_version",  limit: 64,                              null: false
    t.boolean   "is_valid",                              default: true, null: false
    t.timestamp "created_at",              precision: 6
    t.timestamp "updated_at",              precision: 6
  end

  create_table "attachments", force: true do |t|
    t.text "json"
  end

  create_table "audios", force: true do |t|
    t.integer   "org_id",                                          null: false
    t.integer   "owner_id",                                        null: false
    t.integer   "audio_type",                       default: 0
    t.string    "audio_file_name",                                 null: false
    t.string    "audio_content_type",                              null: false
    t.integer   "audio_file_size"
    t.boolean   "is_valid",                         default: true, null: false
    t.timestamp "created_at",         precision: 6
    t.timestamp "updated_at",         precision: 6
  end

  create_table "channels", force: true do |t|
    t.string   "channel_type",                          null: false
    t.string   "channel_frequency",                     null: false
    t.string   "channel_profile_id"
    t.text     "channel_latest_content"
    t.integer  "channel_content_count",  default: 0
    t.integer  "owner_id",               default: 0
    t.integer  "member_count",           default: 0
    t.boolean  "is_active",              default: true
    t.string   "become_active_when"
    t.boolean  "allow_view",             default: true
    t.boolean  "allow_post",             default: true
    t.boolean  "allow_comment",          default: true
    t.boolean  "allow_like",             default: true
    t.boolean  "is_public",              default: true
    t.boolean  "is_valid",               default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "channel_name"
  end

  create_table "chat_messages", force: true do |t|
    t.text      "message",                                    null: false
    t.integer   "attachment_id"
    t.integer   "message_type",                default: 0,    null: false
    t.integer   "session_id",                                 null: false
    t.integer   "sender_id",                                  null: false
    t.boolean   "is_active",                   default: true
    t.boolean   "is_valid",                    default: true
    t.timestamp "created_at",    precision: 6
    t.timestamp "updated_at",    precision: 6
  end

  create_table "chat_participants", force: true do |t|
    t.integer   "user_id",                                   null: false
    t.integer   "session_id",                                null: false
    t.integer   "unread_count",               default: 0
    t.integer   "view_from",                  default: 0
    t.boolean   "is_active",                  default: true
    t.boolean   "is_valid",                   default: true
    t.timestamp "created_at",   precision: 6
    t.timestamp "updated_at",   precision: 6
  end

  create_table "chat_sessions", force: true do |t|
    t.integer   "org_id",                                          null: false
    t.integer   "message_count",                   default: 0
    t.integer   "participant_count",               default: 0
    t.text      "latest_message"
    t.boolean   "multiuser_chat",                  default: false
    t.boolean   "is_active",                       default: true
    t.boolean   "is_valid",                        default: true
    t.timestamp "created_at",        precision: 6
    t.timestamp "updated_at",        precision: 6
  end

  create_table "comments", force: true do |t|
    t.integer   "owner_id",                                    null: false
    t.integer   "source",                                      null: false
    t.integer   "source_id"
    t.text      "content",                                     null: false
    t.integer   "attachment_id"
    t.integer   "comment_type",                default: 0
    t.integer   "likes_count",                 default: 0
    t.boolean   "is_flagged",                  default: false
    t.boolean   "is_valid",                    default: true
    t.timestamp "created_at",    precision: 6
    t.timestamp "updated_at",    precision: 6
  end

  create_table "custom_groups", force: true do |t|
    t.string    "group_nickname",                               null: false
    t.integer   "owner_id",                                     null: false
    t.integer   "location_id",                                  null: false
    t.text      "members",                                      null: false
    t.boolean   "is_valid",                     default: true
    t.boolean   "is_public",                    default: false
    t.timestamp "created_at",     precision: 6
    t.timestamp "updated_at",     precision: 6
  end

  create_table "events", force: true do |t|
    t.integer   "org_id",                                                null: false
    t.integer   "owner_id",                                              null: false
    t.timestamp "event_start",              precision: 6,                null: false
    t.timestamp "event_end",                precision: 6
    t.string    "event_poi"
    t.string    "event_address",                                         null: false
    t.string    "event_lat",     limit: 64,                              null: false
    t.string    "event_lng",     limit: 64,                              null: false
    t.boolean   "event_open",                             default: true
    t.boolean   "is_valid",                               default: true
    t.timestamp "created_at",               precision: 6
    t.timestamp "updated_at",               precision: 6
  end

  create_table "file_uploads", force: true do |t|
    t.integer   "org_id",                            null: false
    t.integer   "owner_id",                          null: false
    t.string    "key"
    t.string    "file_location_url"
    t.string    "upload_file_name"
    t.string    "upload_content_type"
    t.integer   "upload_file_size"
    t.timestamp "upload_updated_at",   precision: 6
    t.timestamp "created_at",          precision: 6
    t.timestamp "updated_at",          precision: 6
  end

  create_table "flags", force: true do |t|
    t.integer   "owner_id",                                null: false
    t.integer   "source",                                  null: false
    t.integer   "source_id",                               null: false
    t.boolean   "is_valid",                 default: true
    t.timestamp "created_at", precision: 6
    t.timestamp "updated_at", precision: 6
  end

  create_table "followers", force: true do |t|
    t.integer   "source",                                  null: false
    t.integer   "source_id",                               null: false
    t.integer   "user_id",                                 null: false
    t.boolean   "is_valid",                 default: true
    t.timestamp "created_at", precision: 6
    t.timestamp "updated_at", precision: 6
  end

  create_table "image_types", force: true do |t|
    t.string    "base_type"
    t.string    "description"
    t.boolean   "allow_comments"
    t.boolean   "allow_likes"
    t.boolean   "allow_flags"
    t.boolean   "allow_delete"
    t.boolean   "allow_enlarge"
    t.boolean   "is_valid",                     default: true
    t.timestamp "created_at",     precision: 6
    t.timestamp "updated_at",     precision: 6
  end

  create_table "images", force: true do |t|
    t.integer   "org_id",                                           null: false
    t.integer   "owner_id",                                         null: false
    t.integer   "comments_count",                    default: 0
    t.integer   "likes_count",                       default: 0
    t.integer   "viewss_count",                      default: 0
    t.integer   "image_type"
    t.string    "avatar_file_name"
    t.string    "avatar_content_type"
    t.integer   "avatar_file_size"
    t.timestamp "avatar_updated_at",   precision: 6
    t.boolean   "is_valid",                          default: true
    t.timestamp "created_at",          precision: 6
    t.timestamp "updated_at",          precision: 6
  end

  create_table "invitations", force: true do |t|
    t.integer   "org_id"
    t.integer   "owner_id",                                default: 0,     null: false
    t.string    "email"
    t.string    "phone_number"
    t.string    "first_name"
    t.string    "last_name"
    t.integer   "location",                                default: 0
    t.integer   "user_group",                              default: 0
    t.integer   "profile_id"
    t.string    "step",           limit: 32
    t.string    "invite_code",    limit: 64,                               null: false
    t.string    "invite_url",     limit: 64,                               null: false
    t.boolean   "is_invited",                              default: false
    t.boolean   "is_whitelisted",                          default: false
    t.boolean   "is_valid",                                default: true
    t.timestamp "valid_until",               precision: 6
    t.timestamp "created_at",                precision: 6
    t.timestamp "updated_at",                precision: 6
  end

  create_table "likes", force: true do |t|
    t.integer   "owner_id",                                null: false
    t.integer   "source",                                  null: false
    t.integer   "source_id",                               null: false
    t.boolean   "is_valid",                 default: true
    t.timestamp "created_at", precision: 6
    t.timestamp "updated_at", precision: 6
  end

  create_table "locations", force: true do |t|
    t.integer   "org_id",                                                      null: false
    t.integer   "owner_id",                                    default: 0,     null: false
    t.integer   "member_count",                                default: 0
    t.string    "location_name"
    t.string    "unit_number",       limit: 20
    t.string    "street_number",     limit: 20
    t.string    "address",                                                     null: false
    t.string    "city",              limit: 155
    t.string    "province",          limit: 155
    t.string    "postal",            limit: 64
    t.string    "country",           limit: 64
    t.string    "formatted_address"
    t.string    "lng",               limit: 50
    t.string    "lat",               limit: 50
    t.boolean   "is_valid",                                    default: true
    t.timestamp "created_at",                    precision: 6
    t.timestamp "updated_at",                    precision: 6
    t.boolean   "is_hq",                                       default: false
    t.string    "four_sq_id"
    t.string    "google_map_id"
    t.boolean   "require_approval",                            default: false
  end

  create_table "messions", force: true do |t|
    t.integer   "org_id"
    t.integer   "user_id",                                      null: false
    t.string    "device",                                       null: false
    t.string    "device_id",                                    null: false
    t.string    "ip_address"
    t.timestamp "start",           precision: 6
    t.string    "start_location"
    t.timestamp "finish",          precision: 6
    t.string    "finish_location"
    t.string    "push_to",                                      null: false
    t.string    "push_id"
    t.string    "session_id"
    t.boolean   "is_active",                     default: true
    t.boolean   "is_valid",                      default: true
    t.timestamp "created_at",      precision: 6
    t.timestamp "updated_at",      precision: 6
  end

  create_table "notifications", force: true do |t|
    t.integer   "notify_id",                                  null: false
    t.integer   "sender_id",                                  null: false
    t.integer   "recipient_id"
    t.integer   "org_id"
    t.integer   "source",                                     null: false
    t.integer   "source_id",                                  null: false
    t.boolean   "viewed",                     default: false
    t.string    "event",                                      null: false
    t.string    "message"
    t.timestamp "created_at",   precision: 6
    t.timestamp "updated_at",   precision: 6
  end

  create_table "organizations", force: true do |t|
    t.string    "name",                                                       null: false
    t.string    "unit_number",      limit: 20
    t.string    "street_number",    limit: 20
    t.string    "address"
    t.string    "city",             limit: 155
    t.string    "province",         limit: 155
    t.string    "postal",           limit: 64
    t.string    "country",          limit: 64
    t.string    "status"
    t.string    "description"
    t.integer   "profile_id"
    t.integer   "cover_id"
    t.boolean   "secure_network",                             default: false
    t.boolean   "validated",                                  default: false
    t.string    "validation_hash",                                            null: false
    t.boolean   "is_valid",                                   default: true
    t.timestamp "created_at",                   precision: 6
    t.timestamp "updated_at",                   precision: 6
    t.boolean   "profanity_filter"
  end

  create_table "poll_answers", force: true do |t|
    t.integer   "question_id",                               null: false
    t.text      "content",                                   null: false
    t.boolean   "correct",                   default: false
    t.boolean   "is_active",                 default: true
    t.boolean   "is_valid",                  default: true
    t.timestamp "created_at",  precision: 6
    t.timestamp "updated_at",  precision: 6
  end

  create_table "poll_questions", force: true do |t|
    t.integer   "poll_id"
    t.integer   "attachment_id"
    t.text      "content",                                     null: false
    t.string    "question_type",                default: "0"
    t.integer   "complete_count",               default: 0
    t.boolean   "randomize",                    default: true
    t.boolean   "is_active",                    default: true
    t.boolean   "is_valid",                     default: true
    t.timestamp "created_at",     precision: 6
    t.timestamp "updated_at",     precision: 6
  end

  create_table "poll_results", force: true do |t|
    t.integer   "org_id"
    t.integer   "user_id",                                      null: false
    t.integer   "poll_id",                                      null: false
    t.integer   "question_count",               default: 0
    t.integer   "score",                        default: 0
    t.string    "answer_key"
    t.boolean   "passed",                       default: false
    t.boolean   "is_valid",                     default: true
    t.timestamp "created_at",     precision: 6
    t.timestamp "updated_at",     precision: 6
    t.text      "answer_json"
  end

  create_table "polls", force: true do |t|
    t.integer   "org_id",                                      null: false
    t.integer   "owner_id",                                    null: false
    t.string    "poll_name",                                   null: false
    t.integer   "complete_count",               default: 0
    t.integer   "question_count",               default: 0
    t.integer   "count_down",                   default: 10
    t.integer   "pass_mark",                    default: 0
    t.integer   "attempts_count",               default: 0
    t.timestamp "start_at",       precision: 6
    t.timestamp "end_at",         precision: 6
    t.boolean   "is_active",                    default: true
    t.boolean   "is_valid",                     default: true
    t.timestamp "created_at",     precision: 6
    t.timestamp "updated_at",     precision: 6
  end

  create_table "post_types", force: true do |t|
    t.string    "base_type"
    t.string    "description"
    t.integer   "image_count",            limit: 2
    t.boolean   "includes_video",                                 default: false
    t.boolean   "includes_event",                                 default: false
    t.boolean   "includes_survey",                                default: false
    t.boolean   "includes_shift",                                 default: false
    t.string    "includes_layover",                               default: "f"
    t.boolean   "includes_schedule",                              default: false
    t.boolean   "includes_audio",                                 default: false
    t.boolean   "includes_url",                                   default: false
    t.boolean   "includes_pdf",                                   default: false
    t.boolean   "includes_safety_course",                         default: false
    t.boolean   "allow_comments",                                 default: true
    t.boolean   "allow_likes",                                    default: true
    t.boolean   "allow_flags",                                    default: true
    t.boolean   "allow_delete",                                   default: true
    t.boolean   "is_valid",                                       default: true
    t.timestamp "created_at",                       precision: 6
    t.timestamp "updated_at",                       precision: 6
  end

  create_table "posts", force: true do |t|
    t.integer   "org_id",                                       null: false
    t.integer   "owner_id",                                     null: false
    t.string    "title",                                        null: false
    t.text      "content"
    t.integer   "attachment_id"
    t.integer   "post_type"
    t.integer   "comments_count",               default: 0
    t.integer   "likes_count",                  default: 0
    t.integer   "views_count",                  default: 0
    t.integer   "location",                     default: 0
    t.integer   "user_group",                   default: 0
    t.boolean   "is_flagged",                   default: false
    t.boolean   "is_valid",                     default: true
    t.timestamp "created_at",     precision: 6
    t.timestamp "updated_at",     precision: 6
    t.timestamp "sorted_at",      precision: 6
    t.boolean   "allow_comment",                default: true
    t.boolean   "allow_like",                   default: true
    t.integer   "z_index",                      default: 0
    t.integer   "channel_id"
  end

  create_table "rpush_apps", force: true do |t|
    t.string    "name",                                              null: false
    t.string    "environment"
    t.text      "certificate"
    t.string    "password"
    t.integer   "connections",                           default: 1, null: false
    t.timestamp "created_at",              precision: 6
    t.timestamp "updated_at",              precision: 6
    t.string    "type",                                              null: false
    t.string    "auth_key"
    t.string    "client_id"
    t.string    "client_secret"
    t.string    "access_token"
    t.timestamp "access_token_expiration", precision: 6
  end

  create_table "rpush_feedback", force: true do |t|
    t.string    "device_token", limit: 64,               null: false
    t.timestamp "failed_at",               precision: 6, null: false
    t.timestamp "created_at",              precision: 6
    t.timestamp "updated_at",              precision: 6
    t.integer   "app_id"
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: true do |t|
    t.integer   "badge"
    t.string    "device_token",      limit: 64
    t.string    "sound",                                      default: "default"
    t.string    "alert"
    t.text      "data"
    t.integer   "expiry",                                     default: 86400
    t.boolean   "delivered",                                  default: false,     null: false
    t.timestamp "delivered_at",                 precision: 6
    t.boolean   "failed",                                     default: false,     null: false
    t.timestamp "failed_at",                    precision: 6
    t.integer   "error_code"
    t.text      "error_description"
    t.timestamp "deliver_after",                precision: 6
    t.timestamp "created_at",                   precision: 6
    t.timestamp "updated_at",                   precision: 6
    t.boolean   "alert_is_json",                              default: false
    t.string    "type",                                                           null: false
    t.string    "collapse_key"
    t.boolean   "delay_while_idle",                           default: false,     null: false
    t.text      "registration_ids"
    t.integer   "app_id",                                                         null: false
    t.integer   "retries",                                    default: 0
    t.string    "uri"
    t.timestamp "fail_after",                   precision: 6
    t.boolean   "processing",                                 default: false,     null: false
    t.integer   "priority"
    t.text      "url_args"
    t.string    "category"
  end

  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))", using: :btree

  create_table "safety_courses", force: true do |t|
    t.string    "title",                               null: false
    t.string    "url",                                 null: false
    t.string    "icon",                                null: false
    t.string    "size",                                null: false
    t.string    "folder",                              null: false
    t.string    "version",    limit: 10,               null: false
    t.timestamp "created_at",            precision: 6
    t.timestamp "updated_at",            precision: 6
  end

  create_table "schedule_elements", force: true do |t|
    t.integer   "owner_id",                                  null: false
    t.integer   "schedule_id",                               null: false
    t.string    "name",                                      null: false
    t.timestamp "start_at",     precision: 6
    t.timestamp "end_at",       precision: 6
    t.boolean   "is_valid",                   default: true
    t.timestamp "created_at",   precision: 6
    t.timestamp "updated_at",   precision: 6
    t.integer   "trade_status",               default: 0
    t.integer   "coverer_id"
  end

  create_table "schedules", force: true do |t|
    t.string    "name",                                             null: false
    t.integer   "org_id",                                           null: false
    t.timestamp "start_date",          precision: 6
    t.timestamp "end_date",            precision: 6
    t.integer   "admin_id"
    t.boolean   "shift_trade",                       default: true
    t.boolean   "trade_authorization",               default: true
    t.boolean   "is_valid",                          default: true
    t.timestamp "created_at",          precision: 6
    t.timestamp "updated_at",          precision: 6
    t.integer   "location_id"
    t.string    "snapshot_url"
  end

  create_table "sources", force: true do |t|
    t.string    "table_name"
    t.boolean   "is_valid",                 default: true
    t.timestamp "created_at", precision: 6
    t.timestamp "updated_at", precision: 6
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "user_id",                                         null: false
    t.integer  "channel_id",                                      null: false
    t.integer  "subscription_content_count",      default: 0
    t.string   "subscription_nickname"
    t.string   "subscription_my_alias"
    t.boolean  "subscription_stick_to_top",       default: false
    t.boolean  "subscription_mute_notifications", default: false
    t.boolean  "subscription_display_nicknames",  default: true
    t.datetime "subscription_last_synchronize"
    t.integer  "allow_view",                      default: 0
    t.integer  "allow_post",                      default: 0
    t.integer  "allow_comment",                   default: 0
    t.integer  "allow_like",                      default: 0
    t.boolean  "is_valid",                        default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "urls", force: true do |t|
    t.integer   "org_id",                                   null: false
    t.integer   "owner_id",                                 null: false
    t.string    "page_title"
    t.string    "preview_url"
    t.boolean   "is_valid",                  default: true
    t.timestamp "created_at",  precision: 6
    t.timestamp "updated_at",  precision: 6
  end

  create_table "user_analytics", force: true do |t|
    t.integer   "user_id",                             null: false
    t.integer   "action",     limit: 2,                null: false
    t.integer   "org_id"
    t.integer   "length"
    t.integer   "source"
    t.integer   "source_id"
    t.string    "ip_address", limit: 50
    t.timestamp "created_at",            precision: 6
    t.timestamp "updated_at",            precision: 6
  end

  create_table "user_group_mappings", force: true do |t|
    t.integer   "user_id",                                 null: false
    t.integer   "org_id",                                  null: false
    t.integer   "group_id",                                null: false
    t.boolean   "is_valid",                 default: true
    t.timestamp "created_at", precision: 6
    t.timestamp "updated_at", precision: 6
  end

  create_table "user_groups", force: true do |t|
    t.integer   "org_id",                                         null: false
    t.integer   "owner_id",                        default: 0,    null: false
    t.integer   "member_count",                    default: 0
    t.string    "group_name",                                     null: false
    t.string    "group_description",                              null: false
    t.integer   "group_avatar_id"
    t.boolean   "is_valid",                        default: true
    t.timestamp "created_at",        precision: 6
    t.timestamp "updated_at",        precision: 6
  end

  create_table "user_notification_counters", force: true do |t|
    t.integer   "user_id",                                    null: false
    t.integer   "org_id",                                     null: false
    t.timestamp "last_fetched",     precision: 6
    t.integer   "newsfeeds",                      default: 0
    t.integer   "announcements",                  default: 0
    t.integer   "events",                         default: 0
    t.integer   "trainings",                      default: 0
    t.integer   "quizzes",                        default: 0
    t.integer   "contacts",                       default: 0
    t.timestamp "created_at",       precision: 6
    t.timestamp "updated_at",       precision: 6
    t.integer   "safety_trainings",               default: 0
    t.integer   "safety_quiz",                    default: 0
    t.integer   "location_id"
  end

  create_table "user_privileges", force: true do |t|
    t.integer   "owner_id",                                  null: false
    t.integer   "org_id",                                    null: false
    t.boolean   "is_approved",               default: false
    t.boolean   "is_admin",                  default: false
    t.boolean   "read_only",                 default: false
    t.boolean   "is_root",                   default: false
    t.boolean   "is_system",                 default: false
    t.boolean   "is_valid",                  default: true
    t.timestamp "created_at",  precision: 6
    t.timestamp "updated_at",  precision: 6
    t.integer   "location_id"
  end

  create_table "users", force: true do |t|
    t.string    "email"
    t.string    "number"
    t.string    "password_hash"
    t.string    "password_salt"
    t.string    "first_name",                                           null: false
    t.string    "last_name",                                            null: false
    t.integer   "gender",                               default: 0
    t.integer   "user_group",                           default: 0
    t.integer   "location",                             default: 0
    t.text      "status",                               default: ""
    t.string    "chat_handle"
    t.integer   "profile_id"
    t.integer   "cover_id"
    t.integer   "active_org",                           default: 0
    t.integer   "push_count",                           default: 0
    t.integer   "access_key_count",                     default: 0
    t.boolean   "validated",                            default: false
    t.string    "validation_hash",                                      null: false
    t.string    "auth_token"
    t.string    "password_reset_token"
    t.timestamp "password_reset_sent_at", precision: 6
    t.string    "phone_number"
    t.boolean   "system_user",                          default: false
    t.boolean   "is_valid",                             default: true
    t.boolean   "is_visible",                           default: true
    t.timestamp "created_at",             precision: 6
    t.timestamp "updated_at",             precision: 6
  end

  create_table "videos", force: true do |t|
    t.integer   "org_id",                                              null: false
    t.integer   "owner_id",                                            null: false
    t.integer   "comments_count",                       default: 0
    t.integer   "likes_count",                          default: 0
    t.integer   "views_count",                          default: 0
    t.integer   "video_type"
    t.integer   "video_host"
    t.string    "video_url"
    t.string    "video_id"
    t.string    "thumb_url"
    t.integer   "video_duration",                       default: 0
    t.string    "thumbnail_file_name"
    t.string    "thumbnail_content_type"
    t.integer   "thumbnail_file_size"
    t.timestamp "thumbnail_updated_at",   precision: 6
    t.string    "video_file_name"
    t.string    "video_content_type"
    t.integer   "video_file_size"
    t.timestamp "video_updated_at",       precision: 6
    t.string    "job_id"
    t.string    "encoded_state"
    t.string    "output_url"
    t.integer   "duration_in_ms"
    t.string    "aspect_ratio"
    t.boolean   "is_valid",                             default: true
    t.timestamp "created_at",             precision: 6
    t.timestamp "updated_at",             precision: 6
  end

  create_table "whitelisted_domains", force: true do |t|
    t.integer   "org_id",                                             null: false
    t.string    "domain",     limit: 50,                              null: false
    t.boolean   "is_valid",                            default: true
    t.timestamp "created_at",            precision: 6
    t.timestamp "updated_at",            precision: 6
  end

end
