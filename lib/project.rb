class Project
    attr_accessor :name, :year, :genre, :artist, :id
    def initialize(attributes)
        @name = attributes[:name]
        # @year = attributes[:year]
        # @genre = attributes[:genre]
        # @artist = attributes[:artist]
        @id = attributes[:id]
    end
    def save
        @id = DB.exec("INSERT INTO projects (name) VALUES ('#{@name}') RETURNING id;").first.fetch("id").to_i
        self
    end
    def update(new_attrs)
        @name = new_attrs[:name]
        # @year = new_attrs[:year]
        # @genre = new_attrs[:genre]
        # @artist = new_attrs[:artist]
        DB.exec("UPDATE projects SET name = '#{@name}' WHERE id = #{@id};")
        # DB.exec("UPDATE projects SET year = '#{@year}' WHERE id = #{@id};")
        # DB.exec("UPDATE projects SET genre = '#{@genre}' WHERE id = #{@id};")
        # DB.exec("UPDATE projects SET artist = '#{@artist}' WHERE id = #{@id};")
    end
    def delete
        DB.exec("DELETE FROM projects WHERE id = #{@id};")
        DB.exec("DELETE FROM volunteers WHERE project_id = #{@id};")
    end
    def ==(compare)
        (@name == compare.name) && (@year == compare.year) && (@genre == compare.genre) && (@artist == compare.artist)
    end

    #class methods
    def self.all
        DB.exec("SELECT * FROM projects;").map do |project|
            attributes = self.keys_to_sym(project)
            Project.new(attributes)
        end
    end
    def self.clear
        DB.exec("DELETE FROM projects *;")
    end
    def self.find(search_id)
        attributes = self.keys_to_sym(DB.exec("SELECT * FROM projects WHERE id = #{search_id};").first)
        Project.new(attributes)
    end
    # def self.sort
    #     @@projects.values.sort {|a, b| a.name <=> b.name}
    # end

    def volunteers
        Volunteer.find_by_project(@id)
    end

    private
    def self.keys_to_sym(str_hash)
        str_hash.reduce({}) do |acc, (key, val)|
            acc[key.to_sym] = (['id'].include? key) ? val.to_i : val
            acc
        end
    end
end
