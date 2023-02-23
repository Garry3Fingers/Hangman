# frozen_string_literal: true

require 'colorize'

# This class send random word from the dictionary
class GuessWord
  def initialize
    @dictionary = File.open('google-10000-english-no-swears.txt').readlines
  end

  private

  def clean_dictionary
    @dictionary.map { |word| word.split(//) }.each(&:pop).map(&:join)
  end

  public

  def random_word
    dictionary = clean_dictionary
    dictionary.select { |word| (word.length >= 5) && (word.length <= 12) }.sample
  end
end

class InvalidInput < StandardError; end

# This class implements gameplay
class CoreOfTheGame
  def initialize
    @code_word = GuessWord.new.random_word
    @letters_position = []
    @correct_letters = []
    @incorrect_letters = []
  end

  def split_guess_word
    @code_word.split(//)
  end

  def add_blank_positions(guess_word)
    i = 0
    while i < guess_word.length
      @letters_position.push('_')
      i += 1
    end
  end

  def print_postion(array, color)
    array.each do |chr|
      print "#{chr.colorize(color)} "
    end
    puts ''
  end

  def output_game_information(iteration)
    print_postion(@letters_position, :yellow)
    return unless iteration != 11

    print_postion(@correct_letters, :green)
    print_postion(@incorrect_letters, :red)
  end

  def check_if_game_won
    return if @code_word != @letters_position.join

    true
  end

  def player_input
    input = gets.chomp
    raise InvalidInput, 'You should enter one alphabetic character' unless input.match?(/[[:alpha:]]/)\
     && input.length == 1
  rescue InvalidInput => e
    puts e
    retry
  else
    input.downcase
  end

  def pcocess_input(guess_word, input)
    if guess_word.include?(input)
      @correct_letters.push(input)
      guess_word.each_with_index do |letter, i|
        next unless letter == input

        @letters_position[i] = letter
      end
    else
      @incorrect_letters.push(input)
    end
  end

  def play_game
    guess_word = split_guess_word
    add_blank_positions(guess_word)
    i = 11
    while i.positive?
      puts "You've left #{i} attempts"
      output_game_information(i)
      input = player_input
      pcocess_input(guess_word, input)
      break if check_if_game_won

      i -= 1 unless guess_word.include?(input)
    end
  end
end

test1 = CoreOfTheGame.new.play_game
