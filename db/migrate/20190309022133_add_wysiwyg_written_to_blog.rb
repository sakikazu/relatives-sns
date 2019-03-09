class AddWysiwygWrittenToBlog < ActiveRecord::Migration[5.2]
  def change
    add_column :blogs, :wysiwyg_written, :boolean, default: false
  end
end
