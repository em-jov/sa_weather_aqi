require 'singleton'
require 'logger'

class AppLogger 
  include Singleton
  attr_reader :logger

  private
  def initialize
    @logger = Logger.new($stdout)
  end
end