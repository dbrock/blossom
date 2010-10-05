require "rubygems"

require "compass" # Load before sinatra.
require "sinatra/base"
require "haml" # Load after sinatra.
require "rack-strip-www"
require "hassle"

module Blossom ; end

def Blossom(root_file, index = :index)
  Rack::Builder.app do
    use RackStripWWW
    use Hassle
    run Blossom::Base(root_file, index)
  end
end

def Blossom::Base(root_file, index = :index)
  root = File.dirname(root_file)
  Class.new(Sinatra::Base).tap do |app|
    app.class_eval do
      extend Blossom::Helpers

      configure do
        set :root, root
        set :public, "#{root}/static"
        set :views, root
        set :index, index
        set :haml, { :format => :html5, :attr_wrapper => '"' }
    
        Compass.configuration.project_path = root
        Compass.configuration.sass_dir = ""
        Compass.configuration.images_dir = "static"
        Compass.configuration.http_images_path = "/"
        
        sass_options = Compass.sass_engine_options.merge \
          :cache_location => "#{root}/tmp/sass-cache"
        
        set :sass, sass_options
      end
    
      get "/" do
        haml settings.index
      end
  
      get "/:name.css", :file_exists? => :sass do
        content_type "text/css", :charset => "utf-8"
        sass params[:name].to_sym
      end
  
      get "/:name", :file_exists? => :haml do
        haml params[:name].to_sym
      end
    end
  end
end

module Blossom::Helpers
  def file_exists? suffix
    condition do
      basename = File.basename(request.path)
      barename = basename.sub(/\.[^.]*$/, '')
      name = "#{barename}.#{suffix}"
      File.exist? File.join(settings.root, name)
    end
  end
end
