require 'rubygems'
require 'hpricot'
require 'activerecord'
require 'open-uri'


#script_url = "http://identity.eater.com/topics/96087/comments.js?update=entry-96087-comments&open=1"
script_url = "http://identity.eater.com/topics/72176/comments.js?update=entry-72176-comments&open=1"
if !script_url.empty?
    comments = open(script_url).read;
    comments = comments[comments.index("\\")  ... comments.rindex("\"")].gsub("\\u003C", "<").gsub("\\u003E", ">")
    comments.gsub!("\\\"","\"");
    comments.gsub!("\\n", "");
    comments.gsub!("\\t", "");

    print "comments:****************\n"
    #puts comments

    comments_array = []
    comment_html = Hpricot(comments);
    comment_html.search("//div[@class='comment ']").each do |comment_entry|
      comments_array_entry = {}
      print "\n"
      comments_array_entry[:content] = comment_entry.at("//div[@class='comment-body']/p").inner_text.gsub("\"","\\\"")
      #comments_array_entry[:user] = comment_entry.at("//div[@class='comment-who']/a").attributes["alt"];
      if comment_entry.at("//div[@class='comment-who']/span[@class='tag user-name']").nil?
        comments_array_entry[:user] = comment_entry.at("//div[@class='comment-who']/a").attributes["alt"];
      else
        comments_array_entry[:user] = comment_entry.at("//div[@class='comment-who']/span[@class='tag user-name']").inner_text
      end
      comments_array_entry[:date] = comment_entry.search("//div[@class='comment-when']/a")[1].inner_text;
      comments_array << comments_array_entry;
    end
  end
  
  comments_array.each do |each_comment|
    puts each_comment[:user]
    puts each_comment[:date]
    puts each_comment[:content]
  end

