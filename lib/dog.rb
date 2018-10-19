class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      LIMIT 1
    SQL

    result = DB[:conn].execute(sql, name)[0]
    #binding.pry
    self.new_from_db(result)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id)[0]
    #binding.pry
    self.new_from_db(result)
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL

    result = DB[:conn].execute(sql, name, breed)[0]
    if result != nil
      self.new_from_db(result)
    else
      self.create(name: name, breed: breed)
    end
  end

  def save
    if !self.id
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    else
      self.update
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
