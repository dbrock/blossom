require "rubygems"
require "sinatra/base"
require "haml"
require "sass"
require "compass"

def Blossom(config_file, index = :index)
  root = File.dirname(config_file)
  app = Class.new(Sinatra::Base)
  app.class_eval do
    configure do
      set :public, root
      set :views, root
      set :index, index
  
      Compass.configuration do |config|
        config.project_path = root
        config.sass_dir = ""
        config.images_dir = "static"
        config.http_images_path = "/"
        config.output_style = :compact
        config.line_comments = false
      end
  
      set :haml, { :format => :html5, :attr_wrapper => '"' }
      set :sass, Compass.sass_engine_options
    end
  
    get "/" do
      haml settings.index
    end
  
    get "/:name.css" do
      content_type "text/css", :charset => "utf-8"
      sass params[:name].to_sym
    end

    for file_name in Dir[File.join(root, "*.haml")]
      name = File.basename(file_name).sub(/\.haml$/, "")
      get "/#{name}" do
        haml name.to_sym
      end
    end
  end

  app
end
