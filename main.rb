# frozen_string_literal: true

require 'colorize'
require 'json'

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
  def initialize(code_word, letters_position, correct_letters, incorrect_letters, rounds)
    @code_word = code_word
    @letters_position = letters_position
    @correct_letters = correct_letters
    @incorrect_letters = incorrect_letters
    @rounds = rounds
  end

  private

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

  def output_game_information(iteration, guess_word)
    add_blank_positions(guess_word) if @letters_position.empty?

    puts "\nYou've left #{iteration} attempts"

    puts "\nThe position of the letters in the word:"
    print_postion(@letters_position, :yellow)

    puts "\nCorrect letters:"
    print_postion(@correct_letters, :green)

    puts "\nIncorrecy letters:"
    print_postion(@incorrect_letters, :red)
  end

  def check_if_game_won
    return if @code_word != @letters_position.join

    true
  end

  def player_input
    input = gets.chomp
    input = input.downcase
    raise InvalidInput, 'You should enter one alphabetic character or "save"' unless input.match?(/[[:alpha:]]/)\
     && input.length == 1 || input == 'save'
  rescue InvalidInput => e
    puts e
    retry
  else
    input
  end

  def to_json(*args)
    {
      'json_class' => self.class.name,
      'data' => [@code_word, @letters_position, @correct_letters, @incorrect_letters, @rounds]
    }.to_json(*args)
  end

  def save_game
    save = to_json
    dirname = 'save_files'
    Dir.mkdir(dirname) unless File.exist? dirname
    puts "\nEnter name of the save-file"
    file_name = gets.chomp
    save_file = File.open("#{dirname}/#{file_name}.json", 'w')
    save_file.puts save
    save_file.close
  end

  def process_correct_letter(guess_word, input)
    @correct_letters.push(input)
    guess_word.each_with_index do |letter, i|
      next unless letter == input

      @letters_position[i] = letter
    end
  end

  def pcocess_input(guess_word, input)
    if input == 'save'
      save_game
    elsif guess_word.include?(input)
      process_correct_letter(guess_word, input)
    else
      @incorrect_letters.push(input)
    end
  end

  def endgame_message
    if check_if_game_won
      "\nCode word is '#{@code_word}'. Congratulations! You won!!!"
    else
      "\nYou don't have left attempts! Code word was '#{@code_word}'."
    end
  end

  public

  def play_game
    guess_word = split_guess_word

    while @rounds.positive?
      output_game_information(@rounds, guess_word)
      input = player_input
      pcocess_input(guess_word, input)
      break if check_if_game_won

      @rounds -= 1 unless guess_word.include?(input)
    end

    puts endgame_message
  end
end

# This class implements the launch or a loading of the game
class GameHangman
  def initialize
    puts 'Welcome to the Hangman! This is a guessing game.'
    puts 'Type "new" to start a new game or "load" to load a saved game.'
  end

  private

  def player_input
    input = gets.chomp
    input = input.downcase
    check_words = %w[new load]
    raise InvalidInput, 'You should enter "new" or "load"' unless check_words.include?(input)
  rescue InvalidInput => e
    puts e
    retry
  else
    input
  end

  def load_save
    save_file = File.open('save_files/test1.json', 'r')
    save_data = save_file.read
    save_file.close
    JSON.parse save_data
  end

  public

  def start_game
    answer = player_input

    if answer == 'new'
      new_game = CoreOfTheGame.new(GuessWord.new.random_word, [], [], [], 11)
      new_game.play_game
    elsif answer == 'load'
      save = load_save
      save_game = CoreOfTheGame.new(save['data'][0], save['data'][1], save['data'][2], save['data'][3], save['data'][4])
      save_game.play_game
    end
  end
end

GameHangman.new.start_game
