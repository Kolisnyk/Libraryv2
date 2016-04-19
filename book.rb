
  require 'sqlite3'

  class Book

    @@SQLITE_DB_FILE = 'Library.sqlite'

      def self.post_types
      {'Fantasy' => Fantasy, 'Detective' => Detective, 'Humour' => Humour}
    end

    def self.create(type)
      return post_types[type].new
    end
  # вывод результатов
    def self.find(limit, genre, id)
      db = SQLite3::Database.open(@@SQLITE_DB_FILE)

      # конкретная запись
      if !id.nil?
        db.results_as_hash = true

        result = db.execute("SELECT * FROM posts WHERE rowid = ?", id)

        result = result[0] if result.is_a? Array

        db.close

        if result.empty?
          puts "Book #{id} not founded"
          return nil
        else
          post = create(result['type'])

          post.load_data(result)

          return post

        end

      else
        # возвращаем таблицу записей
        db.results_as_hash = false

        #формируем запрос в базу данных с нужными условиями
        query = "SELECT rowid, * FROM library "

        query += "WHERE genre = :genre " unless genre.nil? #!!!
        query += "ORDER by rowid DESC "

        query += "LIMIT :limit " unless limit.nil?
        statement = db.prepare(query)

        statement.bind_param('genre', genre) unless genre.nil?
        statement.bind_param('limit', limit) unless limit.nil?

        result = statement.execute!

        statement.close
        db.close

        return result

      end
    end

    def initialize
      @genre = nil
      @title = nil
      @author = nil
      @cover = nil
      @content = nil
      @created_at = Time.now
    end

    def read_from_console
      puts "Enter the title of new book"
      @title = STDIN.gets.chomp

      puts "Enter author's name"
      @author = STDIN.gets.chomp

      puts "Enter url address of new book cover"
      @cover = STDIN.gets.chomp

      puts "Enter short cotent of new book"
      @content = STDIN.gets.chomp

       end

    def to_strings
      time_string = "The book included in the Library: #{@created_at.strftime("%Y,%m,%d, %H:%M:%S")} \n\r \n\r"
      return [@title, time_string]
    end

   def save
   file = File.new(file_path, "w:UTF-8")
   for item in to_strings do
   file.puts (item)
   end

    file.close
    end


    def file_path
      current_path = File.dirname(__FILE__)

      file_name = @created_at.strftime("#{self.class.name}_%Y-%m-%d_%H-%M-%S.txt")

      return current_path + "/" + file_name
    end

    def save_to_db
      db = SQLite3::Database.open(@@SQLITE_DB_FILE)
      db.results_as_hash = true
      db.execute(
          "INSERT INTO library (" +
              to_db_hash.keys.join(',') +
              ")" +
              "VALUES (" +
              ('?,'*to_db_hash.keys.size).chomp(',') +
              ")",
          to_db_hash.values
      )
      insert_row_id =db.last_insert_row_id

      db.close
      return insert_row_id
    end

    def to_db_hash
      {
      'genre' => self.class.name,
      'title' => @title,
      'author' => @author,
      'cover' => @cover,
      'content' => @content,
      'created_at' => @created_at.to_s,
      }
    end

  # заполняем свои поля из хэш массива
    def load_data(data_hash)
      @title = data_hash['title']
      @author = data_hash['author']
      @cover = data_hash['cover']
      @content = data_hash['content'].split('\n\r')
      @created_at = Time.parse(data_hash['created_at'])
    end
  end
