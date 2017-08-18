require 'rails_helper'
require 'algolia/webmock'

RSpec.describe Article, type: :model do
  before(:all) do
    Algolia.init(application_id: 'foo', api_key: 'bar')
  end

  around do |example|
    # Stub all Algolia requests
    # list indexes
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/indexes/).to_return(:body => '{ "items": [] }')
    # query index
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+/).to_return(:body => '{ "hits": [ { "objectID": 42 } ], "page": 1, "hitsPerPage": 1 }')
    # delete index
    WebMock.stub_request(:delete, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+/).to_return(:body => '{ "taskID": 42 }')
    # clear index
    WebMock.stub_request(:post, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/clear/).to_return(:body => '{ "taskID": 42 }')
    # add object
    WebMock.stub_request(:post, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+/).to_return(:body => '{ "taskID": 42 }')
    # save object
    WebMock.stub_request(:put, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/[^\/]+/).to_return(:body => '{ "taskID": 42 }')
    # partial update
    WebMock.stub_request(:put, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/[^\/]+\/partial/).to_return(:body => '{ "taskID": 42 }')
    # get object
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/[^\/]+/).to_return(:body => '{}')
    # delete object
    WebMock.stub_request(:delete, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/[^\/]+/).to_return(:body => '{ "taskID": 42 }')
    # batch
    WebMock.stub_request(:post, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/batch/).to_return(:body => '{ "taskID": 42 }')
    # settings
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/settings/).to_return(:body => '{}')
    WebMock.stub_request(:put, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/settings/).to_return(:body => '{ "taskID": 42 }')
    # browse
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/browse/).to_return(:body => '{}')
    # operations
    WebMock.stub_request(:post, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/operation/).to_return(:body => '{ "taskID": 42 }')
    # tasks
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/task\/[^\/]+/).to_return(:body => '{ "status": "published" }')
    # index keys
    WebMock.stub_request(:post, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/keys/).to_return(:body => '{ }')
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/keys/).to_return(:body => '{ "keys": [] }')
    # global keys
    WebMock.stub_request(:post, /.*\.algolia(net\.com|\.net)\/1\/keys/).to_return(:body => '{ }')
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/keys/).to_return(:body => '{ "keys": [] }')
    WebMock.stub_request(:get, /.*\.algolia(net\.com|\.net)\/1\/keys\/[^\/]+/).to_return(:body => '{ }')
    WebMock.stub_request(:delete, /.*\.algolia(net\.com|\.net)\/1\/keys\/[^\/]+/).to_return(:body => '{ }')
    # query POST
    WebMock.stub_request(:post, /.*\.algolia(net\.com|\.net)\/1\/indexes\/[^\/]+\/query/).to_return(:body => '{ "hits": [ { "objectID": 42 } ], "page": 1, "hitsPerPage": 1 }')




    example.run
  end

  let(:article) { Article.new title: 'my title', slug: 'a-slug', content: 1.upto(1000).to_a.join('.') }

  context "create" do
    before { allow(article).to receive(:add_to_algolia).and_call_original }
    before { allow(article).to receive(:remove_from_algolia) }

    before { article.save! }

    it { expect(article.new_record?).to be false }
    it { expect(article.content.length).to eq 3892 }
    it { expect(article.split_content.length).to eq 19 }
    it { expect(article).to have_received(:add_to_algolia).once }
    it { expect(article).to_not have_received(:remove_from_algolia) }
  end

  context "update" do
    before { allow(article).to receive(:add_to_algolia).and_call_original }
    before { allow(article).to receive(:remove_from_algolia) }

    context "changing the content" do
      before do
        article.save!
        article.content = article.content + "more"
        article.save!
      end

      it do
        expect(article).to have_received(:add_to_algolia).twice
        expect(article).to have_received(:remove_from_algolia).once
      end
    end

    context "without changing the content" do
      before do
        article.save!
        article.title = 'another title'
        article.save!
      end

      it do
        expect(article).to have_received(:add_to_algolia).twice
        expect(article).to_not have_received(:remove_from_algolia)
      end
    end
  end

  context "destroy" do
    before { article.save! }

    before { allow(article).to receive(:add_to_algolia).and_call_original }
    before { allow(article).to receive(:remove_from_algolia) }

    before { article.destroy }

    it { expect(article).to_not have_received(:add_to_algolia) }
    it { expect(article).to have_received(:remove_from_algolia).once }
  end
end
