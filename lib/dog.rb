class Dog
attr_accessor :name, :breed
attr_reader :id 

def initialize(name:, breed:, id: nil)
    @name = name 
    @breed = breed
    @id = id 
end

def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
        id INTEGER PRMARY KEY,
        name TEXT,
        breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
end

def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
end

def save
sql = <<-SQL
INSERT INTO dogs (name, breed) VALUES (?, ?)
SQL
DB[:conn].execute(sql, self.name, self.breed)
@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
self 
end

def self.create(hash)
    dog = self.new(hash)
    dog.save
    dog
end

def self.new_from_db(row)
    attributes = {
        :id => row[0],
        :name => row[1],
        :breed => row[2]
    }
    self.new(attributes)
end

def self.find_by_id(id_to_find)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    DB[:conn].execute(sql,id_to_find).map do |row|
        self.new_from_db(row)
    end.first
end

def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs 
    WHERE name = ?, breed = ?
    SQL
    
    dog = DB[:conn].execute(sql)

    if dog
        new_dog = self.new_from_db(dog)
    else
        new_dog = self.create({:name => name, :breed => breed})
    end
    new_dog
end

def self.find_by_name(name_to_find)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    DB[:conn].execute(sql, name_to_find)
end

def update(name, breed)
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, breed, self.id)
end
end
    





