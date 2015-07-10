require "nokogiri"

# Grab traceroutes from a few random sites on the internet
@targets = %w(
  google.com
  yahoo.com
  s3.amazonaws.com
  amazon.com
  cnn.com
  github.com
)

task :nmap do
  `sudo nmap -sn --traceroute #{@targets.join(" ")} -oX nmap.xml`
  # parse the file
  f = File.open("nmap.xml")
  @doc = Nokogiri::XML(f)
  f.close
end

desc "Generate magic"
task :smokeping => [:nmap] do
  # do some setup
  ip_count = Hash.new(0)
  hostnames = {}
  puts "+ ISP"
  puts "menu = ISP"
  puts "title = ISP"
  puts ""

  # pull all the hops out of it
  hops = @doc.xpath("//hop").each do |h|
    ip_count[h["ipaddr"]] += 1
    hostnames[h["ipaddr"]] = h["host"]
  end

  # include all hops in more than half
  common_ips = ip_count.select do |k,v|
    v > (targets.length / 2)
  end

  # output config
  common_ips.each do |i,_v|
    title = hostnames[i] || i
    title = title.gsub(/\./, '-')
    puts "++ #{title}"
    puts "menu = #{title}"
    puts "title = #{title}"
    puts "host = #{i}"
    puts ""
  end
end
