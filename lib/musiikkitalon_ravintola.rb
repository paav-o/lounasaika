# encoding: UTF-8

class MusiikkitalonRavintola
  def self.get_meals(data, meals)
    index = -1

    url = "http://www.tapahtumaravintolat.fi" + data.css("#content_body a")[2]["href"]
    reader = PDF::Reader.new(open(URI.escape(url)))

    data = reader.pages.first.text.gsub(/(.*?)(maanantai)/mi, '\2').gsub(/(\*-merkillä)(.*)/, "")
    data.split("\n").each do |row|
      if row =~ /maanantai|tiistai|keskiviikko|torstai|perjantai|lauantai|ruokahalua/mi
        index += 1
        meals.first.last[index] = []
      else
        meals.first.last[index] = [] unless meals.first.last[index].present?
        meals.first.last[index] << row.strip if row.present?
      end
    end
    return meals
  end
end