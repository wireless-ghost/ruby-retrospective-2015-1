require 'matrix'

class RationalSequence
  include Enumerable

  def each
    @sequence.each do |element|
      yield element
    end
  end

  def add_up_diagonal(x, y, limit)
   while (x >= 0 && @sequence.length < limit) do
     if (x >= 0 && y >= 0 && !@sequence.include?(Rational(@matrix[y, x][0], @matrix[y, x][1])))
                        @sequence << Rational(@matrix.element(y, x).first, @matrix.element(y, x).last)
     end
     if y <= 0
        x += 1
                    break
           end
                  y -= 1
                  x += 1
          end
    return x, y
  end

        def add_down_diagonal(x, y, limit)
                while(y >=0 && @sequence.length < limit) do
                        if (y >= 0 && x >= 0 && !@sequence.include?(Rational(@matrix[y, x][0], @matrix[y, x][1])))
                                @sequence << Rational(@matrix.element(y, x).first, @matrix.element(y, x).last)
      end
      if x <= 0
        y += 1
        break
                        end
                                y += 1
                                x -= 1
                end
                return x, y
        end

  def initialize(limit)
    @sequence = Array.new
                @matrix = Matrix.build(limit, limit) {|x, y| [x+1, y+1]}
                y = 0
                x = 0
                while(@sequence.length < limit) do
                        x, y = add_down_diagonal(x, y, limit)
      x, y = add_up_diagonal(x, y, limit)
                end
  end
end

class Numeric
  def prime?
    return false if self <= 1
    (2...self).all? { |divisor| self % divisor != 0 }
  end
end

class PrimeSequence
  include Enumerable

  def each
    @sequence.each do |element|
      yield element
    end
  end

  def initialize(limit)
    @sequence = Array.new(0)
    next_number = 2
    while(@sequence.length < limit)
      if (next_number.prime?)
        @sequence << next_number
      end
      next_number+= 1
    end
  end
end

class FibonacciSequence
  include Enumerable

  def each
    @sequence.each do |element|
      yield element
    end
  end

  def initialize(limit, first: 0, second: 1)
    @sequence = Array.new(0)

    while(@sequence.length < limit)
      @sequence << first
      temp = first + second
      first = second
      second = temp
    end
  end
end

module DrunkenMathematician
  def self.meaningless(n)
    rationals = RationalSequence.new(n).to_a.partition do |rational|
      (rational.numerator.prime? || rational.denominator.prime?)
    end
    rationals.map { |group| (group.reduce(:*) || Rational(1, 1)) }.reduce(:/)
  end

  def self.aimless(n)
    rationals = []
    primes = PrimeSequence.new(n).to_a
    primes.each_slice(2) do |numerator, denominator|
      rationals << Rational(numerator, (denominator || 1))
    end
    rationals.reduce(:+)
  end

  def self.worthless(n)
    fibonacci = FibonacciSequence.new(n).to_a.last
    result = []
    n.downto(1) do |current|
      result = RationalSequence.new(current).to_a
      if (result.reduce(:+).to_i <= fibonacci)
        break
      end
   end
   result
  end
end
