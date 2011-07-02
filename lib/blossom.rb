require "blossom/version"

require "sass"
require "compass"

require "haml"
require "rack"
require "rack/normalize-domain"
require "sinatra/base"
require "yaml"

begin
  require "rack/coffee"
rescue LoadError
end

module Blossom
  def self.fail(message)
    info "Error: #{message}"
    exit 1
  end

  def self.info(message)
    Kernel.warn "[Blossom] #{message}"
  end
end

def Blossom(root_filename)
  Blossom::Application.new(File.dirname(root_filename))
end

class Blossom::Application < Rack::Builder
  def initialize(root)
    super()

    @root = root

    determine_name!
    load_configuration!
    configure!
    build_rack!
  end

  # --------------------------------------------------------

  def compass_options
    return \
      :cache_dir         => sass_cache_dirname,
      :http_images_path  => "/",
      :images_dir        => @config.public_directory,
      :line_comments     => false,
      :output_style      => :compact,
      :project_path      => @root,
      :sass_dir          => ""
  end

  def coffee_options
    return \
      :cache   => @config.cache_content?,
      :static  => false,
      :ttl     => @config.content_max_age,
      :urls    => "/"
  end

  def haml_options
    return \
      :format        => :html5,
      :attr_wrapper  => '"'
  end

  def sass_options
    Compass.sass_engine_options
  end

  # --------------------------------------------------------

  def determine_name!
    names = glob("*.blossom")
    case names.size
    when 0
      Blossom.fail "Missing configuration file: NAME.blossom"
    when 1
      @name = names[0].sub(/\.blossom$/, '')
    else
      Blossom.fail "Multiple configuration files: #{names * ', '}"
    end
  end

  def load_configuration!
    @config = Configuration.new(configuration_hash)
  end

  def configuration_hash
    case result = YAML.load_file(configuration_filename)
    when false then {} # Empty file.
    when Hash then result
    else Blossom.fail "Bad configuration file: #{configuration_filename}"
    end
  rescue Errno::ENOENT
    {}
  end

  # --------------------------------------------------------

  def configuration_filename
    filename("#@name.blossom") end
  def sinatra_code_filename
    filename("#@name.sinatra.rb") end
  def sass_cache_dirname
    filename("tmp", "sass-cache") end
  def public_dirname
    filename(@config.public_directory) end

  def glob(glob)
    Dir[filename(glob)].map { |name| File.basename(name) } end
  def filename(*components)
    File.join(@root, *components) end

  # --------------------------------------------------------

  def configure!
    compass_options.each do |key, value|
      Compass.configuration.send("#{key}=", value)
    end

    Compass.configure_sass_plugin!

    # XXX: Why do we have to set this manually?
    Sass::Plugin.options[:cache_store] =
      Sass::CacheStores::Filesystem.new(sass_cache_dirname)
  end

  def build_rack!
    use_rack_normalize_domain!
    use_rack_coffee!
    run sinatra_app
  end

  def use_rack_normalize_domain!
    if @config.strip_www?
      use Rack::NormalizeDomain
      Blossom.info "Normalizing domains by removing initial www."
    else
      Blossom.info "Not normalizing domains."
    end
  end

  def use_rack_coffee!
    if defined? Rack::Coffee
      use Rack::Coffee, coffee_options
      Blossom.info "Using CoffeeScript."
    else
      Blossom.info "Not using CoffeeScript."
    end
  end

  def sinatra_app
    app = Sinatra.new
    app.set :blossom, self

    app.set :root, @root
    app.set :index, @name.to_sym

    app.set :views, @root
    app.set :public, public_dirname

    app.set :haml, haml_options
    app.set :sass, sass_options

    # Need variable here for lexical scoping.
    max_age = @config.max_age
    app.before { cache_control :max_age => max_age }

    app.register do
      def path_exists? suffix
        condition do
          basename = File.basename(request.path_info)
          File.exist? File.join(settings.root, "#{basename}.#{suffix}")
        end
      end
  
      def file_exists? suffix
        condition do
          basename = File.basename(request.path_info)
          barename = basename.sub(/\.[^.]*$/, '')
          File.exist? File.join(settings.root, "#{barename}.#{suffix}")
        end
      end
    end

    @config.public_extensions.each do |extension|
      app.get "/:name.#{extension}", :file_exists? => extension do
        send_file "#{params[:name]}.#{extension}"
      end
    end

    app.get "/:name.css", :file_exists? => :sass do
      content_type :css
      sass params[:name].to_sym
    end
  
    app.get "/:name", :path_exists? => :haml do
      haml params[:name].to_sym
    end

    app.get "/" do
      haml settings.index
    end

    if custom_sinatra_code
      app.class_eval(custom_sinatra_code)
    end

    app
  end

  def custom_sinatra_code
    File.read(sinatra_code_filename) rescue nil
  end

  # --------------------------------------------------------

  class Configuration < Struct.new(:user_data)
    DEFAULTS = YAML.load <<"^D"
Public-Directory: public
Public-Extensions: js css html png jpg
Max-Cache-Time: 1 day
Remove-WWW-From-Domain: yes
^D

    def public_directory
      get("Public-Directory").string end
    def strip_www?
      get("Remove-WWW-From-Domain").boolean end
    def max_age
      get("Max-Cache-Time").duration end
    def public_extensions
      get("Public-Extensions").words end

  private

    def get(name)
      if user_data.include? name
        Value.new(user_data[name])
      else
        Value.new(DEFAULTS[name])
      end
    end

    class Value < Struct.new(:value)
      def string
        value.to_s
      end

      def words
        value.gsub(/^\s+|\s$/, "").split(/\s+/)
      end

      def boolean
        if value == true or value == false
          value
        else
          fail "Must be \`yes' or \`no\': #{name}"
        end
      end

      def duration
        if value =~ /^((?:\d+\.)?\d+) ([a-z]+?)s?$/
          $1.to_f * time_unit($2.to_sym)
        else
          error "Bad duration: #{value}"
        end
      end

    private

      def fail(message)
        Blossom.fail "Configuration: #{value}: #{message}"
      end

      def time_unit(name)
        case name
        when :second then 1
        when :minute then 60
        when :hour then 60 * 60
        when :day then 24 * time_unit(:hour)
        when :week then 7 * time_unit(:day)
        when :month then 30 * time_unit(:day)
        when :year then 365 * time_unit(:day)
        else fail "Unknown time unit: #{name}"
        end
      end
    end
  end
end
