require "rubygems"

require "compass" # Load before sinatra.
require "sinatra/base"
require "haml" # Load after sinatra.
require "rack/strip-www"
require "hassle"

module Blossom
  VERSION = "0.0.6"
end

def Blossom(root_file, index = :index, options = {})
  Rack::Builder.app do
    use Rack::StripWWW
    use Hassle
    run Blossom::Base(root_file, index, options)
  end
end

def Blossom::Base(root_file, index = :index, blossom_options = {})
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
        Compass.configuration.output_style = :compact
        Compass.configuration.line_comments = false
        
        sass_options = Compass.sass_engine_options.merge \
          :cache_location => "#{root}/tmp/sass-cache"
        
        set :sass, sass_options
      end
    
      get "/" do
        headers blossom_headers
        haml settings.index
      end
  
      get "/:name.css", :file_exists? => :sass do
        headers blossom_headers
        content_type "text/css", :charset => "utf-8"
        sass params[:name].to_sym
      end
  
      get "/:name", :file_exists? => :haml do
        headers blossom_headers
        haml params[:name].to_sym
      end
      
      define_method :blossom_headers do
        if blossom_options.include? :cache
          seconds = get_seconds(*blossom_options[:cache])
          { 'Cache-Control' => "public, max-age=#{seconds}" }
        else
          {}
        end
      end

      def get_seconds(value, unit)
        days = 60 * 60 * 24
        case unit
        when :seconds, :second
          value
        when :minutes, :minute
          value * 60
        when :hours, :hour
          value * 60 * 60
        when :days, :day
          value * days
        when :weeks, :week
          value * days * 7
        when :months, :month
          value * days * 30
        when :years, :year
          value * days * 365
        else
          raise ArgumentError, "Unrecognized unit: #{unit}"
        end
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
