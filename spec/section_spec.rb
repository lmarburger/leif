require 'stringio'
require 'leif/section'

describe Section do
  let(:io)     { StringIO.new }
  let(:banner) { 'Banner' }
  subject { io.string }

  describe '.banner' do
    it 'yields itself' do
      expect {|probe| Section.banner(banner, io, &probe) }.
        to yield_with_args(Section)
    end
  end

  describe '.print' do
    let(:message) { 'message' }
    let(:body)    { ->(out) { out.print message } }
    before do Section.banner(banner, io, &body) end

    it 'prints the banner and message' do
      expect(subject).to eq(<<MSG)
-- Banner --
  message
MSG
    end

    context 'with an array of messages' do
      let(:message) { %w(one two three) }

      it 'prints the banner and message' do
        expect(subject).to eq(<<MSG)
-- Banner --
  one
  two
  three
MSG
      end
    end

    context 'without a message' do
      let(:body) { ->(out) {} }
      it 'prints the banner and message' do
        expect(subject).to eq(<<MSG)
-- Banner --
  [empty]
MSG
      end
    end
  end
end
