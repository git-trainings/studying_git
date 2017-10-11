require "webrick"
require "net/http"

include WEBrick
SERVER_NAME = "test.gomasy.jp"

class ProxyServlet < HTTPServlet::AbstractServlet
  @@ignore = [ "connection", "transfer-encoding", "via", "x-cache", "x-cache-lookup", "x-squid-error" ]
  @@rewrite = [ "ニコニコ", "プレミアム", "オススメ", "niconico", "けものフレンズ", "けもフレ" ]

  def do_GET(req, res)
    proxy = Net::HTTP::Proxy('localhost', 3128)
    http = req.host != SERVER_NAME ? proxy.new(req.host) : Net::HTTP.new("localhost", 8080)
    fwd_res = http.get(req.path, req.header.each{|k, v| req.header[k] = v.kind_of?(String) ? v : v[0]})
    fwd_res.header.each do |h|
      f = true
      @@ignore.each do |e|
        f = false if e == h.downcase
      end
      res[h] = fwd_res[h] if f
    end
    res.status = fwd_res.code
    if !fwd_res.body.nil? && (fwd_res.body.include?("utf-8") || fwd_res.body.include?("UTF-8"))
      @@rewrite.each do |e|
        fwd_res.body.force_encoding("utf-8").gsub!(e, "ちんこ")
      end
    end
    res.body = fwd_res.body
  end
end

srv = WEBrick::HTTPServer.new(:Port => 80)
srv.mount("/", ProxyServlet)
srv.start
