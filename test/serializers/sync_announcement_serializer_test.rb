require 'test_helper'

class SyncAnnouncementSerializerTest < ActionController::TestCase

	setup do
		announcement = Post.where(:post_type => 1, :is_valid => true).last
		@announcement = SyncAnnouncementSerializer.new(announcement, root: false)
	end

  test "Result should contain id" do
    @announcement[:id].present?
  end
end


#:id,:org_id,:owner_id,:title,:content,:comments_count,:likes_count,:views_count,:liked,
#:flagged,:created_at,:updated_at,:attachment,:organization,:is_valid