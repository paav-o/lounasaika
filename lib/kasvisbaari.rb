class Kasvisbaari
  def self.get_meals(data, meals)
    index = 0
    
    data = data.at_css("#text").css("p")[0]
    data.search("br").each { |br| br.replace("\n") }

    data.text.split("\n").each do |row|
      if row =~ /maanantai|tiistai|keskiviikko|torstai|perjantai/mi
        index += 1
        meals["fi"][index] = []
      else
        meals["fi"][index] = [] unless meals["fi"][index].present?
        meals["fi"][index] << row.strip.mb_chars.capitalize if row.present?
      end
    end

    meals["en"] = meals["fi"].slice(1..5).map{|m| [ m[1] ]}
    meals["fi"] = meals["fi"].slice(1..5).map{|m| [ m[0] ]}

    return meals
  end
end