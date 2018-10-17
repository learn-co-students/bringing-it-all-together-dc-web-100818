require 'pry'

class Dog 
  attr_accessor :name, :breed, :id
  
  def initialize(name: name, breed: breed, id: nil)
    @name = name 
    @breed = breed
    @id = id
  end 
  
  def attributes 
    @name
    @breed
    @id
  end 
  
  def self.create_table 
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table 
    sql = <<-SQL 
      DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def save 
    if self.id.nil?
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else 
      self.update
    end 
    self
  end 
  
  def self.create(attributes)
    new_dog = Dog.new
    new_dog.name = attributes[:name]
    new_dog.breed = attributes[:breed]
    new_dog.save 
    new_dog
  end 
  
  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM dogs WHERE id = ?
    SQL
    
    dog_info = DB[:conn].execute(sql, id)[0]
    dog = Dog.new
    dog.name = dog_info[1]
    dog.breed = dog_info[2]
    dog.id = dog_info[0]
    dog
  end 
  
  def self.new_from_db(row)
    new_dog = Dog.new 
    new_dog.id = row[0]
    new_dog.name = row[1]
    new_dog.breed = row[2]
    new_dog
  end 
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new
      dog.name = dog_data[1]
      dog.breed = dog_data[2]
      dog.id = dog_data[0]
      dog 
    else 
      dog = Dog.new
      dog.name = name 
      dog.breed = breed
      dog.save 
      dog
    end 
  end 
  
  
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    
    dog_db = DB[:conn].execute(sql, name)[0]
    self.new_from_db(dog_db)
  end 
  
  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
end 