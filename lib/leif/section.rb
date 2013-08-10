class Section
  attr_reader :io
  def empty?() @empty end

  def initialize(io)
    @io    = io
    @empty = true
  end

  def self.banner(banner, io = $stdout, &message)
    new(io).banner(banner, &message)
  end

  def banner(banner, &message)
    io.puts "-- #{banner} --"
    yield self
    print '[empty]' if empty?
  end

  def print(message)
    @empty = false
    Array(message).each do |line|
      io.puts "  #{line}"
    end
  end
end
