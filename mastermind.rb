# frozen_string_literal: false

module Mastermind
  CODE_LENGTH = 4
  TURNS_PER_ROUND = 12
  BOTH_CORRECT_SYM = 'x'.freeze
  COLOR_CORRECT_SYM = 'o'.freeze



end

# extending string to include colors
class String
  include Mastermind

  RESET_CODE = "\u001b[0m".freeze
  BOLD = "\u001b[1m".freeze
  GREEN_BG = "\u001b[42m".freeze
  RED_BG = "\u001b[41m".freeze
  PINK_BG = "\u001b[45;1m".freeze
  BLUE_BG = "\u001b[46m".freeze
  ORANGE_BG = "\u001b[43m".freeze
  WHITE_BG = "\u001b[47m".freeze
  BIG_DOT = "\u2b24".freeze
  ORANGE_TEXT = "\u001b[31m".freeze

  def format
    case self
    when '0' then format_zero
    when '1' then format_one
    when '2' then format_two
    when '3' then format_three
    when '4' then format_four
    when '5' then format_five
    when BOTH_CORRECT_SYM then format_both_correct
    when COLOR_CORRECT_SYM then format_color_correct
    else self
    end
  end

  private

  def format_one
    " #{BOLD}#{GREEN_BG} #{self} #{RESET_CODE} "
  end

  def format_two
    " #{BOLD}#{RED_BG} #{self} #{RESET_CODE} "
  end

  def format_three
    " #{BOLD}#{PINK_BG} #{self} #{RESET_CODE} "
  end

  def format_four
    " #{BOLD}#{BLUE_BG} #{self} #{RESET_CODE} "
  end

  def format_five
    " #{BOLD}#{ORANGE_BG} #{self} #{RESET_CODE} "
  end

  def format_zero
    " #{BOLD}#{WHITE_BG} #{self} #{RESET_CODE} "
  end

  def format_both_correct
    "#{BOLD}#{ORANGE_TEXT} #{BIG_DOT} #{RESET_CODE}"
  end

  def format_color_correct
    "#{BOLD} #{BIG_DOT} #{RESET_CODE}"
  end
end

# Holds information about 12 turns of Mastermind
class Round
  attr_reader :guess_count, :complete, :answer

  include Mastermind

  def initialize
    @guess_count = 0
    @answer = Answer.new
    @complete = false
  end

  def process_guess(guess)
    clue = Clues.new(guess, answer.code)
    self.guess_count += 1
    self.complete = true if clue.both_correct == CODE_LENGTH || self.guess_count >= TURNS_PER_ROUND
    clue
  end

  private

  attr_writer :complete, :guess_count
end

# Holds the 4-digit code for both the guesses and answers
class Code
  attr_reader :code

  include Mastermind
  def initialize(code = random_code)
    @code = code
  end

  def to_s
    new_str = ''
    code.each do |element|
      new_str += element.to_s.format
    end
    new_str
  end

  private

  def random_code
    code_arr = []
    CODE_LENGTH.times { code_arr << rand(6) }
    code_arr
  end
end

# Used for the answer from the codemaker
class Answer < Code; end

# Used for guesses provided by the codebreak
class Guess < Code; end

# Used for clues provided by the codemaker
class Clues
  attr_reader :both_correct, :color_correct

  include Mastermind
  def initialize(guess, answer)
    get_clue_vals(guess, answer)
    @both_correct = both_correct
    @color_correct = color_correct
  end

  def to_s
    t_arr = ([BOTH_CORRECT_SYM] * both_correct).concat([COLOR_CORRECT_SYM] * color_correct)
    new_str = ''
    t_arr.each do |element|
      new_str += element.to_s.format
    end
    new_str
  end

  private

  attr_writer :both_correct, :color_correct

  def get_clue_vals(guess, answer)
    total_shared = count_intersection_with_dups(guess, answer)
    self.both_correct = count_matches(guess, answer)
    self.color_correct = total_shared - both_correct
  end

  def count_intersection_with_dups(guess, answer)
    (guess | answer).reduce(0) do |acc, element|
      acc + [guess.count(element), answer.count(element)].min
    end
  end

  def count_matches(arr1, arr2)
    matches = 0
    CODE_LENGTH.times do |i|
      matches += 1 if arr1[i] == arr2[i]
    end
    matches
  end
end

def ask_guess(round)
  guess_str = "Round ##{round.guess_count + 1}: What will be your guess? Choose four numbers between 0 - 5."
  puts guess_str
  user_guess = gets.chomp
  until valid_input?(user_guess)
    puts "Incorrect format. #{guess_str} Example of the format is 0044."
    user_guess = gets.chomp
  end
  Guess.new(user_guess.split('').map(&:to_i))
end

def valid_input?(user_guess)
  user_guess.match?('\A[0-5]{4}\z')
end

def process_round_end(round, clue)
  if clue.both_correct == 4
    puts "You win! The code was #{round.answer}"
  else
    puts "You lose :(. The code was #{round.answer}"
  end
end

def play_round
  print_instructions
  round = Round.new
  until round.complete
    guess = ask_guess(round)
    clue = round.process_guess(guess.code)
    puts "#{guess}  Clues: #{clue}"
  end
  process_round_end(round, clue)
end

def print_instructions
  puts 'This is the game of Mastermind.'
  puts 'You have 12 rounds to guess the correct code. Each time you guess, you will receive feedback on the number of colors and positions you have guessed correctly as well as the number of colors you have guessed correctly.'
  puts "For each correct color and position, you will see a #{'x'.format}. And for each color you have correct, you will see a #{'o'.format}. \n"
end
