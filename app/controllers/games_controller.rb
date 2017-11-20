require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start_time = Time.now
  end

  def score
    @word = params[:word].upcase
    @letters = params[:grid]
    @start_time = params[:time].to_datetime
    if !included?(@word, @letters)
      @result = "Sorry but #{@word} can't be built with #{@letters.gsub(" ", ", ")}."
      @score = 0
    elsif !valid_word?(@word)
      @result = "Sorry but #{@word} does not seem to be an English word..."
      @score = 0
    else
      @result = "Congratulations! #{@word} is a valid English word!"
      @score = compute_score(@word, Time.now - @start_time)
    end
    session[:score].nil? ? session[:score] = @score.round(1) : session[:score] += @score.round(1)
  end

  private

  def valid_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    html_file = open(url).read
    html_doc = JSON.parse(html_file)
    return html_doc["found"]
  end

  def included?(guess, grid)
    return guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    return time_taken > 60.0 ? 0 : (attempt.size * (1.0 - time_taken / 60.0)).round(1)
  end

end
