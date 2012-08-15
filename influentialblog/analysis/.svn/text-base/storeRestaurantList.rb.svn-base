require "rubygems"
require "activerecord"
class DBConnection < ActiveRecord::Base
end
DBConnection.establish_connection(:adapter => "mysql",       
                                  :host => "pierce.rutgers.edu",
                                  :username => "root",   
                                  :password => "",
                                  :database => "Weblog_development")

def createTable()
  sql =<<-SQL
    create table restaurants (id int auto_increment primary key, name varchar(255), category varchar(255), update_time timestamp)
  SQL
  DBConnection::connection.execute(sql)
end

def loadtodb(filename)
  rfile = File.open("#{filename}", "r")
  larray = Array.new
  while (line = rfile.gets)
    larray = line.split("##")
    puts larray[0]
    puts larray[1]
    sql =<<-SQL
      insert into restaurants(name, category) values("#{larray[1].strip}","#{larray[0].strip}")
    SQL
    DBConnection::connection.execute(sql)
  end
end

createTable()
loadtodb("restaurantList")
