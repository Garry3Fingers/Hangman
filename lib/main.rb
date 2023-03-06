# frozen_string_literal: true

require 'colorize'
require 'json'
require_relative 'guess_word'
require_relative 'core_of_the_game'

class InvalidInput < StandardError; end

# This class implements the launch or a loading of the game
class GameHangman
  def initialize
    puts "\nWelcome to the Hangman! This is a guessing game."
    puts 'Type "new" to start a new game or "load" to load a saved game.'
  end

  private

  def player_input
    input = gets.chomp
    input = input.downcase
    check_words = %w[new load]
    raise InvalidInput, "\nYou should enter 'new' or 'load'" unless check_words.include?(input)
  rescue InvalidInput => e
    puts e
    retry
  else
    input
  end

  def process_save_file(name_file)
    save_file = File.open("save_files/#{name_file}.json", 'r')
    save_data = save_file.read
    save_file.close
    hash_data = JSON.parse save_data
    hash_data.to_a[1][1]
  end

  def load_save
    puts "\nSelect the save file and enter its name.\n\n"

    # Specify your own directory here
    Dir.chdir('/home/garry3fingers/repos/Hangman/')

    puts files = Dir.glob('save_files/*').map { |name| name.delete_prefix('save_files/').delete_suffix('.json') }

    name_file = gets.chomp
    raise InvalidInput, "\nYou are entering an invalid file name" unless files.any? { |name| name == name_file }
  rescue InvalidInput => e
    puts e
    retry
  else
    process_save_file(name_file)
  end

  def start_game
    answer = player_input

    case answer
    when 'new'
      new_game = CoreOfTheGame.new(GuessWord.new.random_word, [], [], [], 11)
      new_game.play_game
    when 'load'
      save = load_save
      save_game = CoreOfTheGame.new(save[0], save[1], save[2], save[3], save[4])
      save_game.play_game
    end
  end

  public

  def play_game
    start_game
    puts "\nDo you want to play again? Enter 'yes' or whatever."
    answer = gets.chomp

    if answer.downcase == 'yes'
      GameHangman.new.play_game
    else
      puts "\nThanks for playing!"
    end
  end
end

GameHangman.new.play_game
