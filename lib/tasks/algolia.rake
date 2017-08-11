namespace :algolia do
  desc 'Set algolia\'s index settings'
  task set_settings: :environment do
    Article.algolia_index.set_settings({
      searchableAttributes: ['unordered(title)', 'unordered(content)'],
      # TODO
    })
  end
end
