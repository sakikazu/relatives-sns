xml.instruct!
 
xml.rss("version"    => "2.0",
        "xmlns:dc"   => "http://purl.org/dc/elements/1.1/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.channel do
    xml.title       @site_title
    xml.link        @site_url
    xml.pubDate     Time.now.rfc822
    xml.description @site_description
    xml.atom :link, "href" => rss2_url, "rel" => "self", "type" => "application/rss+xml"
 
    @contents.each do |content|
      xml.item do
        xml.title        content[:title]
        xml.link         @site_url
        xml.guid         @site_url
        xml.description  content[:description]
        xml.pubDate      content[:created_at].to_formatted_s(:rfc822)
        xml.dc :creator, @author
      end
    end
  end
end
