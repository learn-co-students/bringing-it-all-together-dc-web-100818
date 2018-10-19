
require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  # creates the dogs table in the database
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

  # drops the dogs table from the database
  def self.drop_table
    sql = <<-SQL
          DROP TABLE dogs
        SQL
    DB[:conn].execute(sql)
  end

  # returns an instance of the dog class
  def save
    if !self.id
      sql = <<-SQL
          INSERT INTO dogs(name, breed) VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  # takes in a hash of attributes and uses metaprogramming to create a new dog object.
  # Then it uses the save method to save that dog to the database returns a new dog object
  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = Dog.new(name: name, breed: breed, id: id)
    new_dog
  end

 # returns a new dog object by id
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    row = DB[:conn].execute(sql, id)[0]
    new_from_db(row)
  end

  # returns an instance of dog that matches the name from the DB
  def self.find_by_name(name)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        LIMIT 1
    SQL
    row = DB[:conn].execute(sql, name)[0]
    new_from_db(row)
  end

  # creates an instance of a dog if it does not already exist
  # when two dogs have the same name and different breed, it returns the correct dog
  # when creating a new dog with the same name as persisted dogs, it returns the correct dog
  def self.find_or_create_by(attributes)
    name = attributes[:name]
    breed = attributes[:breed]
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", name, breed).first
    if !dog.nil?
      dog = self.new_from_db(dog)
    else
      dog = self.create(attributes)
    end
    dog
  end

  # updates the record associated with a given instance
  def update
    sql = "UPDATE dogs SET (name) = ?, (breed) = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end














end # Class
