#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

# Paperclip添付をActiveStorageへ移行するワンショットスクリプト。
# 実行例: bundle exec rails runner oneshot_scripts/migrate_paperclip_to_active_storage.rb
# DRY_RUN=1 で実際の添付は行わない。

DRY_RUN = ENV["DRY_RUN"].present?
BATCH_SIZE = (ENV["BATCH_SIZE"] || 200).to_i

TARGETS = [
  { model: UserExt, paperclip: :image, active_storage: :image, legacy_dirs: %w[profile user_ext user_exts users] },
  { model: Photo, paperclip: :image, active_storage: :image, legacy_dirs: %w[album albums photo photos] },
  { model: Board, paperclip: :attach, active_storage: :image, legacy_dirs: %w[board boards] },
  { model: BoardComment, paperclip: :attach, active_storage: :image, legacy_dirs: %w[board_comment board_comments board boards] },
  { model: Movie, paperclip: :movie, active_storage: :movie, legacy_dirs: %w[movie movies] },
  { model: Movie, paperclip: :thumb, active_storage: :thumb, legacy_dirs: %w[movie movies] },
  { model: BlogImage, paperclip: :image, active_storage: :image, legacy_dirs: %w[blog blogs blog_image blog_images] }
].freeze

def filename_for(record, paperclip_name, fallback_path)
  col = "#{paperclip_name}_file_name"
  if record.respond_to?(col) && record.public_send(col).present?
    record.public_send(col)
  else
    File.basename(fallback_path)
  end
end

def content_type_for(record, paperclip_name, paperclip)
  return paperclip.content_type if paperclip&.respond_to?(:content_type)

  col = "#{paperclip_name}_content_type"
  return record.public_send(col) if record.respond_to?(col) && record.public_send(col).present?

  nil
end

def id_partition_for(id)
  id.to_s.rjust(9, "0").scan(/\d{3}/).join("/")
end

def base_public_paths
  paths = []
  if ENV["PAPERCLIP_PUBLIC_ROOT"].present?
    paths << Pathname.new(ENV["PAPERCLIP_PUBLIC_ROOT"])
  end
  paths << Rails.root.join("public")
  shared_public = Rails.root.join("..", "..", "shared", "public")
  paths << shared_public if Dir.exist?(shared_public)
  paths.uniq.select { |p| Dir.exist?(p) }
end

def legacy_path_for(record, paperclip_name, legacy_dirs: nil)
  filename_col = "#{paperclip_name}_file_name"
  return nil unless record.respond_to?(filename_col)

  filename = record.public_send(filename_col)
  return nil if filename.blank?

  class_dirs = []
  if legacy_dirs.present?
    class_dirs.concat(Array(legacy_dirs))
  end
  class_dirs << record.class.name.underscore
  class_dirs << record.class.name.underscore.pluralize
  class_dirs = class_dirs.uniq

  attachment_candidates = [paperclip_name.to_s, paperclip_name.to_s.pluralize].uniq
  style_candidates = %w[original large thumb].freeze
  ids = [record.id]
  ids << record.blog_id if record.respond_to?(:blog_id) && record.blog_id.present?
  ids << record.album_id if record.respond_to?(:album_id) && record.album_id.present?
  ids << record.board_id if record.respond_to?(:board_id) && record.board_id.present?
  ids = ids.uniq
  partition = id_partition_for(record.id)

  base_paths = base_public_paths.flat_map { |base| [base.join("system"), base.join("upload")] }

  base_paths.each do |base|
    class_dirs.each do |class_dir|
      attachment_candidates.each do |attachment|
        style_candidates.each do |style|
          path = File.join(base, class_dir, attachment, partition, style, filename)
          return path if File.exist?(path)
        end
      end
    end
  end

  base_paths.each do |base|
    class_dirs.each do |class_dir|
      attachment_candidates.each do |attachment|
        style_candidates.each do |style|
          ids.each do |id|
            path = File.join(base, class_dir, attachment, id.to_s, style, filename)
            return path if File.exist?(path)
          end
        end
      end
    end
  end

  base_paths.each do |base|
    class_dirs.each do |class_dir|
      style_candidates.each do |style|
        ids.each do |id|
          path = File.join(base, class_dir, id.to_s, style, filename)
          return path if File.exist?(path)
        end
      end
    end
  end

  if record.respond_to?(:album_id) && record.album_id.present?
    base_paths.each do |base|
      style_candidates.each do |style|
        path = File.join(base, "album", record.album_id.to_s, record.id.to_s, style, filename)
        return path if File.exist?(path)
      end
    end
  end

  glob_candidates = [
    *class_dirs.flat_map do |class_dir|
      base_paths.map { |base| File.join(base, class_dir, "*", partition, "*", filename) }
    end,
    *class_dirs.flat_map do |class_dir|
      base_paths.map { |base| File.join(base, class_dir, "*", record.id.to_s, "*", filename) }
    end
  ]

  glob_candidates.each do |pattern|
    found = Dir.glob(pattern).first
    return found if found.present?
  end

  nil
end

def migrate_attachment(record, paperclip_name, active_storage_name, legacy_dirs: nil)
  paperclip = record.respond_to?(paperclip_name) ? record.public_send(paperclip_name) : nil

  if ActiveStorage::Attachment.exists?(record: record, name: active_storage_name.to_s)
    return [:already, nil]
  end

  if paperclip&.respond_to?(:path)
    path = paperclip.path
  else
    path = legacy_path_for(record, paperclip_name, legacy_dirs: legacy_dirs)
  end
  return [:missing, path] if path.blank? || !File.exist?(path)

  if DRY_RUN
    return [:dry_run, path]
  end

  File.open(path, "rb") do |io|
    blob = ActiveStorage::Blob.create_and_upload!(
      io: io,
      filename: filename_for(record, paperclip_name, path),
      content_type: content_type_for(record, paperclip_name, paperclip),
      identify: false
    )
    ActiveStorage::Attachment.create!(record: record, name: active_storage_name.to_s, blob: blob)
  end

  [:ok, path]
end

TARGETS.each do |target|
  model = target[:model]
  paperclip_name = target[:paperclip]
  active_storage_name = target[:active_storage]
  legacy_dirs = target[:legacy_dirs]
  filename_col = "#{paperclip_name}_file_name"
  scope = model
  scope = scope.where.not(filename_col => nil) if model.column_names.include?(filename_col)

  puts "== #{model.name}##{paperclip_name} -> #{active_storage_name} (batch_size=#{BATCH_SIZE}) =="
  counters = Hash.new(0)

  scope.find_each(batch_size: BATCH_SIZE) do |record|
    status, path = migrate_attachment(record, paperclip_name, active_storage_name, legacy_dirs: legacy_dirs)
    counters[status] += 1

    next if [:ok, :already].include?(status)
    puts "[#{status}] #{model.name} id=#{record.id} path=#{path || 'N/A'}"
  end

  puts "---- result #{model.name}##{paperclip_name} -> #{active_storage_name} ----"
  counters.sort_by { |k, _| k.to_s }.each do |key, count|
    puts "#{key}: #{count}"
  end
end
