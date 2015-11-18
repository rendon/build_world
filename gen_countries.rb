#!/usr/bin/env ruby
require "json"
require_relative "lib/helpers"

# Sources differ on the the official number of countries and their names.
# Usually countries have 2-letter codes, however, Datamaps uses 3-letter codes.
# This function returns a list of countries in both lists, with short and long
# code. 
def match_countries
  long = []
  File.readlines("data/countries_long_codes.txt").each do |l|
    t = l.chomp.split(",")
    long << {code: t[0], name: t[1]}
  end

  short = []
  File.readlines("data/countries_short_codes.txt").each do |l|
    t = l.chomp.split(",")
    short << {code: t[0], name: t[1]}
  end

  countries = []
  long.each do |x|
    min = 1000
    match = short[0]
    short.each do |y|
      d = Levenshtein.distance(x[:name], y[:name])
      if d < min
        min = d
        match = y
      end
    end
    c = {
      name: x[:name],
      names: [],
      long_code: x[:code],
      short_code: match[:code]
    }
    countries << c
  end
  countries
end

def build_countries()
  countries = match_countries
  countries.each do |c|
    text = c[:name]
    c[:names] = []
    TARGET_LANGS.each do |t|
      resp = RestClient.get "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20151117T201220Z.b3c3cc938bab4d8c.2e0595d5b7170d4abd77a6ccc545005745444fc7&text=#{text}&lang=en-#{t}"
      data = JSON.parse(resp)
      c[:names] << data["text"].join(" ")
    end
    STDERR.puts text
  end
  countries
end
puts JSON.pretty_generate(build_countries)
