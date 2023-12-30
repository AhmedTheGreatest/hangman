# frozen_string_literal: true

require 'colorize'

module Hangman
  # This class will handle the flow of the game
  class Menu
    def start
      display_start_options
      option = gets.chomp.to_i
      if option == 1
        game = Game.new
        game.new_game
      elsif option == 2
        game = Game.load_game("game.bin")
        game.play_game
      end
    end

    private

    def display_start_options
      puts 'Do you want to:'.bold.red
      puts "#{'[1]'.cyan.bold} #{'Play a new game'.bold.cyan}"
      puts "#{'[2]'.cyan.bold} #{'Load a previous game'.bold.cyan}"
    end
  end

  class Game
    DICTIONARY_NAME = 'dictionary.txt'

    def initialize
      @word = []
      @correct_word = []
      @incorrect_letters = []
      @attempts = 7
    end

    def new_game
      puts 'You have chosen to start a new game!'
      puts 'If at any time you want to save the game type save'
      @correct_word = random_word.split('')
      @word = Array.new(@correct_word.length, '_')
      @attempts = 7
      play_game
    end

    def self.load_game(path)
      # Loads a game from a file
      File.open(path, "r") do |file|
        Marshal.load(file.read)
      end
    end

    def play_game
      # Play a game
      loop do
        break if game_over?

        display_game
        handle_input
      end
      display_game_end_msg
    end

    private

    # Saves a game into a file
    def save_game
      File.open("game.bin", "w") do |file|
        file.write(Marshal.dump(self))
      end
    end

    def display_game_end_msg
      if game_won?
        puts 'You have won the game!'
      elsif game_lost?
        puts 'You have lost the game!'
        puts "The correct word was #{@correct_word.join('')}"
      end
    end

    def game_over?
      game_won? || game_lost?
    end

    def game_won?
      @correct_word == @word
    end

    def game_lost?
      @attempts < 1
    end

    def make_guess(guess)
      if @correct_word.include?(guess)
        @correct_word.each_with_index do |letter, index|
          @word[index] = guess if letter == guess
        end
      else
        @incorrect_letters << guess
        @attempts -= 1
      end
    end

    def ask_for_input
      print 'Type your guess: '
      guess = ''
      loop do
        guess = gets.chomp.downcase
        break unless guess.empty? && guess != 'save'
      end
      guess
    end

    def handle_input
      input = ask_for_input
      if input == 'save'
        save_game
      else
        make_guess(input[0])
      end
    end

    def display_game
      puts ''
      puts "You have #{@attempts} attempt(s) left!"
      puts "Incorrect letters: #{@incorrect_letters.join(' ')}"
      puts @word.join(' ')
    end

    def random_word
      valid_words(open_dictionary).sample.chomp
    end

    def valid_words(words)
      words.select { |word| word.chomp.length <= 12 && word.chomp.length >= 5 }
    end

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
