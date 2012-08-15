
def normalize_url(url)
   url_char = {
  '%20' => ' ',
  '%2F' => '/',
  '%3A' => ':',
  '%3F' => '?',
  '%e2%80%99' => '\''
   }

  url_char.each do |key, value|
    url.gsub!(key,value)
  end
 
end

urls = File.open("badurls","r+")
while line=urls.gets
  normalize_url(line)
  puts line
  
end

