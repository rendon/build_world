# build world
Just a bunch of scripts and data files needed to build a database of continents, with countries and cities.

Some data files were omitted because of the file size, e.g. `data/world_cities.txt`, which you can get from [maxmind](https://www.maxmind.com/en/free-world-cities-databas").

The result is a SQLite database [ccc.db](https://github.com/rendon/world/blob/master/data/ccc.db) with three tables continents, countries and cities:

    sqlite> .schema continents
    CREATE TABLE continents(
        id        INTEGER PRIMARY KEY,
        name      VARCHAR(200)
      );

    sqlite> .schema countries
    CREATE TABLE countries(
        id            INTEGER PRIMARY KEY,
        name          VARCHAR(200),
        short_code    CHAR(2),
        long_code     CHAR(3),
        continent_id  INTEGER,
        FOREIGN KEY(continent_id)  REFERENCES countries(id)
      );

    sqlite> .schema cities
    CREATE TABLE cities(
        id          INTEGER PRIMARY KEY,
        name        VARCHAR(200),
        country_id  INTEGER,
        FOREIGN KEY (country_id) REFERENCES countries(id)
      );


Next is an example query:

    SELECT  continents.name AS continent, countries.name AS country, 
            countries.short_code AS short, countries.long_code AS long,
            cities.name AS city
    FROM    continents, countries, cities
    WHERE   continents.id = countries.continent_id AND
            cities.country_id = countries.id;


The result will look like this:

    america|Peru|PE|PER|paccho
    america|Peru|PE|PER|paccho tingo
    america|Peru|PE|PER|pacchuta
    america|Peru|PE|PER|paccohuarmi
    america|Peru|PE|PER|paccollo
    america|Peru|PE|PER|paccopampa
    ...

# Contributions
I build this database because I needed it for a project, it's not complete, but it's good enough for my needs. Contributions to improve the database are welcome.
