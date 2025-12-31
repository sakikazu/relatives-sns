#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "digest/sha1"

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

PAPERCLIP_HASH_SECRET = "7RD8csjgCa"
PAPERCLIP_HASH_DATA = ":class/:attachment/:id"

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

def basename_and_ext(record, paperclip_name)
  filename_col = "#{paperclip_name}_file_name"
  return [nil, nil] unless record.respond_to?(filename_col)

  filename = record.public_send(filename_col)
  return [nil, nil] if filename.blank?

  ext = File.extname(filename).delete(".")
  basename = File.basename(filename, ".*")
  [basename, ext.presence]
end

def paperclip_hash(record, paperclip_name)
  data = PAPERCLIP_HASH_DATA
           .gsub(":class", record.class.name.underscore)
           .gsub(":attachment", paperclip_name.to_s)
           .gsub(":id", record.id.to_s)
  Digest::SHA1.hexdigest("#{data}#{PAPERCLIP_HASH_SECRET}")
end

def paperclip_relative_paths(record, paperclip_name)
  case [record.class.name, paperclip_name.to_sym]
  when ["UserExt", :image]
    basename, ext = basename_and_ext(record, paperclip_name)
    return [] if basename.blank? || ext.blank?
    %w[original large thumb small].map do |style|
      File.join("upload", "profile", record.id.to_s, style, "#{basename}.#{ext}")
    end
  when ["Photo", :image]
    return [] if record.album_id.blank?
    _basename, ext = basename_and_ext(record, paperclip_name)
    return [] if ext.blank?
    hash = paperclip_hash(record, paperclip_name)
    %w[original large thumb].map do |style|
      File.join("upload", "album", record.album_id.to_s, record.id.to_s, style, "#{hash}.#{ext}")
    end
  when ["Board", :attach]
    basename, ext = basename_and_ext(record, paperclip_name)
    return [] if basename.blank? || ext.blank?
    %w[original large thumb].map do |style|
      File.join("upload", "board", record.id.to_s, style, "#{basename}.#{ext}")
    end
  when ["BoardComment", :attach]
    return [] if record.board_id.blank?
    basename, ext = basename_and_ext(record, paperclip_name)
    return [] if basename.blank? || ext.blank?
    %w[original large thumb].map do |style|
      File.join("upload", "board", record.board_id.to_s, "_res", record.id.to_s, style, "#{basename}.#{ext}")
    end
  when ["Movie", :movie]
    basename, ext = basename_and_ext(record, paperclip_name)
    return [] if basename.blank? || ext.blank?
    %w[original].map do |style|
      File.join("upload", "movie", record.id.to_s, style, "#{basename}.#{ext}")
    end
  when ["Movie", :thumb]
    basename, ext = basename_and_ext(record, paperclip_name)
    return [] if basename.blank? || ext.blank?
    %w[thumb large].map do |style|
      File.join("upload", "movie", record.id.to_s, "thumb", style, "#{basename}.#{ext}")
    end
  when ["BlogImage", :image]
    basename, ext = basename_and_ext(record, paperclip_name)
    return [] if basename.blank? || ext.blank?
    %w[original large thumb].map do |style|
      File.join("upload", "blog", record.id.to_s, style, "#{basename}.#{ext}")
    end
  else
    []
  end
end

def legacy_path_for(record, paperclip_name)
  relative_paths = paperclip_relative_paths(record, paperclip_name)
  return nil if relative_paths.empty?

  base_public_paths.each do |base|
    relative_paths.each do |relative|
      path = base.join(relative)
      return path.to_s if File.exist?(path)
    end
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
