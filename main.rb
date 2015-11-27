#!/usr/bin/env ruby
require "json"
require "csv"
require "levenshtein"
require "sqlite3"

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

cities = {}
File.readlines("data/world_cities.txt").each do |l|
  row = l.chomp.split(",")
  code = row[0]
  city = row[1]
  accent_city = row[2]
  next if code == "Country" # skip first line

  unless cities.has_key?(code)
    cities[code] = []
  end
  cities[code] << [city, accent_city]
end

continents.each do |k, v|
  v["countries"].each do |c|
    code = c["short_code"].downcase
    c["cities"] = cities[code]
  end
end

# Open database
db = SQLite3::Database.new "ccc.db"

# Clean up
rows = db.execute "DROP TABLE IF EXISTS continents"
rows = db.execute <<-SQL
  CREATE TABLE continents(
    id        INTEGER PRIMARY KEY,
    name      VARCHAR(200)
  );
SQL

rows = db.execute "DROP TABLE IF EXISTS countries"
rows = db.execute <<-SQL
  CREATE TABLE countries(
    id            INTEGER PRIMARY KEY,
    name          VARCHAR(200),
    short_code    CHAR(2),
    long_code     CHAR(3),
    continent_id  INTEGER,
    FOREIGN KEY(continent_id)  REFERENCES countries(id)
  );
SQL

rows = db.execute "DROP TABLE IF EXISTS cities"
rows = db.execute <<-SQL
  CREATE TABLE cities(
    id          INTEGER PRIMARY KEY,
    name        VARCHAR(200),
    country_id  INTEGER,
    FOREIGN KEY (country_id) REFERENCES countries(id)
  )
SQL

country_count = 0
city_count = 0
continents.each do |k, v|
  db.execute "INSERT INTO continents(name) values(?)", k.to_s
  rows = db.execute "SELECT last_insert_rowid();"
  continent_id = rows[0][0]
  v["countries"].each do |c|
    query = <<-SQL
    INSERT INTO countries(name, short_code, long_code, continent_id)
    VALUES (?, ?, ?, ?)
    SQL
    db.execute query, c["name"], c["short_code"], c["long_code"], continent_id
    next if c["cities"].nil?
    rows = db.execute "SELECT last_insert_rowid();"
    country_id = rows[0][0]
    db.execute "BEGIN TRANSACTION;"
    c["cities"].each do |y|
      query = "INSERT INTO cities(name, country_id) VALUES (?, ?)"
      rows = db.execute query, y[0], country_id
      city_count += 1
      puts "cities inserted: #{city_count}"
    end
    db.execute "COMMIT;"
    country_count += 1
    puts "countries inserted: #{country_count}"
  end
end
