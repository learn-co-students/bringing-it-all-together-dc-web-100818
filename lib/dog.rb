require 'pry'
require_relative "../config/environment.rb"

class Dog
  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:) #???? how do u know when to do this vs just a variable?
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save #????
     if self.id
       self.update
     else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
    end
    self #why did we have to do this?
  end

  def self.create(name:, breed:) #????
    dog = Dog.new(name: name, breed: breed) #? bc started with hash keys?
    dog.save
    dog
  end

#?????
  def self.new_from_db(row) #newfromarray (array = what database returns) #constructor method
    #binding.pry #[1, "Pat", "poodle"]
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed) #? bc started with hash keys?
  end

  def self.find_by_name(name) #????
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
      SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row) #does previous method on array returned to create new instance
    end.first #why do we have to put first? takes it out of an array and makes it an instance
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

#  name: "blah" = :name => "blah"

  def self.find_or_create_by(name:, breed:) #???
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'") #why are we using this syntax?
    if !dog.empty? #if there's something from the database returned (will be array of arrays)
      dog_data = dog[0] #break it out of 1st array, now just array with 3 elements [1, "name", "breed"]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2]) #find new instance as object
    else
      dog = self.create(name: name, breed: breed) #if there's nothing returned from the database, create new dog instance and enter it into db
    end
    dog #return the new object/instance
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
