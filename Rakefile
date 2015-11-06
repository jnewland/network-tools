require "nokogiri"

if ENV["TARGETS"]
  @targets = ENV["TARGETS"].split(",")
else
  country = `curl -s ipinfo.io  | jq -r '.country'`
  alexa = `curl -s http://www.alexa.com/topsites/countries/#{country}`
  @targets = alexa.scan(/"\/siteinfo\/(.*)"/).flatten
end

file "nmap.xml" => ["GeoIPASNum.dat"] do
  `sudo nmap -sn --traceroute #{@targets.join(" ")} -oX nmap.xml`
end

task :nmap => ["nmap.xml"] do
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

task :graph => [:dot] do
  `dot -Tpng graph.dot > graph.png`
end

file "GeoIPASNum.dat.gz" do
  `test -f GeoIPASNum.dat.gz || curl -s http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz > GeoIPASNum.dat.gz`
end

file "GeoIPASNum.dat" => ["GeoIPASNum.dat.gz"] do
  `test -f GeoIPASNum.dat || gunzip GeoIPASNum.dat.gz`
end

task :clean do
  `rm -f graph.dot graph.png GeoIPASNum.dat.gz GeoIPASNum.dat nmap.xml`
end
