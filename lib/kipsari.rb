class Kipsari
  def self.get_meals(data, meals)
    week_keyword = {
      "fi" => "Viikko",
      "en" => "Week"
    }

    week_keyword.each do |locale,keyword|
      week = data["data"].find {|i| i['message'].include? "#{keyword} #{DateTime.now.cweek}"}["message"]
      week.split("\n").slice(2..6).each_with_index do |row,index|
        meals[locale][index] = [ row.slice(5..-1).strip.gsub(/^\- /, "") ]
      end
    end

    return meals
  end
end