class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/vnd.Expresso.v#{@version}")
  end

#  def matches?(req)
 # 	if req.headers['Accept'] = "application/vnd.eXpresso.v2"
#	    req.headers['Accept'].include?("application/vnd.eXpresso.v#{@version}")
#	else
#		@default
#	end
  #end
end