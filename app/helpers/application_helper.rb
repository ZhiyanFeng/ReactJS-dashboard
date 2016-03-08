module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
  	base_title = "Coffee Mobile"
  	if page_title.empty?
  		base_title
  	else
  		"#{base_title} | #{page_title}"
  	end
  end

  def active_if(url1, url2="", url3="")
  	if current_page?(url1) or current_page?(url2) or current_page?(url3)
  		'nav-active'
  	end
  end

  def active_sub_if(actionName)
    if current_page?(url_for(:controller => 'events'))
      "db-events-button active"
    #elsif current_page?(url_for(:controller => 'dashboard', :action => actionName))
      #"db-" + actionName + "-button active"
    else
      "db-" + actionName + "-button"
    end
  end

  def active_sub_iff(actionName)
    if current_page?(url_for(:action => actionName))
      "db-" + actionName + "-button active"
    else
      "db-" + actionName + "-button"
    end
  end

  def active_sidenav(actionName)
    if current_page?(url_for(:action => actionName))
      "active"
    else
      ""
    end
  end

  def make_act(controller_name, action_name)
    if current_page?(url_for(:controller => controller_name, :action => action_name))
      "active"
    else
      ""
    end
  end

  def make_active(url)
    #if current_page?(url_for(:controller => controller_name, :action => action_name))
    if current_page?(url)
      "active"
    else
      ""
    end
  end

  def nav_link(link_text, page)
    class_name = link_text == page ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, page
    end
  end

  def parse_youtube url
     regex = /(?:.be\/|\/watch\?v=|\/(?=p\/))([\w\/\-]+)/
     url.match(regex)[1]
  end

  def parse_hour(file)
    users = {}
    posts = {}
    messages = {}
    likes = {}
    users["total"] = 0
    posts["total"] = 0
    messages["total"] = 0
    likes["total"] = 0

    regex_new_user = /\[(\d{4}\-\d{2}\-\d{2}\s\d{2})\:\d{2}\:\d{2}\.\d{3}\]\s\[INFO\]\s\[users.join_org\]\s(\d*)\sjoined\s(\d*)./
    regex_new_post = /\[(\d{4}\-\d{2}\-\d{2}\s\d{2})\:\d{2}\:\d{2}\.\d{3}\]\s\[INFO\]\s\[posts.create\]\s(\d*)\s(\d*)\s([a-zA-Z]*)./
    regex_new_message = /\[(\d{4}\-\d{2}\-\d{2}\s\d{2})\:\d{2}\:\d{2}\.\d{3}\]\s\[INFO\]\s\[chat.message\]\s(\d*)\s(\d*)\s(\d*)./
    regex_new_like = /\[(\d{4}\-\d{2}\-\d{2}\s\d{2})\:\d{2}\:\d{2}\.\d{3}\]\s\[INFO\]\s\[[a-z]*.like\]\s(\d*)\s(\d*)\s(\d*)./
    File.open( file ).each do |line|

      ##### If line matches new user join org START #####
      if regex_new_user =~ line
        users["total"] = users["total"] + 1
        date, uid, oid = line.match(regex_new_user).captures
        if users[date+":00:00"].nil?
          users[date+":00:00"] = 1
        else
          users[date+":00:00"] = users[date+":00:00"] + 1
        end
      end
      ##### If line matches new user join org END #####

      ##### If line matches new post created START #####
      if regex_new_post =~ line
        posts["total"] = posts["total"] + 1
        date, oid, uid, feed = line.match(regex_new_post).captures
        if posts[date+":00:00"].nil?
          posts[date+":00:00"] = 1
        else
          posts[date+":00:00"] = posts[date+":00:00"] + 1
        end
      end
      ##### If line matches new post created END #####

      ##### If line matches new message created START #####
      if regex_new_message =~ line
        messages["total"] = messages["total"] + 1
        date, oid, sid, rid = line.match(regex_new_message).captures
        if messages[date+":00:00"].nil?
          messages[date+":00:00"] = 1
        else
          messages[date+":00:00"] = messages[date+":00:00"] + 1
        end
      end
      ##### If line matches new message created END #####

      ##### If line matches new like created START #####
      if regex_new_like =~ line
        likes["total"] = likes["total"] + 1
        date, oid, uid, lid = line.match(regex_new_like).captures
        if likes[date+":00:00"].nil?
          likes[date+":00:00"] = 1
        else
          likes[date+":00:00"] = likes[date+":00:00"] + 1
        end
      end
      ##### If line matches new like created END #####

    end

    result = {}
    result["users"] = users
    result["posts"] = posts
    result["messages"] = messages
    result["likes"] = likes

    result
  end

  def parse_half_hour(file)
    users = {}
    posts = {}
    messages = {}
    likes = {}
    users["total"] = 0
    posts["total"] = 0
    messages["total"] = 0
    likes["total"] = 0

    regex_new_user = /\[(\d{4}\-\d{2}\-\d{2})\s(\d{2})\:\d{2}\:\d{2}\.\d{3}\]\s\[INFO\]\s\[users.join_org\]\s(\d*)\sjoined\s(\d*)./
    regex_new_post = /\[(\d{4}\-\d{2}\-\d{2})\s(\d{2})\:\d{2}\:\d{2}\.\d{3}\]\s\[INFO\]\s\[posts.compose\]\s(\d*)\s(\d*)\s([a-zA-Z]*)./
    regex_new_message = /\[(\d{4}\-\d{2}\-\d{2})\s(\d{2})\:\d{2}\:\d{2}\.\d{3}\]\s\[INFO\]\s\[chat.message\]\s(\d*)\s(\d*)\s(\d*)./
    regex_new_like = /\[(\d{4}\-\d{2}\-\d{2})\s(\d{2})\:\d{2}\:\d{2}\.\d{3}\]\s\[INFO\]\s\[[a-z]*.like\]\s(\d*)\s(\d*)\s(\d*)./
    File.open( file ).each do |line|

      ##### If line matches new user join org START #####
      if regex_new_user =~ line
        users["total"] = users["total"] + 1
        date, time, uid, oid = line.match(regex_new_user).captures
        if users[date].nil?
          users[date] = {}
          users[date]["total"] = 1
          users[date][time] = 1
        else
          users[date]["total"] = users[date]["total"] + 1
          if users[date][time].nil?
            users[date][time] = 1
          else
            users[date][time] = users[date][time] + 1
          end
        end
      end
      ##### If line matches new user join org END #####

      ##### If line matches new post created START #####
      if regex_new_post =~ line
        posts["total"] = posts["total"] + 1
        date, time, oid, uid, feed = line.match(regex_new_post).captures
        if posts[date].nil?
          posts[date] = {}
          posts[date]["total"] = 1
          posts[date][time] = 1
        else
          posts[date]["total"] = posts[date]["total"] + 1
          if posts[date][time].nil?
            posts[date][time] = 1
          else
            posts[date][time] = posts[date][time] + 1
          end
        end
      end
      ##### If line matches new post created END #####

      ##### If line matches new message created START #####
      if regex_new_message =~ line
        messages["total"] = messages["total"] + 1
        date, time, oid, sid, rid = line.match(regex_new_message).captures
        if messages[date].nil?
          messages[date] = {}
          messages[date]["total"] = 1
          messages[date][time] = 1
        else
          messages[date]["total"] = messages[date]["total"] + 1
          if messages[date][time].nil?
            messages[date][time] = 1
          else
            messages[date][time] = messages[date][time] + 1
          end
        end
      end
      ##### If line matches new message created END #####

      ##### If line matches new like created START #####
      if regex_new_like =~ line
        likes["total"] = likes["total"] + 1
        date, time, oid, uid, lid = line.match(regex_new_like).captures
        if likes[date].nil?
          likes[date] = {}
          likes[date]["total"] = 1
          likes[date][time] = 1
        else
          likes[date]["total"] = likes[date]["total"] + 1
          if likes[date][time].nil?
            likes[date][time] = 1
          else
            likes[date][time] = likes[date][time] + 1
          end
        end
      end
      ##### If line matches new like created END #####
    end
    result = {}
    result["users"] = users
    result["posts"] = posts
    result["messages"] = messages
    result["likes"] = likes

    result
  end
end
