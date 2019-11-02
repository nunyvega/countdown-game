require 'open-uri'
require 'json'
require "date"

def generate_grid(grid_size)
  grid = []
  grid_size.times { grid << ('A'..'Z').to_a.sample }
  return grid
end

def run_game(attempt, grid, start_time, end_time)

  total_time = end_time - start_time
  word_exist = check_api(attempt)
  same_letters = compare_letters(grid, attempt)
  letter_count = count_letters(grid, attempt)

  result = { attempt: attempt,
             time: total_time,
             score: score(total_time, attempt.length, word_exist, same_letters, letter_count),
             message: generate_message(word_exist, same_letters, letter_count) }
  return result
end

def count_letters(grid, string)
  grid_letter_count = string_to_hash_counted(grid)
  string_array = string.gsub(/\W/, "").downcase.split('')
  string_letter_count = string_to_hash_counted(string_array)

  string_letter_count.each do |x|
    return false if grid_letter_count.key?(x[0]) == false
    return false if string_letter_count[x[0]] > grid_letter_count[x[0]]
  end
  return true
end

def string_to_hash_counted(array)
  final_hash = {}
  array.each do |x|
    if final_hash.key?(x.downcase)
      final_hash[x.downcase] += 1
    else
      final_hash[x.downcase] = 1
    end
  end
  return final_hash
end

def compare_letters(grid_array, string_input)
  # create new hashes
  letters_grid_hash = Hash.new(0)
  string_hash = Hash.new(0)
  # create array 4 input, remove spaces and downcase it
  clean_phrase_array = string_input.gsub(/\W/, "").downcase.split('')
  # convert arrays to hashes
  grid_array.each { |x| letters_grid_hash[x.downcase] = 0 }
  clean_phrase_array.each { |x| string_hash[x] = 0 }
  # compare hashes
  string_hash.each do |k|
    return false unless letters_grid_hash.key?(k[0])
  end
  return true
end

def score(total_time, length, word_exist, same_letters, letter_count)
  score = length * 1000 - total_time
  if word_exist == true && same_letters == true && letter_count == true
    return score
  else
    return 0
  end
end

def generate_message(word_exist, same_letters, letter_count)
  return "not in the grid" if same_letters == false

  return "not an english word" if word_exist == false

  return "not in the grid" if letter_count == false

  return "well done"
end

def check_api(word)
  url = "https://wagon-dictionary.herokuapp.com/#{word}"
  result_serialized = open(url).read
  result = JSON.parse(result_serialized)
  return result["found"]
end
