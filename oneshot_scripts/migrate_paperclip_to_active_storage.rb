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

def migrate_attachment(record, paperclip_name, active_storage_name)
  paperclip = record.public_send(paperclip_name)
  return [:no_paperclip, nil] unless paperclip.respond_to?(:path)

  if ActiveStorage::Attachment.exists?(record: record, name: active_storage_name.to_s)
    return [:already, nil]
  end

  path = paperclip.path
  return [:missing, path] if path.blank? || !File.exist?(path)

  if DRY_RUN
    return [:dry_run, path]
  end

  File.open(path, "rb") do |io|
    blob = ActiveStorage::Blob.create_and_upload!(
      io: io,
      filename: filename_for(record, paperclip_name, path),
      content_type: paperclip.content_type,
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
