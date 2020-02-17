require "open-uri"
class GamesController < ApplicationController
  def new
    @letters = generate_letters
  end

  def score
    @letters = params[:letters].downcase.split(" ")
    @word = params[:word].downcase
    cookies[:score] = 0 if cookies[:score].nil?
    @result =
      if word_exist?(@word) && letters_check?(@word, @letters)
        cookies[:score] = cookies[:score].to_i + @word.length
        "<strong>Congratulations!</strong> #{@word.upcase} is a valid English word".html_safe
      elsif word_exist?(@word) && !letters_check?(@word, @letters)
        "Sorry but <strong>#{@word.upcase}</strong> can't be built out of #{@letters.join(" ")}".html_safe
      else
        "Sorry but <strong>#{@word.upcase}</strong> is not a valid English word".html_safe
      end
  end
end

private

def generate_letters
  alphabet = ('A'..'Z').to_a
  vowels = %w[A E I O U]
  letters = []
  # generate a letters one shorter than max letters size
  letters << alphabet.sample until letters.length == 9
  # input a vowel so there is at least one
  letters << vowels.sample
  letters
end

def word_exist?(word)
  url = "https://wagon-dictionary.herokuapp.com/#{word}"
  object = open(url).read
  word_check = ActiveSupport::JSON.decode(object)
  word_check["found"]
end

def letters_check?(word, letters)
  checked = word
  letters.each do |letter|
    checked = checked.delete(letter)
  end
  checked == ""
end
