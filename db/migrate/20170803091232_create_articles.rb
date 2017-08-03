class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.text :html_content
      t.string :slug

      t.timestamps null: false
    end
  end
end
