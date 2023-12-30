# frozen_string_literal: true

module Hangman
  # This class will handle the flow of the game
  class Game
    DICTIONARY_NAME = 'dictionary.txt'

    def initalize
      @word = []
      @correct_word = []
      @incorrect_letters = []
    end

    def new_game
      @correct_word = random_word.split('')
      @word = Array.new(@correct_word.length, '_')
      play_game
    end

    private

    def play_game
      # Play a game
      display_game
    end

    def display_game
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
        words = file.readlines
      rescue StandardError => e
        puts "Error reading file: #{e.message}"
      end

      file&.close
      words
    end
  end
end

game = Hangman::Game.new
game.new_game
