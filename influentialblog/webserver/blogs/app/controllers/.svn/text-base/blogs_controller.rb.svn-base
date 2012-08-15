class BlogsController < ApplicationController
  def main
    @fields = ["Sites","WeblogDB"]
  end

  def index
    redirect_to :action => "main" 
  end
  
  def weblog_db
    @weblog = Webdb.statistics
  end
  
  def sites
   @allsites = Site.statistics  
  end

  def sslinks
    @sspairs = Sslink.statistics
  end

  def ssinfectime
    @sstime = Ssinfect.statistics
  end
  
  def search 
  end
  
  def showpostbyid
    @post = Searchpost.searchpostbyid(params[:blog_id])
    render(:partial => "showpostbyid", :layout => false)
  end
  
  def showpostbyurl
    @post = Searchpost.searchpostbyurl(params[:blog_url])
    render(:partial => "showpostbyurl", :layout => false)
  end

  def showlinkbyid 
    @post = Searchpost.searchlinkbyid(params[:link_id])
    render(:partial => "showlinkbyid", :layout => false)
  end

  def showsitebyid
    @post = Searchpost.searchsitebyid(params[:site_id])
    render(:partial => "showsitebyid", :layout => false)
  end
 
  def group
  end

  def showpostbyname
    session[:name] = params[:name]
    @post = Grouppost.groupbyname(params[:name]) 
    render(:partial => "showpostbyname", :layout => false)
  end
  
  def showgraphbyname
    Grouppost.drawgraph(session[:name])
    render(:partial=> "showgraphbyname", :layout => false)
  end
 
  def showimplicitgraph
    Grouppost.drawimplicitgraph(session[:name])
    render(:partial=> "showimplicitgraph", :layout => false)
  end
  def showcompletegraph
    rails_home = File.join(File.dirname(__FILE__),"../..")
    Grouppost.drawcompletegraph(session[:name])
  `dot -Tjpeg "#{rails_home}/public/images/group.dot" -o "#{rails_home}/public/images/completegraph.jpeg" `
    render(:partial=> "showcompletegraph", :layout => false)
  end

  def sort_by_publishdate
   @post = Grouppost.sortbypublishdate(session[:name]) 
   render(:partial => "showpostbyname", :layout => false)
  end

  def sort_by_outlinkcnt
    @post = Grouppost.sortbylinkcnt(session[:name])
    render(:partial => "showpostbyname", :layout => false)      
  end

  def sort_by_comcnt
    @post = Grouppost.sortbycomcnt(session[:name])
    render(:partial => "showpostbyname", :layout => false)
  end

  def showoverlaplinks
    @post = Grouppost.showoverlapoutlinks(session[:name])
    render(:partial => "showoverlaplinks", :layout => false)
  end
 
  def novelty
  end
 
  def showfirstpost
    @fposts = Findfirstpost.searchbylist(params[:rests])
    render(:partial => "showfirstpost", :layout => false)
  end

  def popularity
  end
  
  def showpopbysite  
     @pop = Popmeasure.orderpopbysite(params[:days])
     render(:partial => "orderpopbysite", :layout => false)
  end
  
  def showpopbypost
     @pop = Popmeasure.orderbypost
     render(:partial => "orderpopbypost", :layout => false)
  end

  def coverage 
    @rests = Restaurant.showcoverage
  end
end
