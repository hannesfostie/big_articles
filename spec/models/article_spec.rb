require 'rails_helper'

RSpec.describe Article, type: :model do
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
