require "rubygems"
require "sinatra/base"
require "haml"
require "sass"
require "compass"

def Blossom(config_file, index = :index)
  root = File.dirname(config_file)
  Class.new(Sinatra::Base).tap do |app|
    app.class_eval do
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
      end
    
      get "/" do
        haml settings.index
      end
  
      def self.file_exists? suffix
        condition do
          basename = File.basename(request.path)
          barename = basename.sub(/\.[^.]*$/, '')
          name = "#{barename}.#{suffix}"
          File.exist? File.join(settings.root, name)
        end
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
