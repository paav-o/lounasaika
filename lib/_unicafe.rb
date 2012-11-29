class Unicafe
  def self.get_meals(data, meals)
    data.xpath("//channel/item/description").each_with_index do |day,index|
      meals.first.last[index] = []
      day = Nokogiri::HTML(day.text)
      day.css("p").each do |meal|
        meals.first.last[index] << [meal.css(".meal").text, meal.css("em").text].join(" ")
      end
    end
    return meals
  end
end