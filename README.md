# WSWSANE

What Star Wars Ships are Near Earth? A ruby gem that uses the NASA NEO API.  
Use this gem to find which space objects (asteroids etc.) are nearby to earth, and which Star Wars ships they are most likely to be based on their size.

## Installation

```bash
gem install WSWSANE
```
More information can be found on the RubyGems page:

[https://rubygems.org/gems/WSWSANE](https://rubygems.org/gems/WSWSANE)

## Usage

Firstly, make sure you import the gem using:

```ruby
require 'WSWSANE'
```

The simplest thing that this gem can do is classify something based on its size.
To do this, use the WSWSANE.classify() function. For example, if you wanted to see what ship an object between 5m and 15m big would be, you would use:

```ruby
WSWSANE.classify(5,15)
#results in "V-wing Starfighter"
```

You can also specify which "factions" you want to compare objects to. For example, if you only wanted to compare with ships from the original trilogy, you could use:

```ruby
WSWSANE.classify(5,15,["empire","rebel_alliance"])
#results in "A-wing Starfighter"
```

In order to use the NASA API to classify objects near earth, there are two methods you can use:
```ruby
WSWSANE.getToday(apikey,factions)
WSWSANE.get(apikey,startDate,endDate,factions)
```
The former will give you a list of NEOs (Near Earth Objects) that have their closest pass to earth today, whereas the latter allows you to specify a date range.

The API key can be generated from here: [https://api.nasa.gov/](https://api.nasa.gov/)  
All dates are strings in the format "YYYY-MM-DD".  
The 'factions' parameter is optional and defaults to:
```ruby
["cis","republic","empire","rebel_alliance","first_order","resistance"]
```

These functions will return a Hash resebmling the JSON provided by the NASA API. The field added by this gem can be accessed in a similar manner to this:
```ruby
neos = WSWSANE.get(apikey,"2020-01-01","2020-01-07")
puts neos["near_earth_objects"]["2020-01-01"][0]["star_wars_ship"]
#Lambda-class Shuttle
```
If the object couldn't be classified, then the "star_wars_ship" value will be "None".

## License
[Unlicense](https://choosealicense.com/licenses/unlicense/)
