#!/usr/bin/env ruby
# frozen_string_literal: true

# Paperclip添付をActiveStorageへ移行するワンショットスクリプト。
# 実行例: bundle exec rails runner oneshot_scripts/migrate_paperclip_to_active_storage.rb
# DRY_RUN=1 で実際の添付は行わない。

DRY_RUN = ENV["DRY_RUN"].present?
BATCH_SIZE = (ENV["BATCH_SIZE"] || 200).to_i

TARGETS = [
  { model: UserExt, paperclip: :image, active_storage: :image },
  { model: Photo, paperclip: :image, active_storage: :image },
  { model: Board, paperclip: :attach, active_storage: :image },
  { model: BoardComment, paperclip: :attach, active_storage: :image },
  { model: Movie, paperclip: :movie, active_storage: :movie },
  { model: Movie, paperclip: :thumb, active_storage: :thumb },
  { model: BlogImage, paperclip: :image, active_storage: :image }
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

def legacy_path_for(record, paperclip_name)
  filename_col = "#{paperclip_name}_file_name"
  return nil unless record.respond_to?(filename_col)

  filename = record.public_send(filename_col)
  return nil if filename.blank?

  class_dir = record.class.name.underscore.pluralize
  attachment_candidates = [paperclip_name.to_s, paperclip_name.to_s.pluralize].uniq
  style_candidates = %w[original large thumb].freeze
  partition = id_partition_for(record.id)

  base_paths = [
    Rails.root.join("public/system"),
    Rails.root.join("public/upload")
  ]

  base_paths.each do |base|
    attachment_candidates.each do |attachment|
      style_candidates.each do |style|
        path = File.join(base, class_dir, attachment, partition, style, filename)
        return path if File.exist?(path)
      end
    end
  end

  base_paths.each do |base|
    attachment_candidates.each do |attachment|
      style_candidates.each do |style|
        [class_dir, class_dir.singularize].uniq.each do |klass|
          path = File.join(base, klass, attachment, record.id.to_s, style, filename)
          return path if File.exist?(path)
        end
      end
    end
  end

  glob_candidates = [
    Rails.root.join("public/system", class_dir, "*", partition, "*", filename).to_s,
    Rails.root.join("public/upload", class_dir, "*", record.id.to_s, "*", filename).to_s
  ]

  glob_candidates.each do |pattern|
    found = Dir.glob(pattern).first
    return found if found.present?
  end

  nil
end

def migrate_attachment(record, paperclip_name, active_storage_name)
  paperclip = record.respond_to?(paperclip_name) ? record.public_send(paperclip_name) : nil

  if ActiveStorage::Attachment.exists?(record: record, name: active_storage_name.to_s)
    return [:already, nil]
  end

  if paperclip&.respond_to?(:path)
    path = paperclip.path
  else
    path = legacy_path_for(record, paperclip_name)
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
  filename_col = "#{paperclip_name}_file_name"
  scope = model
  scope = scope.where.not(filename_col => nil) if model.column_names.include?(filename_col)

  puts "== #{model.name}##{paperclip_name} -> #{active_storage_name} (batch_size=#{BATCH_SIZE}) =="
  counters = Hash.new(0)

  scope.find_each(batch_size: BATCH_SIZE) do |record|
    status, path = migrate_attachment(record, paperclip_name, active_storage_name)
    counters[status] += 1

    next if [:ok, :already].include?(status)
    puts "[#{status}] #{model.name} id=#{record.id} path=#{path || 'N/A'}"
  end

  puts "---- result #{model.name}##{paperclip_name} -> #{active_storage_name} ----"
  counters.sort_by { |k, _| k.to_s }.each do |key, count|
    puts "#{key}: #{count}"
  end
end
