
#encoding UTF-8 for using russian letters with Windows

if (Gem.win_platform?)
  #Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(#Encoding.default_external,
        Encoding.default_internal)
  end
end

require_relative 'book.rb'
require_relative 'draft_book.rb'#
require_relative 'fantasy.rb'
require_relative 'detective.rb'
require_relative 'humour.rb'
require_relative 'fantasy_.rb'
require_relative 'detective_.rb'
require_relative 'humour_.rb'

require 'optparse'

#help к программе
options = {}

OptionParser.new do |opt|
  opt.banner = 'Usage: read.rb [options]'

  opt.on('-h', 'Print help') do
    puts opt
    exit
  end
  opt.on('--limit NUMBER', 'how much recent posts would you like to see') {|o| options[:limit] = o}
  opt.on('--genre GENRE', 'which genre of books would you like to see') {|o| options[:genre] = o}
  opt.on('--id POST_ID', 'show just this ID (by default any)') {|o| options[:id] = o}


end.parse!

puts "Welcome to the Library. Used SQLite."

# Механизм аутентификации
# Зарегестрированный пользователь, пароль лежат в теле программы

authorized_name = "1111"
authorization_password = "1111"

puts "Enter your name, please:"
name = STDIN.gets.chomp
puts "Enter your password, please:"
password = STDIN.gets.chomp

if authorized_name != name or authorization_password != password
  puts "You are not authorized: access limited"
  puts
  puts "Would you like to get list of books in Common library? Answer is yes/no."

  list = "yes"
  ch_list = STDIN.gets.chomp

  if ch_list != list
    puts "You can't work with library"
  else
    puts "You are not authorized: you can just read Common library. Here it is."

    result = Book.find(options[:limit], options[:genre], options[:id])

    if result.is_a? Book
      puts "Book #{result.class.name}, id = #{options[:id]}"

      result.to_strings.each do |line|
        puts line
      end
    else
      puts "Books in the library:"
      print "| id\t| Genre\t\t| Title \t| Author \t| Cover \t| Content \t | Added to library \t "

      result.each do |row|
        puts

        row.each do |element|
          print "| #{element.to_s.delete("\\n\\r")[0..15]}\t"
        end
      end
    end
  end
#----------------
  else
  puts "Would you like to include your book in the Library?" +
       "or to get list of books which are in the Library? Answer is include/get"
      incl= "include"
      ch_incl = STDIN.gets.chomp
      if incl !=ch_incl
        puts "Would you like to see Common library or Draft library? Answer is common/draft."
        answer = STDIN.gets.chomp
        if answer != "common"
          result = Draftbook.find(options[:limit], options[:genre], options[:id])

          if result.is_a? Draftbook
            puts "Book #{result.class.name}, id = #{options[:id]}"

            result.to_strings.each do |line|
              puts line
            end
          else
            puts "Books in the library:"
            print "| id\t| Genre\t\t| Title \t| Author \t| Cover \t| Content \t | Added to library \t "

            result.each do |row|
              puts

              row.each do |element|
                print "| #{element.to_s.delete("\\n\\r")[0..15]}\t"
              end
            end
          end
        else
          result = Book.find(options[:limit], options[:genre], options[:id])

          if result.is_a? Book
            puts "Book #{result.class.name}, id = #{options[:id]}"

            result.to_strings.each do |line|
              puts line
            end
          else
            puts "Books in the library:"
            print "| id\t| Genre\t\t| Title \t| Author \t| Cover \t| Content \t | Added to library \t "

            result.each do |row|
              puts

              row.each do |element|
                print "| #{element.to_s.delete("\\n\\r")[0..15]}\t"
              end
            end
          end
        end
      end
      #------------------------

          # запись книги в общую библиотеку или в черновики?
          puts "Would you like to include your book in Common library? yes/no?"
          choicey = "no"
          user_choice = STDIN.gets.chomp
          if choicey != user_choice
            # запись книги в общую библиотеку

            puts "Which book would you add to the Common library?"


            choices = Book.post_types.keys
            choice = -1

            until choice>=0 && choice < (choices.size)

              choices.each_with_index do |type, index|
                puts "\t#{index}. #{type}"
              end
              choice = (STDIN.gets.chomp.to_i)
            end

            entry = Book.create(choices[choice])

            entry.read_from_console

            id = entry.save_to_db


            puts "Your book is saved in Common library. ID of your book = #{id}"
          else
            # запись книги в черновики?
            puts "Your book will be icluded in Draft library."
            #
            choices = Draftbook.post_types.keys
            choice = -1

            until choice>=0 && choice < (choices.size)

              choices.each_with_index do |type, index|
                puts "\t#{index}. #{type}"
              end
              choice = (STDIN.gets.chomp.to_i)
            end

            entry = Draftbook.create(choices[choice])

            entry.read_from_console

            id = entry.save_to_db

            puts "Your book is saved in Draft library. ID of your book = #{id}"

          end
end