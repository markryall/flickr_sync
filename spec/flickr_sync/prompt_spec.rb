require_relative '../spec_helper.rb'

describe FlickrSync::Prompt do
  before do
    @inio = stub 'inio', :gets => ''
    @outio = stub 'outio', :print => nil
    @prompt = FlickrSync::Prompt.new @inio, @outio
  end

  describe '#ask' do
    it 'should write prompt with true default' do
      @outio.should_receive(:print).with 'Is this it [y] ? '
      @prompt.ask 'Is this it', true
    end

    it 'should write prompt with false default' do
      @outio.should_receive(:print).with 'Is this it [n] ? '
      @prompt.ask 'Is this it', false
    end

    it 'should return true when true is default and nothing is entered' do      
      @prompt.ask('anything', true).should be_true
    end

    it 'should return false when false is default and nothing is entered' do
      @prompt.ask('anything', false).should be_false
    end

    it 'should return false when true is default and n is entered' do
      @inio.should_receive(:gets).and_return 'n'
      @prompt.ask('anything', true).should be_false
    end

    it 'should return true when false is default and y is entered' do
      @inio.should_receive(:gets).and_return 'y'
      @prompt.ask('anything', true).should be_true
    end
  end
end