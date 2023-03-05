# This class send random word from the dictionary
class GuessWord
  def initialize
    @dictionary = File.open('../google-10000-english-no-swears.txt').readlines
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
