# frozen_string_literal: true

require 'colorize'

# The popular game Hangman
module Hangman
  # This class will start a game
  class Menu
    # Displays the menu and starts playing the game
    def start
      display_start_options
      option = gets.chomp.to_i
      if option == 1
        game = Game.new
        game.new_game
      elsif option == 2
        load
      end
    end

    private

    # Loads a serialized binary file as a Game object and starts playing it
    def load
      games = Dir.entries('games')[0..-3]
      display_load_options(games)
      file_path = file_to_load(games)
      game = Game.load_game(file_path)
      game.play_game
    end

    # Displays the load options (the files)
    def display_load_options(games)
      puts 'Which game do you want to open?'.bold.red
      games.each_with_index do |game, index|
        puts "#{"[#{index + 1}]".bold.cyan} #{game.bold.cyan}"
      end
    end

    # Asks the user for the file and returns its path
    def file_to_load(games)
      option = gets.chomp.to_i - 1
      "games/#{games[option]}"
    end

    # Displays the game's start menu
    def display_start_options
      puts 'Do you want to:'.bold.red
      puts "#{'[1]'.cyan.bold} #{'Play a new game'.bold.cyan}"
      puts "#{'[2]'.cyan.bold} #{'Load a previous game'.bold.cyan}"
    end
  end

  # This class will handle the flow of the game
  class Game
    # The path of the Hangman dictionary
    DICTIONARY_NAME = 'dictionary.txt'

    def initialize
      @word = []
      @correct_word = []
      @incorrect_letters = []
      @attempts = 7
    end

    # Setups a new game
    def new_game
      puts 'You have chosen to start a new game!'
      puts 'If at any time you want to save the game type save'
      @correct_word = random_word.split('') # Splits the word into an array
      @word = Array.new(@correct_word.length, '_')
      @attempts = 7
      play_game
    end

    # Loads a game from a file
    def self.load_game(path)
      # If the file does not exist display an error
      unless File.exist?(path)
        puts "Error: File #{path} not found."
        return nil
      end

      # Opens the file and loads the object
      File.open(path, 'r') do |file|
        Marshal.load(file.read)
      end
    end

    # Plays a game
    def play_game
      # Loops until the game is over
      loop do
        break if game_over?

        display_game # Displays the game
        handle_input # Handles the player input
      end
      display_game_end_msg # Displays the win or lose message
    end

    private

    # Serializes and saves a game into a file
    def save_game
      Dir.mkdir('games') unless Dir.exist?('games') # Creates a games directory unless it already exists

      File.open(available_file_name, 'w') do |file|
        file.write(Marshal.dump(self))
      end
    end

    # Displays the win or lose message
    def display_game_end_msg
      if game_won?
        puts 'You have won the game!'
      elsif game_lost?
        puts 'You have lost the game!'
        puts "The correct word was #{@correct_word.join('')}"
      end
    end

    # Returns the available game file name
    def available_file_name
      counter = 0
      loop do
        break unless File.exist?("games/game#{counter}.bin")

        counter += 1
      end
      "games/game#{counter}.bin"
    end

    # Returns if the game is over
    def game_over?
      game_won? || game_lost?
    end

    # Returns if the game is won
    def game_won?
      @correct_word == @word
    end

    # Returns if the game is lost
    def game_lost?
      @attempts < 1
    end

    # Makes and handles guesses
    def make_guess(guess)
      # The the guess is correct, replace every occurrence with it
      if @correct_word.include?(guess)
        @correct_word.each_with_index do |letter, index|
          @word[index] = guess if letter == guess
        end
      # Else if it is incorrect, add it to the incorrect letters array and decrease attempts
      else
        @incorrect_letters << guess
        @attempts -= 1
      end
    end

    # Asks and validates the input from the user
    def ask_for_input
      print 'Type your guess: '
      guess = ''
      # Loops until the input is valid
      loop do
        guess = gets.chomp.downcase
        break unless guess.empty? && guess != 'save'
      end
      guess
    end

    # Handles the user input
    def handle_input
      input = ask_for_input
      if input == 'save'
        save_game
      else
        make_guess(input[0])
      end
    end

    # Displays the game
    def display_game
      puts ''
      puts "You have #{@attempts} attempt(s) left!"
      puts "Incorrect letters: #{@incorrect_letters.join(' ')}"
      puts @word.join(' ')
    end

    # Gets a random valid word from the dictionary
    def random_word
      valid_words(open_dictionary).sample.chomp
    end

    # Get all the valid words from the dictionary
    def valid_words(words)
      words.select { |word| word.chomp.length <= 12 && word.chomp.length >= 5 }
    end

    # Opens the dictionary and returns all the words in it
    def open_dictionary
      begin
        file = File.open(DICTIONARY_NAME)
        lines = file.readlines
      rescue StandardError => e
        puts "Error reading file: #{e.message}"
      end

      file&.close
      lines
    end
  end
end

menu = Hangman::Menu.new
menu.start
