json.extract! article, :id, :title, :content, :html_content, :slug, :created_at, :updated_at
json.url article_url(article, format: :json)
