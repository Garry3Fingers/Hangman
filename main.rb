# frozen_string_literal: true

# This class send random word from the dictionary
class GuessWord
  attr_reader :dictionary

  def initialize
    @dictionary = File.open('google-10000-english-no-swears.txt').readlines.sample
  end
end
