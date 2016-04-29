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

ActiveRecord::Schema.define(version: 20160428221547) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "admin_claims", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "ref_type"
    t.integer  "ref_id"
    t.string   "email",           limit: 255
    t.string   "activation_code", limit: 255
    t.boolean  "is_active",                   default: true
    t.boolean  "is_valid",                    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_privileges", force: :cascade do |t|
    t.integer  "owner_id",                                             null: false
    t.integer  "org_id",                                               null: false
    t.integer  "location_id",                                          null: false
    t.integer  "master_key"
    t.integer  "parent_key"
    t.string   "key_hash",    limit: 255
    t.boolean  "is_valid",                              default: true
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
  end

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token", limit: 64,                              null: false
    t.string   "app_platform", limit: 64,                              null: false
    t.string   "app_version",  limit: 64,                              null: false
    t.boolean  "is_valid",                              default: true, null: false
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
  end

  create_table "attachments", force: :cascade do |t|
    t.text "json"
  end

  create_table "audios", force: :cascade do |t|
    t.integer  "org_id",                                                      null: false
    t.integer  "owner_id",                                                    null: false
    t.integer  "audio_type",                                   default: 0
    t.string   "audio_file_name",    limit: 255,                              null: false
    t.string   "audio_content_type", limit: 255,                              null: false
    t.integer  "audio_file_size"
    t.boolean  "is_valid",                                     default: true, null: false
    t.datetime "created_at",                     precision: 6
    t.datetime "updated_at",                     precision: 6
  end

  create_table "channel_push_reports", force: :cascade do |t|
    t.integer  "channel_id"
    t.integer  "target_number"
    t.integer  "attempted"
    t.integer  "success"
    t.integer  "failed_due_to_missing_id"
    t.integer  "failed_due_to_other"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_sent",                  default: false
  end

  create_table "channels", force: :cascade do |t|
    t.string   "channel_type",                 limit: 255,                 null: false
    t.text     "channel_frequency",                                        null: false
    t.string   "channel_profile_id",           limit: 255
    t.text     "channel_latest_content"
    t.integer  "channel_content_count",                    default: 0
    t.integer  "owner_id",                                 default: 0
    t.integer  "member_count",                             default: 0
    t.boolean  "is_active",                                default: true
    t.string   "become_active_when",           limit: 255
    t.boolean  "allow_view",                               default: true
    t.boolean  "allow_post",                               default: true
    t.boolean  "allow_comment",                            default: true
    t.boolean  "allow_like",                               default: true
    t.boolean  "is_public",                                default: true
    t.boolean  "is_valid",                                 default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "channel_name",                 limit: 255
    t.boolean  "allow_shift_trade",                        default: true
    t.boolean  "allow_schedule",                           default: true
    t.boolean  "allow_announcement",                       default: true
    t.boolean  "allow_view_profile",                       default: true
    t.boolean  "allow_view_covered_shifts",                default: false
    t.boolean  "shift_trade_require_approval",             default: false
  end

  create_table "chat_messages", force: :cascade do |t|
    t.text     "message",                                    null: false
    t.integer  "attachment_id"
    t.integer  "message_type",                default: 0,    null: false
    t.integer  "session_id",                                 null: false
    t.integer  "sender_id",                                  null: false
    t.boolean  "is_active",                   default: true
    t.boolean  "is_valid",                    default: true
    t.datetime "created_at",    precision: 6
    t.datetime "updated_at",    precision: 6
  end

  create_table "chat_participants", force: :cascade do |t|
    t.integer  "user_id",                                   null: false
    t.integer  "session_id",                                null: false
    t.integer  "unread_count",               default: 0
    t.integer  "view_from",                  default: 0
    t.boolean  "is_active",                  default: true
    t.boolean  "is_valid",                   default: true
    t.datetime "created_at",   precision: 6
    t.datetime "updated_at",   precision: 6
  end

  create_table "chat_sessions", force: :cascade do |t|
    t.integer  "org_id",                                          null: false
    t.integer  "message_count",                   default: 0
    t.integer  "participant_count",               default: 0
    t.text     "latest_message"
    t.boolean  "multiuser_chat",                  default: false
    t.boolean  "is_active",                       default: true
    t.boolean  "is_valid",                        default: true
    t.datetime "created_at",        precision: 6
    t.datetime "updated_at",        precision: 6
    t.string   "title"
  end

  create_table "claims", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "referred_count_required_for_claim"
    t.string   "status",                            limit: 255
    t.float    "claim_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "claim_id",                          limit: 255
    t.string   "email",                             limit: 255
    t.string   "verification_code",                 limit: 255
    t.boolean  "verified"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "owner_id",                                    null: false
    t.integer  "source",                                      null: false
    t.integer  "source_id"
    t.text     "content",                                     null: false
    t.integer  "attachment_id"
    t.integer  "comment_type",                default: 0
    t.integer  "likes_count",                 default: 0
    t.boolean  "is_flagged",                  default: false
    t.boolean  "is_valid",                    default: true
    t.datetime "created_at",    precision: 6
    t.datetime "updated_at",    precision: 6
  end

  create_table "contact_dumps", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "phone_numbers"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "emails"
    t.text     "social_links"
    t.boolean  "processed",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_groups", force: :cascade do |t|
    t.string   "group_nickname", limit: 255,                               null: false
    t.integer  "owner_id",                                                 null: false
    t.integer  "location_id",                                              null: false
    t.text     "members",                                                  null: false
    t.boolean  "is_valid",                                 default: true
    t.boolean  "is_public",                                default: false
    t.datetime "created_at",                 precision: 6
    t.datetime "updated_at",                 precision: 6
  end

  create_table "error_logs", force: :cascade do |t|
    t.string   "file",       limit: 255
    t.string   "function",   limit: 255
    t.string   "error",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: :cascade do |t|
    t.integer  "org_id",                                                 null: false
    t.integer  "owner_id",                                               null: false
    t.datetime "event_start",               precision: 6,                null: false
    t.datetime "event_end",                 precision: 6
    t.string   "event_poi",     limit: 255
    t.string   "event_address", limit: 255,                              null: false
    t.string   "event_lat",     limit: 64,                               null: false
    t.string   "event_lng",     limit: 64,                               null: false
    t.boolean  "event_open",                              default: true
    t.boolean  "is_valid",                                default: true
    t.datetime "created_at",                precision: 6
    t.datetime "updated_at",                precision: 6
  end

  create_table "file_uploads", force: :cascade do |t|
    t.integer  "org_id",                                        null: false
    t.integer  "owner_id",                                      null: false
    t.string   "key",                 limit: 255
    t.string   "file_location_url",   limit: 255
    t.string   "upload_file_name",    limit: 255
    t.string   "upload_content_type", limit: 255
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at",               precision: 6
    t.datetime "created_at",                      precision: 6
    t.datetime "updated_at",                      precision: 6
  end

  create_table "flags", force: :cascade do |t|
    t.integer  "owner_id",                                null: false
    t.integer  "source",                                  null: false
    t.integer  "source_id",                               null: false
    t.boolean  "is_valid",                 default: true
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "flash_message_responses", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "flash_message_uid"
    t.boolean  "clicked"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followers", force: :cascade do |t|
    t.integer  "source",                                  null: false
    t.integer  "source_id",                               null: false
    t.integer  "user_id",                                 null: false
    t.boolean  "is_valid",                 default: true
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "image_types", force: :cascade do |t|
    t.string   "base_type",      limit: 255
    t.string   "description",    limit: 255
    t.boolean  "allow_comments"
    t.boolean  "allow_likes"
    t.boolean  "allow_flags"
    t.boolean  "allow_delete"
    t.boolean  "allow_enlarge"
    t.boolean  "is_valid",                                 default: true
    t.datetime "created_at",                 precision: 6
    t.datetime "updated_at",                 precision: 6
  end

  create_table "images", force: :cascade do |t|
    t.integer  "org_id",                                                       null: false
    t.integer  "owner_id",                                                     null: false
    t.integer  "comments_count",                                default: 0
    t.integer  "likes_count",                                   default: 0
    t.integer  "viewss_count",                                  default: 0
    t.integer  "image_type"
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at",               precision: 6
    t.boolean  "is_valid",                                      default: true
    t.datetime "created_at",                      precision: 6
    t.datetime "updated_at",                      precision: 6
  end

  create_table "invitations", force: :cascade do |t|
    t.integer  "org_id"
    t.integer  "owner_id",                                 default: 0,     null: false
    t.string   "email",          limit: 255
    t.string   "phone_number",   limit: 255
    t.string   "first_name",     limit: 255
    t.string   "last_name",      limit: 255
    t.integer  "location",                                 default: 0
    t.integer  "user_group",                               default: 0
    t.integer  "profile_id"
    t.string   "step",           limit: 32
    t.string   "invite_code",    limit: 64,                                null: false
    t.string   "invite_url",     limit: 64,                                null: false
    t.boolean  "is_invited",                               default: false
    t.boolean  "is_whitelisted",                           default: false
    t.boolean  "is_valid",                                 default: true
    t.datetime "valid_until",                precision: 6
    t.datetime "created_at",                 precision: 6
    t.datetime "updated_at",                 precision: 6
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "owner_id",                                null: false
    t.integer  "source",                                  null: false
    t.integer  "source_id",                               null: false
    t.boolean  "is_valid",                 default: true
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "locations", force: :cascade do |t|
    t.integer  "org_id",                                                      null: false
    t.integer  "owner_id",                                    default: 0,     null: false
    t.integer  "member_count",                                default: 0
    t.string   "location_name",     limit: 255
    t.string   "unit_number",       limit: 20
    t.string   "street_number",     limit: 20
    t.string   "address",           limit: 255,                               null: false
    t.string   "city",              limit: 155
    t.string   "province",          limit: 155
    t.string   "postal",            limit: 64
    t.string   "country",           limit: 64
    t.string   "formatted_address", limit: 255
    t.string   "lng",               limit: 50
    t.string   "lat",               limit: 50
    t.boolean  "is_valid",                                    default: true
    t.datetime "created_at",                    precision: 6
    t.datetime "updated_at",                    precision: 6
    t.boolean  "is_hq",                                       default: false
    t.string   "four_sq_id",        limit: 255
    t.string   "google_map_id",     limit: 255
    t.boolean  "require_approval",                            default: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "category",          limit: 255
  end

  create_table "messions", force: :cascade do |t|
    t.integer  "org_id"
    t.integer  "user_id",                                                  null: false
    t.string   "device",          limit: 255,                              null: false
    t.string   "device_id",       limit: 255,                              null: false
    t.string   "ip_address",      limit: 255
    t.datetime "start",                       precision: 6
    t.string   "start_location",  limit: 255
    t.datetime "finish",                      precision: 6
    t.string   "finish_location", limit: 255
    t.string   "push_to",         limit: 255,                              null: false
    t.string   "push_id",         limit: 255
    t.string   "session_id",      limit: 255
    t.boolean  "is_active",                                 default: true
    t.boolean  "is_valid",                                  default: true
    t.datetime "created_at",                  precision: 6
    t.datetime "updated_at",                  precision: 6
    t.string   "build",           limit: 255
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notify_id",                                              null: false
    t.integer  "sender_id",                                              null: false
    t.integer  "recipient_id"
    t.integer  "org_id"
    t.integer  "source",                                                 null: false
    t.integer  "source_id",                                              null: false
    t.boolean  "viewed",                                 default: false
    t.string   "event",        limit: 255,                               null: false
    t.string   "message",      limit: 255
    t.datetime "created_at",               precision: 6
    t.datetime "updated_at",               precision: 6
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "name",             limit: 255,                               null: false
    t.string   "unit_number",      limit: 20
    t.string   "street_number",    limit: 20
    t.string   "address",          limit: 255
    t.string   "city",             limit: 155
    t.string   "province",         limit: 155
    t.string   "postal",           limit: 64
    t.string   "country",          limit: 64
    t.string   "status",           limit: 255
    t.string   "description",      limit: 255
    t.integer  "profile_id"
    t.integer  "cover_id"
    t.boolean  "secure_network",                             default: false
    t.boolean  "validated",                                  default: false
    t.string   "validation_hash",  limit: 255,                               null: false
    t.boolean  "is_valid",                                   default: true
    t.datetime "created_at",                   precision: 6
    t.datetime "updated_at",                   precision: 6
    t.boolean  "profanity_filter"
  end

  create_table "poll_answers", force: :cascade do |t|
    t.integer  "question_id",                               null: false
    t.text     "content",                                   null: false
    t.boolean  "correct",                   default: false
    t.boolean  "is_active",                 default: true
    t.boolean  "is_valid",                  default: true
    t.datetime "created_at",  precision: 6
    t.datetime "updated_at",  precision: 6
  end

  create_table "poll_questions", force: :cascade do |t|
    t.integer  "poll_id"
    t.integer  "attachment_id"
    t.text     "content",                                                 null: false
    t.string   "question_type",  limit: 255,               default: "0"
    t.integer  "complete_count",                           default: 0
    t.boolean  "randomize",                                default: true
    t.boolean  "is_active",                                default: true
    t.boolean  "is_valid",                                 default: true
    t.datetime "created_at",                 precision: 6
    t.datetime "updated_at",                 precision: 6
  end

  create_table "poll_results", force: :cascade do |t|
    t.integer  "org_id"
    t.integer  "user_id",                                                  null: false
    t.integer  "poll_id",                                                  null: false
    t.integer  "question_count",                           default: 0
    t.integer  "score",                                    default: 0
    t.string   "answer_key",     limit: 255
    t.boolean  "passed",                                   default: false
    t.boolean  "is_valid",                                 default: true
    t.datetime "created_at",                 precision: 6
    t.datetime "updated_at",                 precision: 6
    t.text     "answer_json"
  end

  create_table "polls", force: :cascade do |t|
    t.integer  "org_id",                                                  null: false
    t.integer  "owner_id",                                                null: false
    t.string   "poll_name",      limit: 255,                              null: false
    t.integer  "complete_count",                           default: 0
    t.integer  "question_count",                           default: 0
    t.integer  "count_down",                               default: 10
    t.integer  "pass_mark",                                default: 0
    t.integer  "attempts_count",                           default: 0
    t.datetime "start_at",                   precision: 6
    t.datetime "end_at",                     precision: 6
    t.boolean  "is_active",                                default: true
    t.boolean  "is_valid",                                 default: true
    t.datetime "created_at",                 precision: 6
    t.datetime "updated_at",                 precision: 6
  end

  create_table "post_types", force: :cascade do |t|
    t.string   "base_type",              limit: 255
    t.string   "description",            limit: 255
    t.integer  "image_count",            limit: 2
    t.boolean  "includes_video",                                   default: false
    t.boolean  "includes_event",                                   default: false
    t.boolean  "includes_survey",                                  default: false
    t.boolean  "includes_shift",                                   default: false
    t.string   "includes_layover",       limit: 255,               default: "f"
    t.boolean  "includes_schedule",                                default: false
    t.boolean  "includes_audio",                                   default: false
    t.boolean  "includes_url",                                     default: false
    t.boolean  "includes_pdf",                                     default: false
    t.boolean  "includes_safety_course",                           default: false
    t.boolean  "allow_comments",                                   default: true
    t.boolean  "allow_likes",                                      default: true
    t.boolean  "allow_flags",                                      default: true
    t.boolean  "allow_delete",                                     default: true
    t.boolean  "is_valid",                                         default: true
    t.datetime "created_at",                         precision: 6
    t.datetime "updated_at",                         precision: 6
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "org_id",                                                   null: false
    t.integer  "owner_id",                                                 null: false
    t.string   "title",          limit: 255,                               null: false
    t.text     "content"
    t.integer  "attachment_id"
    t.integer  "post_type"
    t.integer  "comments_count",                           default: 0
    t.integer  "likes_count",                              default: 0
    t.integer  "views_count",                              default: 0
    t.integer  "location",                                 default: 0
    t.integer  "user_group",                               default: 0
    t.boolean  "is_flagged",                               default: false
    t.boolean  "is_valid",                                 default: true
    t.datetime "created_at",                 precision: 6
    t.datetime "updated_at",                 precision: 6
    t.datetime "sorted_at",                  precision: 6
    t.boolean  "allow_comment",                            default: true
    t.boolean  "allow_like",                               default: true
    t.integer  "z_index",                                  default: 0
    t.integer  "channel_id"
  end

  create_table "processed_contact_dumps", force: :cascade do |t|
    t.string   "phone_number",             limit: 255
    t.integer  "user_reference_count"
    t.text     "referenced_user_ids"
    t.integer  "location_reference_count"
    t.text     "referenced_location_ids"
    t.integer  "lead_score"
    t.string   "first_name",               limit: 255
    t.string   "last_name",                limit: 255
    t.text     "emails"
    t.text     "social_links"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "referral_accepts", force: :cascade do |t|
    t.integer  "acceptor_id"
    t.string   "acceptor_branch_id",    limit: 255
    t.string   "program_code",          limit: 255
    t.string   "referral_platform",     limit: 255
    t.string   "referral_code",         limit: 255
    t.integer  "referral_credit_given"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "claimed",                           default: false
  end

  create_table "referral_sends", force: :cascade do |t|
    t.integer  "sender_id"
    t.string   "program_code",       limit: 255
    t.string   "referral_link",      limit: 255
    t.string   "referral_platform",  limit: 255
    t.string   "referral_code",      limit: 255
    t.string   "referral_target_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rpush_apps", force: :cascade do |t|
    t.string   "name",                    limit: 255,                           null: false
    t.string   "environment",             limit: 255
    t.text     "certificate"
    t.string   "password",                limit: 255
    t.integer  "connections",                                       default: 1, null: false
    t.datetime "created_at",                          precision: 6
    t.datetime "updated_at",                          precision: 6
    t.string   "type",                    limit: 255,                           null: false
    t.string   "auth_key",                limit: 255
    t.string   "client_id",               limit: 255
    t.string   "client_secret",           limit: 255
    t.string   "access_token",            limit: 255
    t.datetime "access_token_expiration",             precision: 6
  end

  create_table "rpush_feedback", force: :cascade do |t|
    t.string   "device_token", limit: 64,               null: false
    t.datetime "failed_at",               precision: 6, null: false
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
    t.integer  "app_id"
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: :cascade do |t|
    t.integer  "badge"
    t.string   "device_token",      limit: 64
    t.string   "sound",             limit: 255,               default: "default"
    t.text     "alert"
    t.text     "data"
    t.integer  "expiry",                                      default: 86400
    t.boolean  "delivered",                                   default: false,     null: false
    t.datetime "delivered_at",                  precision: 6
    t.boolean  "failed",                                      default: false,     null: false
    t.datetime "failed_at",                     precision: 6
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after",                 precision: 6
    t.datetime "created_at",                    precision: 6
    t.datetime "updated_at",                    precision: 6
    t.boolean  "alert_is_json",                               default: false
    t.string   "type",              limit: 255,                                   null: false
    t.string   "collapse_key",      limit: 255
    t.boolean  "delay_while_idle",                            default: false,     null: false
    t.text     "registration_ids"
    t.integer  "app_id",                                                          null: false
    t.integer  "retries",                                     default: 0
    t.string   "uri",               limit: 255
    t.datetime "fail_after",                    precision: 6
    t.boolean  "processing",                                  default: false,     null: false
    t.integer  "priority"
    t.text     "url_args"
    t.string   "category",          limit: 255
    t.boolean  "content_available",                           default: false
    t.text     "notification"
  end

  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", where: "((NOT delivered) AND (NOT failed))", using: :btree

  create_table "safety_courses", force: :cascade do |t|
    t.string   "title",      limit: 255,               null: false
    t.string   "url",        limit: 255,               null: false
    t.string   "icon",       limit: 255,               null: false
    t.string   "size",       limit: 255,               null: false
    t.string   "folder",     limit: 255,               null: false
    t.string   "version",    limit: 10,                null: false
    t.datetime "created_at",             precision: 6
    t.datetime "updated_at",             precision: 6
  end

  create_table "schedule_elements", force: :cascade do |t|
    t.integer  "owner_id",                                              null: false
    t.integer  "schedule_id",                                           null: false
    t.string   "name",         limit: 255,                              null: false
    t.datetime "start_at",                 precision: 6
    t.datetime "end_at",                   precision: 6
    t.boolean  "is_valid",                               default: true
    t.datetime "created_at",               precision: 6
    t.datetime "updated_at",               precision: 6
    t.integer  "trade_status",                           default: 0
    t.integer  "coverer_id"
    t.integer  "approver_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.string   "name",                limit: 255,                              null: false
    t.integer  "org_id",                                                       null: false
    t.datetime "start_date",                      precision: 6
    t.datetime "end_date",                        precision: 6
    t.integer  "admin_id"
    t.boolean  "shift_trade",                                   default: true
    t.boolean  "trade_authorization",                           default: true
    t.boolean  "is_valid",                                      default: true
    t.datetime "created_at",                      precision: 6
    t.datetime "updated_at",                      precision: 6
    t.integer  "location_id"
    t.string   "snapshot_url",        limit: 255
  end

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "ip_address", limit: 255
    t.string   "device",     limit: 255
    t.string   "browser",    limit: 255
    t.string   "version",    limit: 255
    t.boolean  "is_active",              default: true
    t.boolean  "is_valid",               default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_logins", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "validation_code"
    t.integer  "validation_entered"
    t.boolean  "is_used"
    t.boolean  "is_valid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_stops", force: :cascade do |t|
    t.string   "plivo_number", limit: 255
    t.string   "stop_number",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", force: :cascade do |t|
    t.string   "table_name", limit: 255
    t.boolean  "is_valid",                             default: true
    t.datetime "created_at",             precision: 6
    t.datetime "updated_at",             precision: 6
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id",                                                     null: false
    t.integer  "channel_id",                                                  null: false
    t.integer  "subscription_content_count",                  default: 0
    t.string   "subscription_nickname",           limit: 255
    t.string   "subscription_my_alias",           limit: 255
    t.boolean  "subscription_stick_to_top",                   default: false
    t.boolean  "subscription_mute_notifications",             default: false
    t.boolean  "subscription_display_nicknames",              default: true
    t.datetime "subscription_last_synchronize"
    t.integer  "allow_view",                                  default: 0
    t.integer  "allow_post",                                  default: 0
    t.integer  "allow_comment",                               default: 0
    t.integer  "allow_like",                                  default: 0
    t.boolean  "is_valid",                                    default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",                                   default: true
    t.boolean  "is_coffee",                                   default: false
    t.boolean  "is_invisible",                                default: false
    t.boolean  "is_admin",                                    default: false
  end

  create_table "urls", force: :cascade do |t|
    t.integer  "org_id",                                               null: false
    t.integer  "owner_id",                                             null: false
    t.string   "page_title",  limit: 255
    t.string   "preview_url", limit: 255
    t.boolean  "is_valid",                              default: true
    t.datetime "created_at",              precision: 6
    t.datetime "updated_at",              precision: 6
  end

  create_table "user_analytics", force: :cascade do |t|
    t.integer  "user_id",                             null: false
    t.integer  "action",     limit: 2,                null: false
    t.integer  "org_id"
    t.integer  "length"
    t.integer  "source"
    t.integer  "source_id"
    t.string   "ip_address", limit: 50
    t.datetime "created_at",            precision: 6
    t.datetime "updated_at",            precision: 6
  end

  create_table "user_group_mappings", force: :cascade do |t|
    t.integer  "user_id",                                 null: false
    t.integer  "org_id",                                  null: false
    t.integer  "group_id",                                null: false
    t.boolean  "is_valid",                 default: true
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer  "org_id",                                                     null: false
    t.integer  "owner_id",                                    default: 0,    null: false
    t.integer  "member_count",                                default: 0
    t.string   "group_name",        limit: 255,                              null: false
    t.string   "group_description", limit: 255,                              null: false
    t.integer  "group_avatar_id"
    t.boolean  "is_valid",                                    default: true
    t.datetime "created_at",                    precision: 6
    t.datetime "updated_at",                    precision: 6
  end

  create_table "user_notification_counters", force: :cascade do |t|
    t.integer  "user_id",                                    null: false
    t.integer  "org_id",                                     null: false
    t.datetime "last_fetched",     precision: 6
    t.integer  "newsfeeds",                      default: 0
    t.integer  "announcements",                  default: 0
    t.integer  "events",                         default: 0
    t.integer  "trainings",                      default: 0
    t.integer  "quizzes",                        default: 0
    t.integer  "contacts",                       default: 0
    t.datetime "created_at",       precision: 6
    t.datetime "updated_at",       precision: 6
    t.integer  "safety_trainings",               default: 0
    t.integer  "safety_quiz",                    default: 0
    t.integer  "location_id"
  end

  create_table "user_privileges", force: :cascade do |t|
    t.integer  "owner_id",                                   null: false
    t.integer  "org_id",                                     null: false
    t.boolean  "is_approved",                default: false
    t.boolean  "is_admin",                   default: false
    t.boolean  "read_only",                  default: false
    t.boolean  "is_root",                    default: false
    t.boolean  "is_system",                  default: false
    t.boolean  "is_valid",                   default: true
    t.datetime "created_at",   precision: 6
    t.datetime "updated_at",   precision: 6
    t.integer  "location_id"
    t.boolean  "is_coffee",                  default: false
    t.boolean  "is_invisible",               default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255
    t.string   "number",                 limit: 255
    t.string   "password_hash",          limit: 255
    t.string   "password_salt",          limit: 255
    t.string   "first_name",             limit: 255,                               null: false
    t.string   "last_name",              limit: 255,                               null: false
    t.integer  "gender",                                           default: 0
    t.integer  "user_group",                                       default: 0
    t.integer  "location",                                         default: 0
    t.text     "status",                                           default: ""
    t.string   "chat_handle",            limit: 255
    t.integer  "profile_id"
    t.integer  "cover_id"
    t.integer  "active_org",                                       default: 0
    t.integer  "push_count",                                       default: 0
    t.integer  "access_key_count",                                 default: 0
    t.boolean  "validated",                                        default: false
    t.string   "validation_hash",        limit: 255,                               null: false
    t.string   "auth_token",             limit: 255
    t.string   "password_reset_token",   limit: 255
    t.datetime "password_reset_sent_at",             precision: 6
    t.string   "phone_number",           limit: 255
    t.boolean  "system_user",                                      default: false
    t.boolean  "is_valid",                                         default: true
    t.boolean  "is_visible",                                       default: true
    t.datetime "created_at",                         precision: 6
    t.datetime "updated_at",                         precision: 6
    t.datetime "last_seen_at"
    t.datetime "last_engaged_at"
    t.string   "referral_code",          limit: 255
    t.integer  "shift_count",                                      default: 0
    t.integer  "cover_count",                                      default: 0
    t.integer  "shyft_score",                                      default: 0
    t.datetime "last_recount"
  end

  create_table "videos", force: :cascade do |t|
    t.integer  "org_id",                                                          null: false
    t.integer  "owner_id",                                                        null: false
    t.integer  "comments_count",                                   default: 0
    t.integer  "likes_count",                                      default: 0
    t.integer  "views_count",                                      default: 0
    t.integer  "video_type"
    t.integer  "video_host"
    t.string   "video_url",              limit: 255
    t.string   "video_id",               limit: 255
    t.string   "thumb_url",              limit: 255
    t.integer  "video_duration",                                   default: 0
    t.string   "thumbnail_file_name",    limit: 255
    t.string   "thumbnail_content_type", limit: 255
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at",               precision: 6
    t.string   "video_file_name",        limit: 255
    t.string   "video_content_type",     limit: 255
    t.integer  "video_file_size"
    t.datetime "video_updated_at",                   precision: 6
    t.string   "job_id",                 limit: 255
    t.string   "encoded_state",          limit: 255
    t.string   "output_url",             limit: 255
    t.integer  "duration_in_ms"
    t.string   "aspect_ratio",           limit: 255
    t.boolean  "is_valid",                                         default: true
    t.datetime "created_at",                         precision: 6
    t.datetime "updated_at",                         precision: 6
  end

  create_table "whitelisted_domains", force: :cascade do |t|
    t.integer  "org_id",                                             null: false
    t.string   "domain",     limit: 50,                              null: false
    t.boolean  "is_valid",                            default: true
    t.datetime "created_at",            precision: 6
    t.datetime "updated_at",            precision: 6
  end

end
