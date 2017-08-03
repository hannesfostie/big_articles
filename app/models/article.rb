class Article < ActiveRecord::Base
  before_validation :set_slug

  def set_slug
    self.slug = title.strip.parameterize
  end

  def content=(new_content)
    write_attribute(:content, new_content)
    reparse_content
  end

  def reparse_content
    self.html_content = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new).render(content)
  end
end
