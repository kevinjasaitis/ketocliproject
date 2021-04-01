class Ketocliproject
    @@all = []
    @@type = "recipe"
  
    attr_accessor :name, :url, :category, :ingredients, :instructions
  
    def initialize(name, url, category)
      @name = name
      @url = url
      @category = category
      @ingredients = []
      @instructions = []
      self.class.all << self
    end
  
    def self.all
      @@all
    end
  
    def self.type
      @@type
    end
  
    def self.get_recipe(category)
      self.scrape_all_recipes(category)
      puts "Here are all the #{category.name.downcase} recipes:"
      recipe_index = Menu.display(self.type, category.recipes)
      recipe = category.recipes[recipe_index]
    end
  
    def self.scrape_all_recipes(category)
      doc = Nokogiri::HTML(open(category.url))
      posts = doc.css("div.tve_post")
  
      posts.each do |post|
        name = post.css("span.tve-post-grid-title a").text
        url = post.css("a").attr("href").value
        recipe = self.new(name, url, category)
        category.add_recipe(recipe)
      end
    end
  
    def print
      self.get_complete_recipe
      puts "\n#{self.name} (#{self.category.name})"
      puts "\nIngredients:"
      self.ingredients.each do |ingredient|
        puts clean_ingredient(ingredient)
      end
      puts "\nInstructions:"
      self.instructions.each_with_index do |instruction, index|
        puts "#{index + 1}. #{instruction}"
      end
    end
  
    def get_complete_recipe
      doc = Nokogiri::HTML(open(self.url))
      ingredients_data = doc.css("li.wprm-recipe-ingredient")
      ingredients_data.each do |ingredient|
        amount = ingredient.css("span.wprm-recipe-ingredient-amount").text
        unit = ingredient.css("span.wprm-recipe-ingredient-unit").text
        name = ingredient.css("span.wprm-recipe-ingredient-name").text
        notes = ingredient.css("span.wprm-recipe-ingredient-notes")
        if notes
          notes = "#{notes.text}"
        end
        self.ingredients.push("#{amount} #{unit} #{name} #{notes}")
      end
  
      instructions_data = doc.css("li.wprm-recipe-instruction")
      instructions_data.each do |instruction|
        self.instructions.push(instruction.text)
      end
    end
  
    def clean_ingredient(ingredient)
      while ingredient.match(/\s\s/)
        ingredient.gsub!(/\s\s/, " ")
      end
      ingredient.strip
    end
  
  end