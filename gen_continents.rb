#!/usr/bin/env ruby
require "json"
require "rest-client"
require "levenshtein"
require_relative "lib/helpers"

def continent(name)
  { name: name, names: [], countries: [] }
end

def build_continents()
  continents = {
    africa: continent("Africa"),
    america: continent("America"),
    asia: continent("Asia"),
    europe: continent("Europe"),
    oceania: continent("Oceania")
  }

  continents.each do |k, v|
    text = continents[k][:name]
    TARGET_LANGS.each do |t|
      resp = RestClient.get "https://translate.yandex.net/api/v1.5/tr.json/translate?key=#{KEY}&text=#{text}&lang=en-#{t}"
      data = JSON.parse(resp)
      continents[k][:names] << data['text'].join(" ")
    end
  end
  continents
end

puts JSON.pretty_generate(build_continents)
