# WSWSANE

What Star Wars Ships are Near Earth? A ruby gem that uses the NASA NEO API.
Use this gem to find which space objects (asteroids etc.) are nearby to earth, and which star wars ship they are most likely to be based on their size.

## Installation

```bash
gem install WSWSANE
```

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

The API key can be generated from here: [https://api.nasa.gov/](https://api.nasa.gov/).
All dates are strings in the format "YYYY-MM-DD".
The 'factions' parameter is optional and defaults to 
```ruby
["cis","republic","empire","rebel_alliance","first_order","resistance"]
```


## License
[Unlicense](https://choosealicense.com/licenses/unlicense/)
