#!/usr/bin/env ruby
require 'rest-client'
require 'json'
require 'levenshtein'
a = []
File.readlines("countries_a.txt").each do |l|
  t = l.chomp.split(",")
  a << {code: t[0], name: t[1]}
end

b = []
File.readlines("countries_b.txt").each do |l|
  t = l.chomp.split(",")
  b << {code: t[0], name: t[1]}
end

countries = []
a.each do |x|
  min = 1000
  match = b[0]
  b.each do |y|
    d = Levenshtein.distance(x[:name], y[:name])
    if d < min
      min = d
      match = y
    end
  end
  c = {
    name: x[:name],
    codes: {long: x[:code], short: match[:code]}
  }
  countries << c
end

targets = ["be", "ca", "cs", "da", "de", "el", "es", "et", "fi", "fr", "hu", "it", "lt", "lv", "mk", "nl", "no", "pt", "ru", "sk", "sl", "sq", "sv", "tr", "uk"]
countries.each do |c|
  text = c[:name]
  c[:names] = []
  targets.each do |t|
    resp = RestClient.get "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20151117T201220Z.b3c3cc938bab4d8c.2e0595d5b7170d4abd77a6ccc545005745444fc7&text=#{text}&lang=en-#{t}"
    data = JSON.parse(resp)
    c[:names] << data["text"].join(" ")
  end
  STDERR.puts text
end

puts JSON.pretty_generate(countries)
