require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    # Generate random grid
    @letters = 12.times.map { [*('A'..'Z')].sample }
  end

  def score
    word = params[:word]
    letters = params[:letters]

    # The word can't be built out of the original grid
    if !word_in_grid?(word, letters)
      @result = {
        message: "Sorry but #{word.upcase} can't be built out of #{letters.gsub(' ', ',')}",
        score: session[:score] || 0
      }
    elsif !word_exist?(word)
      # The word is valid according to the grid, but is not a valid English word
      @result = {
        message: "Sorry but #{word.upcase} doesn't seem to be a valid English word...",
        score: session[:score] || 0
      }
    else
      # The word is valid according to the grid and is an English word
      @result = {
        message: "Congratulations! #{word.upcase} is a valid English word!",
        score: (session[:score] || 0) + word.length
      }
      session[:score] = (session[:score] || 0) + word.length
    end
  end

  private

  def word_in_grid?(word, grid)
    word_up = word.upcase
    word_up.chars.all? do |letter|
      grid.count(letter).positive? && word_up.count(letter) <= grid.count(letter)
    end
  end

  def word_exist?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    dict_serialized = open(url).read
    dict = JSON.parse(dict_serialized)
    dict['found']
  end
end
