# based on http://freelancing-gods.com/posts/versioning_your_ap_is
# curl -H "Accept: vnd.myapp+json; version=2"
class ApiVersion
  def initialize(version)
    @version = version
  end
 
  def matches?(request)
    versioned_accept_header?(request) || @version == 1
  end
 
  private
 
  def versioned_accept_header?(request)
    accept = request.headers['Accept']
 
    if accept
      mime_type, version = accept.gsub(/\s/, "").split(";")
      mime_type.match(/vnd\.myapp\+json/) && version == "version=#{@version}"
    end
  end
end