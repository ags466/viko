# frozen_string_literal: true

require File.expand_path('test_helper', __dir__)

# rubocop:disable Metrics/BlockLength
describe ValidateWebsite::Validator do
  let(:subject) { ValidateWebsite::Validator }

  before do
    WebMock.reset!
    @http = Spidr::Agent.new
  end

  describe('xhtml1') do
    it 'can ignore' do
      name = 'w3.org-xhtml1-strict-errors'
      file = File.join('test', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: File.open(file).read,
                          content_type: 'text/html')
      @xhtml1_page = @http.get_page(page.url)
      ignore = /width|height|Length/
      validator = subject.new(@xhtml1_page.doc,
                              @xhtml1_page.body,
                              ignore: ignore)
      _(validator.valid?).must_equal true
      _(validator.errors).must_equal []
    end

    it 'xhtml1-strict should be valid' do
      name = 'xhtml1-strict'
      dtd_uri = 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
      file = File.join('test', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: File.open(file).read,
                          content_type: 'text/html')
      @xhtml1_page = @http.get_page(page.url)
      ignore = /width|height|Length/
      validator = subject.new(@xhtml1_page.doc,
                              @xhtml1_page.body,
                              ignore: ignore)
      _(validator.dtd.system_id).must_equal dtd_uri
      _(validator.namespace).must_equal name
      _(validator.valid?).must_equal true
      _(validator.errors).must_equal []
    end
  end

  describe('html5') do
    describe('when valid') do
      before do
        validator_res = File.join('test', 'data', 'validator.nu-success.json')
        stub_request(:any, /#{subject.html5_validator_service_url}/)
          .to_return(body: File.open(validator_res).read)
      end
      it 'html5 should be valid' do
        name = 'html5'
        file = File.join('test', 'data', "#{name}.html")
        page = FakePage.new(name,
                            body: File.open(file).read,
                            content_type: 'text/html')
        @html5_page = @http.get_page(page.url)
        validator = subject.new(@html5_page.doc,
                                @html5_page.body)
        _(validator.valid?).must_equal true
      end
    end

    describe('when not valid') do
      before do
        validator_res = File.join('test', 'data', 'validator.nu-failure.json')
        stub_request(:any, /#{subject.html5_validator_service_url}/)
          .to_return(body: File.open(validator_res).read)
        name = 'html5-fail'
        file = File.join('test', 'data', "#{name}.html")
        page = FakePage.new(name,
                            body: File.open(file).read,
                            content_type: 'text/html')
        @html5_page = @http.get_page(page.url)
      end

      describe('with nu') do
        it 'should have an array of errors' do
          validator = subject.new(@html5_page.doc,
                                  @html5_page.body,
                                  html5_validator: :nu)
          _(validator.valid?).must_equal false
          _(validator.errors.size).must_equal 3
        end

        it 'should exclude errors ignored by :ignore option' do
          ignore = /Unclosed element/
          validator = subject.new(@html5_page.doc,
                                  @html5_page.body,
                                  ignore: ignore,
                                  html5_validator: :nu)
          _(validator.valid?).must_equal false
          _(validator.errors.size).must_equal 1
        end
      end

      describe('with nokogumbo') do
        it 'have an array of errors' do
          validator = subject.new(@html5_page.doc,
                                  @html5_page.body,
                                  html5_validator: :nokogumbo)
          _(validator.valid?).must_equal false
          _(validator.errors.size).must_equal 1
        end

        it 'exclude errors ignored by :ignore option' do
          ignore = /That tag isn't allowed here/
          validator = subject.new(@html5_page.doc,
                                  @html5_page.body,
                                  ignore: ignore,
                                  html5_validator: :nokogumbo)
          _(validator.valid?).must_equal true
          _(validator.errors.size).must_equal 0
        end
      end

      describe('with tidy') do
        it 'should have an array of errors' do
          skip('tidy is not installed') unless ValidateWebsite::Validator.tidy
          validator = subject.new(@html5_page.doc,
                                  @html5_page.body)
          _(validator.valid?).must_equal false
          _(validator.errors.size).must_equal 3
        end

        it 'should exclude errors ignored by :ignore option' do
          skip('tidy is not installed') unless ValidateWebsite::Validator.tidy
          ignore = /letter not allowed here|trimming empty/
          validator = subject.new(@html5_page.doc,
                                  @html5_page.body,
                                  ignore: ignore)
          _(validator.valid?).must_equal false
          _(validator.errors.size).must_equal 2
        end
      end
    end
  end

  describe('html4') do
    it 'should validate html4' do
      name = 'html4-strict'
      file = File.join('test', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: File.open(file).read,
                          content_type: 'text/html')
      @html4_strict_page = @http.get_page(page.url)
      validator = subject.new(@html4_strict_page.doc,
                              @html4_strict_page.body)
      validator.valid?
      _(validator.errors).must_equal []
    end
  end
end
