#!/usr/bin/env ruby
require "json"
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

puts JSON.pretty_generate(continents)
