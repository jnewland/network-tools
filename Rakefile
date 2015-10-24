require "nokogiri"

# Grab traceroutes from a few random sites on the internet
@targets = %w(
  google.com
  yahoo.com
  s3.amazonaws.com
  amazon.com
  cnn.com
  github.com
  etsy.com
)

if ENV["TARGETS"]
  @targets = ENV["TARGETS"].split(",")
end

task :nmap => ["GeoIPASNum.dat"] do
  `sudo nmap -sn --traceroute #{@targets.join(" ")} -oX nmap.xml`
  # parse the file
  f = File.open("nmap.xml")
  @doc = Nokogiri::XML(f)
  f.close

  # do some parsing that we want anytime we use this
  @ip_count = Hash.new(0)
  @hostname_count = Hash.new(0)
  @hostnames = {}
  @ip_network = {}
  @hostname_network = {}

  # pull all the hops out of it
  hops = @doc.xpath("//hop").each do |h|
    ip = h["ipaddr"]
    @ip_count[ip] += 1
    @hostnames[ip] = host = h["host"] || ip
    @hostname_count[host] += 1
    @ip_network[ip] = `geoiplookup -d . #{h["ipaddr"]} | cut -f 2 -d : | awk '{print $1}'`.chomp!
    @hostname_network[host] = @ip_network[ip]
  end
end

desc "Generate magic"
task :smokeping => [:nmap] do
  # do some setup
  puts "+ ISP"
  puts "menu = ISP"
  puts "title = ISP"
  puts ""

  # include all hops in more than half
  common_ips = @ip_count.select do |k,v|
    v > (@targets.length / 2)
  end

  # output config
  common_ips.each do |i,_v|
    title = @hostnames[i] || i
    title = title.gsub(/\./, '-')
    puts "++ #{title}"
    puts "menu = #{title}"
    puts "title = #{title}"
    puts "host = #{i}"
    puts ""
  end
end

desc "Generate a diagram"
task :dot => [:nmap] do
  edges = []
  hops = []
  File.open("graph.dot", 'w') do |dotfile|
    dotfile.write "digraph G {\n"

    @doc.xpath("//trace").each do |t|
      trace_hops = []
      t.xpath("//hop").each do |h|
        ip = h["ipaddr"]
        hop = @hostnames[ip] || ip
        if previous_hop = trace_hops.last
          edges << "\"#{previous_hop}\" -> \"#{hop}\";"
        end
        trace_hops << hop
        hops << hop
      end
    end

    edges.uniq.each do |edge|
      dotfile.write "#{edge}\n"
    end
    hops.uniq.each do |hop|
      dotfile.write "\"#{hop}\" [fontsize = #{12+(@hostname_count[hop]*10)}];\n"
    end

    dotfile.write "graph [rankdir=TB];\n"
    dotfile.write "}\n"
  end
end

file "GeoIPASNum.dat.gz" do
  `test -f GeoIPASNum.dat.gz || wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz`
end

file "GeoIPASNum.dat" => ["GeoIPASNum.dat.gz"] do
  `test -f GeoIPASNum.dat || gunzip GeoIPASNum.dat.gz`
end
