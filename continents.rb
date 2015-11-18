#!/usr/bin/env ruby

require 'rest-client'
continents = [
  {
    name: "Africa",
    names: [],
    countries: [],
  },
  {
    name: "America",
    names: []
  },
  {
    name: "Asia",
    names: [],
    countries: [],
  },
  {
    name: "Oceania",
    names: [],
    countries: [],
  },
  {
    name: "Europe",
    names: [],
    countries: [],
  }
]

targets = ["be", "ca", "cs", "da", "de", "el", "es", "et", "fi", "fr", "hu", "it", "lt", "lv", "mk", "nl", "no", "pt", "ru", "sk", "sl", "sq", "sv", "tr", "uk"]
continents.each do |continent|
  text = continent[:name]
  targets.each do |t|
    resp = RestClient.get "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20151117T201220Z.b3c3cc938bab4d8c.2e0595d5b7170d4abd77a6ccc545005745444fc7&text=#{text}&lang=en-#{t}"
    data = JSON.parse(resp)
    continent[:names] << data['text'].join(" ")
  end
end

puts JSON.pretty_generate(continents)
