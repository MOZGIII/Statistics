module DataLoader
  def self.load
    unless File.file?("data/global.yml")
      puts "You must copy \"data/global.example.yml\" to \"data/global.yml\" and modify it!"
      raise "Not ready to proccess"
    end
  
    DataProvider.global = YAML.load_file("data/global.yml")
    DataProvider.data = YAML.load_file("data/#{DataProvider.global["variant"]}.yml")
  end
end