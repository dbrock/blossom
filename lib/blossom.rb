require "rubygems"
require "rack"

module Blossom
  VERSION = "1.0.0alpha3"
end

def Blossom(root_file)
  require "compass" # Load before sinatra.
  require "sinatra/base"
  require "haml" # Load after sinatra.
  require "rack/normalize-domain"
  require "hassle"
  
  begin
    require "rack/coffee"
  rescue LoadError
  end

  Blossom::Application.new(File.dirname(root_file))
end

class Blossom::Application < Rack::Builder
  def initialize(root)
    super()

    @root = root
    @name = get_application_name
    @config = get_config

    build!
  end

  def get_application_name
    names = glob(@root, "*.blossom")
    case names.size
    when 0
      error "Missing configuration file: NAME.blossom"
    when 1
      names[0].sub(/\.blossom$/, '')
    else
      error "Multiple configuration files: #{names * ', '}"
    end
  end

  def glob(root, glob)
    Dir[File.join(root, glob)].map { |name| File.basename(name) }
  end

  def build!
    use Hassle
    use_normalize_domain!
    use_coffee!
    run get_app
  end

  def use_normalize_domain!
    if @config.normalize_domains?
      use Rack::NormalizeDomain
      status "Normalizing domains by removing initial www."
    else
      status "Not normalizing domains."
    end
  end

  def use_coffee!
    if defined? Rack::Coffee
      use Rack::Coffee, coffee_options
      status "Using CoffeeScript."
    else
      status "Not using CoffeeScript."
    end
  end

  def error(message) fail "Blossom: Error: #{message}" end
  def status(message) warn "Blossom: #{message}" end

  def coffee_options
    {
      :static => false,
      :urls => "/",
      :cache => @config.cache_content?,
      :ttl => @config.content_max_age
    }
  end

  def get_config
    Configuration.new(get_config_hash)
  end

  def get_config_hash
    case result = YAML.load_file(config_file_name)
    when false: {} # Empty file.
    when Hash: result
    else error "Bad configuration file: #{config_file_name}"
    end
  rescue Errno::ENOENT
    {}
  end

  def config_file_name; application_file_name("blossom") end
  def sinatra_file_name; application_file_name("sinatra.rb") end
  def sass_cache_location; file_name("tmp", "sass-cache") end
  def static_location; file_name("static") end

  def application_file_name(extension)
    file_name("#@name.#{extension}")
  end

  def custom_sinatra_code
    File.read(sinatra_file_name) rescue nil
  end

  def file_name(*components)
    File.join(@root, *components)
  end

  def configure_compass!
    config = Compass.configuration
    config.project_path = @root
    config.sass_dir = ""
    config.images_dir = "static"
    config.http_images_path = "/"
    config.output_style = :compact
    config.line_comments = false
  end

  def sass_options
    Compass.sass_engine_options.merge \
      :cache_location => sass_cache_location
  end

  def haml_options
    { :format => :html5, :attr_wrapper => '"' }
  end

  def get_app
    blossom_config = @config

    app = Class.new(Sinatra::Base)
    app.extend SinatraHelpers

    app.set :root, @root
    app.set :index, @name.to_sym

    app.set :views, @root
    app.set :public, static_location

    app.set :haml, haml_options
    app.set :sass, sass_options

    if blossom_config.cache_content?
      app.before do
        cache_control \
          :max_age => blossom_config.content_max_age
      end
    end

    app.get "/" do
      haml settings.index
    end
  
    app.get "/:name.js", :file_exists? => :js do
      content_type "text/javascript", :charset => "utf-8"
      send_file "#{params[:name]}.js"
    end
  
    app.get "/:name.css", :file_exists? => :sass do
      content_type "text/css", :charset => "utf-8"
      sass params[:name].to_sym
    end
  
    app.get "/:name", :path_exists? => :haml do
      haml params[:name].to_sym
    end

    app.class_eval(custom_sinatra_code) if custom_sinatra_code

    return app
  end

  module SinatraHelpers
    def path_exists? suffix
      condition do
        basename = File.basename(request.path)
        File.exist? File.join(settings.root, "#{basename}.#{suffix}")
      end
    end

    def file_exists? suffix
      condition do
        basename = File.basename(request.path)
        barename = basename.sub(/\.[^.]*$/, '')
        File.exist? File.join(settings.root, "#{barename}.#{suffix}")
      end
    end
  end

  class Configuration
    def initialize(yaml)
      @yaml = yaml
    end

    def normalize_domains?
      case @yaml["Normalize-Domains"]
      when nil, true: true
      when false: false
      else fail "Blossom: Configuration error: Normalize-Domains"
      end
    end

    def cache_content?
      content_max_age != nil
    end

    def content_max_age
      parse_duration(@yaml["Content-Max-Age"])
    end

    def parse_duration(input)
      case input
      when nil
        nil
      when /^((?:\d+\.)?\d+) ([a-z]+?)s?$/
        $1.to_f * time_unit($2.to_sym)
      else
        fail "Bad duration: #{input}"
      end
    end

    def time_unit(name)
      case name
      when :second: 1
      when :minute: 60
      when :hour: 60 * 60
      when :day: 24 * time_unit(:hour)
      when :week: 7 * time_unit(:day)
      when :month: 30 * time_unit(:day)
      when :year: 365 * time_unit(:day)
      else fail "Bad time unit: #{name}"
      end
    end
  end
end
