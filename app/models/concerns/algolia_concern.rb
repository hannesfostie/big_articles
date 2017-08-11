module AlgoliaConcern
  extend ActiveSupport::Concern

  # define callback to update Algolia
  included do
    after_commit :add_to_algolia, on: [:create, :update]
    after_commit :remove_from_algolia, on: [:destroy]
  end

  # helper class methods
  class_methods do
    def algolia_index
      Algolia::Index.new("#{ENV['ALGOLIA_INDEX_NAME']}_#{Rails.env}")
    end

    def clear_index!
      algolia_index.clear
    end

    def reindex!
      Article.find_each do |article|
        article.add_to_algolia
      end
    end
  end

  # callback use to add/update an article to the index
  def add_to_algolia
    if previous_changes[:content] && previous_changes[:content].first.present?
      # while updating the content, the resulting split content might not be the same
      # let's remove the objects first
      remove_from_algolia
    end
    self.class.algolia_index.add_objects(to_algolia_records)
  end

  # callback use to remove an article from the index
  def remove_from_algolia
    self.class.algolia_index.delete_by_query('', filters: "id=#{id}")
  end

  private
  def to_algolia_records
    split_content.each_with_index.map do |content, index|
      {
        objectID: "#{id}_#{index}",
        id: id,
        content: content,
        title: title,
        created_at: created_at.to_i
      }
    end
  end

end
