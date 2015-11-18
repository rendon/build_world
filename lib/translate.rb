require "rest-client"
require "levenshtein"

KEY = ENV["YANDEX_TR_KEY"]

# from 'en' -->
TARGET_LANGS = [
  "be", "ca", "cs", "da", "de", "el", "es", "et", "fi", "fr", "hu", "it", "lt",
  "lv", "mk", "nl", "no", "pt", "ru", "sk", "sl", "sq", "sv", "tr", "uk"
]

CONTINENTS_WITH_COUNTRIES = {
    africa: ["Algeria", "Angola", "Benin", "Botswana", "Burkina", "Burundi", "Cameroon", "Cape Verde", "Central African Republic", "Chad", "Comoros", "Congo", "Congo, Democratic Republic of", "Djibouti", "Egypt", "Equatorial Guinea", "Eritrea", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau", "Ivory Coast", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco", "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda", "Sao Tome and Principe", "Senegal", "Seychelles", "Sierra Leone", "Somalia", "South Africa", "South Sudan", "Sudan", "Swaziland", "Tanzania", "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe"],
    america: ["Antigua and Barbuda", "Bahamas", "Barbados", "Belize", "Canada", "Costa Rica", "Cuba", "Dominica", "Dominican Republic", "El Salvador", "Grenada", "Guatemala", "Haiti", "Honduras", "Jamaica", "Mexico", "Nicaragua", "Panama", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Trinidad and Tobago", "United States", "Argentina", "Bolivia", "Brazil", "Chile", "Colombia", "Ecuador", "Guyana", "Paraguay", "Peru", "Suriname", "Uruguay", "Venezuela"],
    asia: ["Afghanistan", "Bahrain", "Bangladesh", "Bhutan", "Brunei", "Burma (Myanmar)", "Cambodia", "China", "East Timor", "India", "Indonesia", "Iran", "Iraq", "Israel", "Japan", "Jordan", "Kazakhstan", "Korea, North", "Korea, South", "Kuwait", "Kyrgyzstan", "Laos", "Lebanon", "Malaysia", "Maldives", "Mongolia", "Nepal", "Oman", "Pakistan", "Philippines", "Qatar", "Russian Federation", "Saudi Arabia", "Singapore", "Sri Lanka", "Syria", "Tajikistan", "Thailand", "Turkey", "Turkmenistan", "United Arab Emirates", "Uzbekistan", "Vietnam", "Yemen"],
    europe: ["Albania", "Andorra", "Armenia", "Austria", "Azerbaijan", "Belarus", "Belgium", "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Estonia", "Finland", "France", "Georgia", "Germany", "Greece", "Hungary", "Iceland", "Ireland", "Italy", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg", "Macedonia", "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands", "Norway", "Poland", "Portugal", "Romania", "San Marino", "Serbia", "Slovakia", "Slovenia", "Spain", "Sweden", "Switzerland", "Ukraine", "United Kingdom", "Vatican City"],
    oceania: ["Australia", "Fiji", "Kiribati", "Marshall Islands", "Micronesia", "Nauru", "New Zealand", "Palau", "Papua New Guinea", "Samoa", "Solomon Islands", "Tonga", "Tuvalu", "Vanuatu"],
}

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

#def continentify(countries)

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
