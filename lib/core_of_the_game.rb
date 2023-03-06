# frozen_string_literal: true

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
    raise InvalidInput, "\nYou should enter one alphabetic character or 'save'" unless input.match?(/[[:alpha:]]/)\
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
    Dir.mkdir("../#{dirname}") unless File.exist?("../#{dirname}")
    puts "\nEnter name of the save-file"
    file_name = gets.chomp
    save_file = File.open("../#{dirname}/#{file_name}.json", 'w')
    save_file.puts save
    save_file.close
    puts "\nYour game has been saved."
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
    guess_word = @code_word.split(//)

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
