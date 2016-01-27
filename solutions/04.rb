require 'pp'

class Card
  attr_reader :rank, :suit

  ALL_RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]
  BELOTE_RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]
  SIXTY_SIX_RANKS = [9, :jack, :queen, :king, 10, :ace]

  SUITS = [:clubs, :diamonds, :hearts, :spades]

  SUIT_VALUES = { :clubs => 20, :diamonds => 30, :hearts => 40, :spades => 50 }

  def initialize(rank, suit)
    @rank, @suit = rank, suit
  end

  def <=>(other)
    [SUITS.index(other.suit), ALL_RANKS.index(other.rank)] <=>
    [SUITS.index(@suit), ALL_RANKS.index(@rank)]
  end

  def ==(other)
    [SUITS.index(other.suit), ALL_RANKS.index(other.rank)] ==
    [SUITS.index(@suit), ALL_RANKS.index(@rank)]
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end

  def suite_index
    SUITS.index(@suit)
  end

  def belote_rank
    BELOTE_RANKS.index(@rank)
  end

  def same_suit(others)
    others.any? { |other| suite_index == other.suite_index }
  end

  def index
    ALL_RANKS.index(@rank) + 2 + SUIT_VALUES[@suit]
  end
end

class Hand
  def initialize(cards)
    @cards = cards
  end

  def size
    @cards.size
  end

  def play_card
    @cards.pop
  end

  def allow_face_up?
    @cards.size <= 3
  end

  def highest_of_suit(suit)
    if @cards.any? { |card| card.suit == suit }
      suits = @cards.select { |card| card.suit == suit }
        return suits.sort.first
    end
  end

  def belote?
    kings = @cards.select do |card|
      card.belote_rank == Card::BELOTE_RANKS.index(:king)
    end
    queens = @cards.select do |card|
      card.belote_rank == Card::BELOTE_RANKS.index(:queen)
    end

    kings.select { |king| king.same_suit(queens) }.length > 0
  end

  def check(cards, count)
    if cards.size < count
      return false
    end
    if cards[0] + count - 1 == cards[count - 1]
      return true
    end
    return check(cards.take(cards.length - 1).to_a, count)
  end

  def tierce?
    cards = @cards.dup
    card_indexes = cards.sort.reverse.map(&:index).to_a
    card_indexes.each_cons(3).any? { |a, b, c| (a + 2) == c && (b + 1) == c }
  end

  def quarte?
    cards = @cards.dup
    return false if cards.count < 4
    card_indexes = cards.sort.reverse.map(&:index).to_a.each_cons(4)
    card_indexes.any? { |a, b, c, d| a + 3 == d && b + 2 == d && c + 1 == d }
  end

  def quint?
    cards = @cards.dup
    return false if cards.count < 5
    card_indexes = cards.sort.reverse.map(&:index).to_a.each_cons(5)
    card_indexes.any? do |a, b, c, d, e|
			a + 4 == e && b + 3 == e && c + 2 == e && d + 1 == e
		end
  end

  def four_of_a_kind?(rank)
    dummy_card = Card.new(rank, :spades)
    fours = @cards.select do |card|
      card.belote_rank == dummy_card.belote_rank
    end
    fours != nil ? fours.size == 4 : false
  end

  def carre_of_jacks?
    four_of_a_kind?(:jack)
  end

  def carre_of_nines?
    four_of_a_kind?(9)
  end

  def carre_of_aces?
    four_of_a_kind?(:ace)
  end

  def twenty?(trump_suit)
    no = @cards.select { |card| card.suit != trump_suit }
    king_card = Card.new(:king, :spades)
    queen_card = Card.new(:queen, :spades)
    kings = no.select { |card| card.belote_rank == king_card.belote_rank }
    queens = no.select { |card| card.belote_rank == queen_card.belote_rank }

    kings.any? { |king| king.same_suit(queens) }
  end

  def forty?(trump_suit)
    trump = @cards.select { |card| card.suit == trump_suit }
    king_card = Card.new(:king, :spades)
        queen_card = Card.new(:queen, :spades)
    kings = trump.select { |card| card.belote_rank == king_card.belote_rank }
    queens = trump.select { |card| card.belote_rank == queen_card.belote_rank }

    kings.any? { |king| king.same_suit(queens) }
  end
end

class Deck
  include Enumerable

  alias_method :top_card, :first

  def initialize(cards = nil)
    @cards = (cards || generate_all_cards)
  end

  def each(&block)
    @cards.map do |card|
      yield card
    end
  end

  def size
    @cards.size
  end

  def draw_top_card
    @cards.shift
  end

  def draw_bottom_card
    @cards.pop
  end

  def top_card
    @cards.first
  end

  def bottom_card
    @cards.last
  end

  def shuffle
    @cards = @cards.shuffle
  end

  def sort
    @cards = @cards.sort
  end

  def to_s
    @cards.map(&:to_s).join("\n")
  end

  def deal(number)
    Hand.new(@cards.pop(number))
  end

  private

  def generate_all_cards
    Card::ALL_RANKS.product(Card::SUITS).map { |card| Card.new(*card) }.shuffle
  end

  def generate_belote_cards
    Card::BELOTE_RANKS.product(Card::SUITS).map do |card|
      Card.new(*card)
    end.shuffle
  end

  def generate_sixty_six_cards
    Card::SIXTY_SIX_RANKS.product(Card::SUITS).map do |card|
      Card.new(*card)
    end.shuffle
  end
end

class WarDeck < Deck
  def deal
    super(26)
  end
end

class BeloteDeck < Deck
  def initialize(cards = nil)
    super(cards || generate_belote_cards)
  end

  def deal
    super(8)
  end
end

class SixtySixDeck < Deck
  def initialize(cards = nil)
    super(cards || generate_sixty_six_cards)
  end

  def deal
    super(6)
  end
end
