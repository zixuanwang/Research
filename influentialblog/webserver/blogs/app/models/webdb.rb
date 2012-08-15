class Webdb < ActiveRecord::Base
  
  def self.statistics
    st = Hash.new
    sql =<<-SQL
      show table status
    SQL
    status = connection.select_all(sql)
    sum = 0
    status.each do |each_table|
     sum = sum + each_table['Data_length'].to_i + each_table['Index_length'].to_i
    end
    st["size"] = sum/1024/1024
    
    tables = ""
    status.each do |each_table|
      if each_table["Name"].strip !="schema_migrations"
        tables = tables + each_table["Name"].to_s.strip + " "
      end
    end
    st["tables"] = tables  
    sql =<<-SQL
      select count(id) as ids from blogs 
    SQL
    st["posts"] = connection.select_all(sql)[0]['ids']
    
    sql =<<-SQL
      select count(id) as ids from outlinks 
    SQL
    st["outlinks"] = connection.select_all(sql)[0]['ids']

    sql =<<-SQL
      select count(id) as ids from comments
    SQL

    st["comments"] = connection.select_all(sql)[0]['ids']
  return st
  end
end
