require "nokogiri"

if ENV["TARGETS"]
  @targets = ENV["TARGETS"].split(",")
else
  country = `curl -s ipinfo.io  | jq -r '.country'`
  alexa = `curl -s https://www.alexa.com/topsites/countries/#{country}`
  @targets = alexa.scan(/"\/siteinfo\/(.*)"/).flatten
end

file "out/nmap.xml" do
  `nmap -sn --traceroute #{@targets.join(" ")} -oX out/nmap.xml`
end

task :nmap => ["out/nmap.xml"] do
  # parse the file
  f = File.open("out/nmap.xml")
  @doc = Nokogiri::XML(f)
  f.close

  # do some parsing that we want anytime we use this
  @ip_count = Hash.new(0)
  @hostnames = {}
  @ip_network = {}

  # pull all the hops out of it
  hops = @doc.xpath("//hop").each do |h|
    ip = h["ipaddr"]
    @ip_count[ip] += 1
    @hostnames[ip] = host = h["host"] || ip
    @ip_network[ip] = `geoiplookup #{h["ipaddr"]} | grep ASNum | cut -f 2 -d : | grep -v "not found"`.strip
  end
end

desc "Generate a diagram"
task :dot => [:nmap] do
  edges = []
  hops = []
  File.open("out/graph.dot", 'w') do |dotfile|
    dotfile.write "digraph G {\n"

    @doc.xpath("//trace").each do |t|
      trace_hops = []
      next if t.xpath("hop").length == 2
      t.xpath("hop").each do |h|
        ip = h["ipaddr"]
        next if @ip_network[ip] == ""
        hop = @hostnames[ip] || ip
        hop += " / #{@ip_network[ip]}"
        if hop != hops.first
          if previous_hop = trace_hops.last
            edges << "\"#{previous_hop}\" -> \"#{hop}\";"
          end
        end
        trace_hops << hop
        hops << hop
      end
    end

    edges.uniq.each do |edge|
      dotfile.write "#{edge}\n"
    end
    hops.uniq.each do |hop|
      dotfile.write "\"#{hop}\" [fontsize = #{12+(@ip_count[hop]*10)}];\n"
    end

    dotfile.write "graph [rankdir=TB];\n"
    dotfile.write "}\n"
  end
end

task :graph => [:dot] do
  `dot -Tpng out/graph.dot > out/graph.png`
end

task :clean do
  `rm -f out/graph.* out/nmap.xml`
end
