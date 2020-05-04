require 'net/http'
require 'json'
##
# This class is a static class from which all functions are called
class WSWSANE
  @@reference={:cis=>[
                   ["The Malevolence", 4845],
                   ["Lucrehulk-class Battleship", 3356.9],
                   ["Providence-class Destroyer", 1088],
                   ["Munificent-class Frigate", 825],
                   ["C-9979 Landing Craft", 210],
                   ["Vulture Droid", 6.96],
                   ["Tri-fighter ",5.4]
                 ],
               :republic=>[
                   ["Venator-class Star Destroyer", 1137],
                   ["Acclamator-class Assault Ship", 752],
                   ["Cosular-class Cruiser", 115],
                   ["LAAT Gunship", 28.8],
                   ["Z-95 Starfighter", 16.74],
                   ["ARC-170 Starfighter", 12.71],
                   ["V-wing Starfighter", 7.9]
                 ],
               :empire=>[
                   ["DS-2 Death Star", 200000],
                   ["DS-1 Death Star", 160000],
                   ["Executor-class Star Dreadnought", 19000],
                   ["Imperial II-class Star Destroyer", 1600],
                   ["Interdictor-class Star Destroyer", 1129],
                   ["Victory II-class Star Destroyer", 900],
                   ["Arquitens-class Light Cruiser", 325],
                   ["Lambda-class Shuttle", 20],
                   ["TIE Fighter", 7.24]
                 ],
               :rebel_alliance=>[
                   ["Mon Calamari Star Cruiser", 1200],
                   ["Nebulon-B Frigate", 300],
                   ["CR90 Corvette", 150],
                   ["Alderaan Cruiser", 126.68],
                   ["Hammerhead Corvette", 116.7],
                   ["GR-75 Transport", 90],
                   ["Millenium Falcon", 34.75],
                   ["U-Wing Starfighter", 23.99],
                   ["Y-wing Starfighter", 23.4],
                   ["B-wing Starfighter", 16.9],
                   ["X-wing Starfighter", 13.4],
                   ["A-wing Starfighter", 9.6]
                 ],
               :first_order=>[
                   ["Starkiller Base", 660000],
                   ["The Supremacy", 60542.68],
                   ["Mandator IV-class Siege Dreadnought", 7669.71],
                   ["Resurgent-class Star Destroyer", 2915.81],
                   ["AAL Transporter", 18.05],
                   ["TIE Fighter", 6.69]
                 ],
               :resistance=>[
                   ["MC85 Star Cruiser", 3438.37],
                   ["MC80A Heavy Star Cruiser", 1300],
                   ["Free Virgillia-class Bunkerbuster", 316.05],
                   ["SF-17 Heavy Bomber", 29.67],
                   ["B-wing Starfighter", 16.9],
                   ["X-wing Starfighter", 13.4],
                   ["A-wing Starfighter", 9.6]
                 ]
}
  ##
  # Returns the NASA NEO API response for the current day (as given by Time.now), but each object has an additional field for the closest sized ship.
  # @param apikey [String] The Api Key given to you by api.nasa.gov.
  # @param factions [Array] An optional array of "factions" that will be used to compare objects. By default, this will compare all NEOs with all ships.
  # @return [Hash] 
  #
  # Example Usage:
  #
  # If you wanted to compare all objects that have their closest approach to earth today to ships from the original trilogy, you could use:
  #   WSWSANE.getToday(apikey,["rebel_alliance","empire"])
  #
  # The return value is very similar to the data provided by the NASA API (it is also a JSON object).
  #
  # To get a list of all the comparisons, you could do:
  #   WSWSANE.getToday(apikey)["near_earth_objects"].each do |date,objects|
  #     objects.each do |neo|
  #       puts neo["star_wars_ship"]
  #     end
  #   end
  #
  # If no suitable comparison for an object can be found, then the classified ship will be "None".
  #
  # If the api key is incorrect, or the api request otherwise fails, then an error will be raised.
  def self.getToday(apikey,factions=["cis","republic","empire","rebel_alliance","first_order","resistance"])
    date=Time.new.strftime("%Y-%m-%d")
    return self.get(apikey,date,date,factions)
  end
  ##
  # Returns the NASA NEO API response for the range of dates provided, but each object has an additional field for the closest sized ship.
  # @param apikey [String] The Api Key given to you by api.nasa.gov
  # @param startDate [String] The start date in the form "YYYY-MM-DD"
  # @param endDate [String] The end date in the form "YYYY-MM-DD"
  # The date parameters are inclusive, and together determine the range of days for closest approach of the NEOs that the api returns.
  # @param factions [Array] An optional array of "factions" that will be used to compare objects. By default, this will compare all NEOs with all ships.
  # 
  # Example Usage:
  #
  # If you wanted to compare all objects that have their closest approach to earth in the first week of 2020 to ships from the prequel trilogy, you could use:
  #   WSWSANE.get(apikey,"2020-01-01","2020-01-07",["cis","republic"])
  #
  # The return value is very similar to the data provided by the NASA API (it is also a JSON object).
  #
  # To get a list of all the comparisons, you could do:
  #   WSWSANE.get(apikey,"2020-01-01","2020-01-07")["near_earth_objects"].each do |date,objects|
  #     objects.each do |neo|
  #       puts neo["star_wars_ship"]
  #     end
  #   end
  #
  # If no suitable comparison for an object can be found, then the classified ship will be "None".
  #
  # If the api key is incorrect, or the api request otherwise fails, then an error will be raised.
  def self.get(apikey,startDate,endDate,factions=["cis","republic","empire","rebel_alliance","first_order","resistance"])
    uri=URI("https://api.nasa.gov/neo/rest/v1/feed")
    params={:start_date=>startDate,
            :end_date=>endDate,
            :api_key=>apikey}
    uri.query = URI.encode_www_form(params)
    response=Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      data=JSON.parse(response.body)
      data["near_earth_objects"].each do |date,dateset|
        dateset.each do |neo|
          size=neo["estimated_diameter"]["meters"]
          neo["star_wars_ship"]=self.classify(size["estimated_diameter_min"],size["estimated_diameter_max"],factions)
        end
      end
      return data
    else
      raise response.body
    end
  end
  ##
  # Classifies an object based on the range of sizes it could be.
  # @param minSize [Integer] The minimum size of the object in meters
  # @param maxSize [Integer] The maximum size of the object in meters
  # @param factions [Array] An optional array of "factions" that will be used to compare objects. By default, this will compare all NEOs with all ships.
  #
  # Example Usage:
  #
  # If you wanted to compare an object between 5 and 10 meters big to ships from the sequel trilogy, you could use:
  #   WSWSANE.classify(5,10,["first_order","resistance"])
  #
  # If no suitable comparison for an object can be found, then the classified ship will be "None".
  def self.classify(minSize,maxSize,factions=["cis","republic","empire","rebel_alliance","first_order","resistance"])
    factions.map!(&:downcase)
    possibleShips=[]
    @@reference.each do |faction,ships|
      if factions.include?(faction.to_s)
        ships.each do |ship|
          if ship[1]>minSize and ship[1]<maxSize
            possibleShips.push(ship)
          end
        end
      end
    end
    if possibleShips.length==0
      return "None"
    else
      bestMatch=possibleShips[0]
      estSize=Math.exp((Math.log(minSize)+Math.log(maxSize))/2)
      possibleShips.each do |possibleShip|
        if (possibleShip[1]-estSize).abs()<(bestMatch[1]-estSize).abs()
          bestMatch=possibleShip
        end
      end
      return bestMatch[0]
    end
  end
end
