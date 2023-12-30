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
      @word = random_word
      play_game
    end

    private

    def play_game
      # hello
    end

    def random_word
      words = File.open(DICTIONARY_NAME).readlines
      word = ''
      loop do
        word = words.sample.chomp
        break if word.length <= 12 && word.length >= 5
      end
      word
    end
  end
end

game = Hangman::Game.new
game.new_game
