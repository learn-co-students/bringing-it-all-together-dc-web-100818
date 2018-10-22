class Deck
  attr_accessor :rank, :suit

  def self.make_card
    @all =[]
    @numbers = ["A".."K"]
    @suits = ["Hearts", "Spades", "Clubs", "Diamonds"]
    @numbers.each do |num|
      @suits.each do |suit|
        @@all << [num, suit]
      end
    end
  end

  def initialize
    @cards = self.class.make_card
  end

  def self.choose_card
     chosen = self.cards.sample
     self.cards.delete(chosen)
    # self.cards.remove(chosen)
    # self.all

  end
end
