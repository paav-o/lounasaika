# encoding: utf-8

# rubygems
require "rubygems"

# stdlib
require "active_support/core_ext/string"
require "benchmark"
require "fileutils"
require "json"
require "open-uri"
require "rake"
require "time"
require "yaml"

# 3rd party
require "bing_translator"
require "nokogiri"
require "pdf/reader"
#require "middleman-gh-pages"

# scraper libraries
Dir.glob("lib/*.rb").each { |file| import file }

CREDENTIALS = YAML.load_file("config/credentials.yml")

#############################################################################
#
# Standard tasks
#
#############################################################################

desc "Update menus for all restaurants and save as json"
task :update do
  archive_path = "archive/#{Date.today.to_s}.json"
  api_path = "source/api/v1/"

  total_time = Benchmark.realtime do
    restaurants = YAML.load_file("config/restaurants.yml")
    restaurants.each do |restaurant|
      time = Benchmark.realtime do
        begin
          scraper = to_module(restaurant["name"])
        rescue
          puts colorize("Couldn't find scraper file for #{restaurant["name"]}!", 31)
        end
        begin
          data = {}
          data["fi"] = load_with_nokogiri(restaurant["url"]["fi"])
          data["en"] = load_with_nokogiri(restaurant["url"]["en"]) if restaurant["url"]["en"].present?
        rescue
          puts colorize("Couldn't download menu for #{restaurant["name"]}!", 31)
        end
        #begin
          data = load_with_nokogiri(restaurant["url"]["fi"])
          scraper = to_module(restaurant["name"])

          meals = {"fi" => [], "en" => []}
          restaurant["meals"] = scraper.get_meals(data, meals)

          restaurant = add_translations(restaurant)
        #rescue
        #  puts colorize("Couldn't process meals for #{restaurant["name"]}!", 31)
        #end
      end
      puts "#{restaurant["name"]} processed (#{time.round(2)})"
    end

    %w(fi en).each do |locale|
      other_locale = %w(fi en).delete_if{|l| l.eql? locale}.first
      stripped_version = Marshal.load(Marshal.dump(restaurants.freeze))
      stripped_version.each{|r| r["meals"] = r["meals"].tap { |hs| hs.delete(other_locale) }}
      File.open(api_path+locale+"/menus.json", "w+") {|f| f.write(stripped_version.to_json) }
    end

    File.open(archive_path, "w+") {|f| f.write(restaurants.to_json) }
    
  end
  puts colorize("Menus saved to #{api_path}", 32) + " (total #{total_time.round(2)})"
end


desc "Add new restaurant"
task :new_restaurant do
  restaurant = {}
  puts "Name of restaurant [Unicafe Ylioppilasaukio]:"
  restaurant["name"] = STDIN.gets.chomp
  puts "Street address [Mannerheimintie 3, Helsinki]:"
  restaurant["address"] = STDIN.gets.chomp
  puts "Campus [Keskusta]:"
  restaurant["campus"] = STDIN.gets.chomp
  puts "Opening times [Mon-Thu 10:30-16:00, Fri 10:30-15:00]:"
  restaurant["open"] = STDIN.gets.chomp
  puts "Menu url [http://www.unicafe.fi/index.php/Keskusta/Ylioppilasaukio]:"
  restaurant["url"] = STDIN.gets.chomp
  puts "Save restaurant? [Y/n]"
  if STDIN.gets.chomp.eql? "Y"
    restaurant = add_location(restaurant)
    File.open("config/restaurants.yml", "a+") {|f| f.write([restaurant].to_yaml.gsub("---", "")) }

    module_template = "class #{to_module_name(restaurant['name'])}\n  def self.get_meals(data)\n    # scraping goes here\n    # return meals\n  end\nend"
    file_name = to_filename(restaurant['name'])
    file_path = "lib/#{file_name}"
    File.open(file_path, "w") {|f| f.write(module_template) }
    
    puts colorize("New restaurant saved to restaurants.yml!", 32)
    puts colorize("  1) Now open and edit #{file_path}", 32)
    puts colorize("  2) Once done, run: rake test[#{file_name}]", 32)
  else
    puts colorize("Restaurant was not saved.", 31)
  end
end


desc "Test menu scraping for one restaurant while developing"
task :test, :filename do |t, args|
  restaurants = YAML.load_file("config/restaurants.yml")
  restaurant = restaurants.find{|r| to_filename(r["name"]).eql? args[:filename]}

  data = load_with_nokogiri(restaurant["url"]["fi"])
  scraper = to_module(restaurant["name"])

  meals = {"fi" => [], "en" => []}
  restaurant["meals"] = scraper.get_meals(data, meals)
  restaurant = add_translations(restaurant)

  jj restaurant["meals"]

  puts colorize("Did this look good? Once it does, run \"rake update\" and commit your changes!", 32)
end

#############################################################################
#
# Helper functions
#
#############################################################################

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def to_module(str)
  to_module_name(str).split("::").inject(Class) {|mod, name| mod.const_get(name)}
end

def to_module_name(str)
  camelize(strip_accents(str))
end

def to_filename(str)
  underscore(strip_accents(str)) + ".rb"
end

def camelize(str)
  str.gsub(/[-,()&\/]/, " ").split(" ").map {|w| w.capitalize}.join
end

def underscore(str)
  str.gsub(/[-,()&\/]/, " ").split(" ").map {|w| w.downcase}.join("_")
end

def strip_accents(str)
  str.tr(
    "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
    "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
  )
end

def translator
  BingTranslator.new(CREDENTIALS["azure"]["client_id"], CREDENTIALS["azure"]["client_secret"])
end

def add_location(restaurant)
  begin
    geocode_base_url = "http://maps.googleapis.com/maps/api/geocode/json?"
    params = URI.encode_www_form(:address => restaurant["address"], :sensor => false)
    data = JSON.parse(open(geocode_base_url+params).read)
    if data["results"].count > 0
      restaurant["location"] = data["results"][0]["geometry"]["location"]
      restaurant["location"].each{|k,v| restaurant["location"][k] = v.round(7)}
    end
  rescue
    puts colorize("Failed getting location for #{restaurant["name"]} from Google Maps API!", 31)
  ensure
    return restaurant
  end
end

def add_translations(restaurant)
  if restaurant["meals"]["en"].empty?
    if restaurant["url"]["en"].present?
      data = load_with_nokogiri(restaurant["url"]["en"])
      meals_en = to_module(restaurant["name"]).get_meals(data, {"en" => []})
      restaurant["meals"].merge! meals_en
    else
      puts "Translating #{restaurant['name']}, this may take a while ..."
      restaurant["meals"]["fi"].each_with_index do |day,index|
        restaurant["meals"]["en"][index] = []
        if day.present?
          day.each do |meal|
            begin
              restaurant["meals"]["en"][index] << translator.translate(meal, :from => "fi", :to => "en")
            rescue
              puts colorize("Translation using Bing API failed! Have you updated config/credentials.yml?", 31)
            end
          end
        end
      end
    end
  end
  return restaurant
end

def load_with_nokogiri(url)
  if url =~ /rss/mi
    Nokogiri::XML(open(url))
  elsif url =~ /facebook\.com/
    pagename = url.match(/facebook.com\/(.*)/)[1]
    url = "https://graph.facebook.com/#{pagename}/posts?limit=5&access_token=#{CREDENTIALS['facebook']['access_token']}"
    data = JSON.parse(open(url).read)
  else
    Nokogiri::HTML(open(url))
  end
end