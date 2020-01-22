class Volunteer
    attr_reader :id
    attr_accessor :name, :project_id

    def initialize(attributes)
        @name = attributes[:name]
        @project_id = attributes[:project_id].to_i
        @id = attributes[:id].to_i
    end

    def save
        @id = DB.exec("INSERT INTO volunteers (name, project_id) VALUES ('#{@name}', #{@project_id}) RETURNING id;").first.fetch("id").to_i
        self
    end
    def update(new_attrs)
        @name = new_attrs[:name]
        @project_id = new_attrs[:project_id]
        DB.exec("UPDATE volunteers SET name = '#{@name}' WHERE id = #{@id};")
    end
    def delete
        DB.exec("DELETE FROM volunteers WHERE id = #{@id};")
    end
    def ==(compare)
        return false if (compare.nil?)
        (@name == compare.name) && (@project_id == compare.project_id)
    end

    def self.all
        DB.exec("SELECT * FROM volunteers;").map do |volunteer|
            attributes = keys_to_sym(volunteer)
            Volunteer.new(attributes)
        end
    end
    def self.find(search_id)
        volunteer = DB.exec("SELECT * FROM volunteers WHERE id = #{search_id};").first
        return nil if (volunteer.nil?)
        Volunteer.new(self.keys_to_sym(volunteer))
    end
    def self.clear
        DB.exec("DELETE FROM volunteers *;")
    end
    def self.find_by_project(alb_id)
      # binding.pry
        DB.exec("SELECT * FROM volunteers WHERE project_id = #{alb_id};").map do |volunteer|
            attributes = self.keys_to_sym(volunteer)
            Volunteer.new(attributes)
        end
    end

    def project
        Project.find(@project_id)
    end

    private
    def self.keys_to_sym(str_hash)
        str_hash.reduce({}) do |acc, (key, val)|
            acc[key.to_sym] = (['id', 'project_id'].include? key) ? val.to_i : val
            acc
        end
    end
end
