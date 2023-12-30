# frozen_string_literal: true

module Hangman
  # This class will handle the flow of the game
  class Game
    DICTIONARY_NAME = 'dictionary.txt'

    def initialize
      @word = []
      @correct_word = []
      @incorrect_letters = []
      @attempts = 7
    end

    def new_game
      @correct_word = random_word.split('')
      @word = Array.new(@correct_word.length, '_')
      @attempts = 7
      play_game
    end

    private

    def play_game
      # Play a game
      loop do
        display_game
        make_guess

        break if game_over?
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

    def make_guess
      guess = ask_for_guess
      if @correct_word.include?(guess)
        @correct_word.each_with_index do |letter, index|
          @word[index] = guess if letter == guess
        end
      else
        @incorrect_letters << guess
        @attempts -= 1
      end
    end

    def ask_for_guess
      gets.chomp[0].downcase
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

game = Hangman::Game.new
game.new_game
