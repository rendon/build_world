#!/usr/bin/env ruby
require "json"
require "csv"
require "levenshtein"

require_relative "lib/helpers"

# use gen_continents.rb to generate data file
continents = JSON.parse(File.read("data/continents.json"))
#puts JSON.pretty_generate(continents)

# use gen_countries.rb to generate data file
countries = JSON.parse(File.read("data/countries.json"))
#puts JSON.pretty_generate(countries)

CONTINENTS_WITH_COUNTRIES.each do |k, v|
  v.each do |a|
    min = 1000
    match = countries[0]
    countries.each do |b|
      d = Levenshtein.distance(a, b["name"])
      if d < min
        min = d
        match = b
      end
    end
    if min <= 1
      continents[k.to_s]["countries"] << match
    end
  end
end

#puts JSON.pretty_generate(continents)

cities = {}
File.readlines("data/world_cities.txt").each do |l|
  row = l.chomp.split(",")
  code = row[0]
  city = row[1]
  next if code == "Country" # skip first line

  unless cities.has_key?(code)
    cities[code] = []
  end
  cities[code] << city
end

continents.each do |k, v|
  v["countries"].each do |c|
    code = c["short_code"].downcase
    c["cities"] = cities[code]
  end
end

puts JSON.generate(continents)
