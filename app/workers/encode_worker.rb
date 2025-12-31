class EncodeWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :encode
  sidekiq_options retry: 1

  def perform(id)
    Rails.logger.info("encode start id=#{id} at=#{Time.zone.now.to_fs(:normal)}")
    movie = Movie.find(id)
    wait_for_movie_file(movie)
    movie.encode
    Rails.logger.info("encode done id=#{id}")
  rescue => e
    Rails.logger.error("encode failed id=#{id} error=#{e.class} message=#{e.message}")
    ExceptionNotifier.notify_exception(e) if defined?(ExceptionNotifier)
    raise
  end

  private

  def wait_for_movie_file(movie)
    attempts = 5
    while attempts > 0
      if movie.movie.attached? && movie.movie.blob&.service&.exist?(movie.movie.blob.key)
        return
      end
      sleep 0.5
      attempts -= 1
      movie.reload
    end

    raise ActiveStorage::FileNotFoundError, "movie file is not ready (id=#{movie.id})"
  end
end
