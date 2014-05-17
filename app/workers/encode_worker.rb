class EncodeWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :encode
  sidekiq_options retry: false

  def perform(id)
    p "---------------------- encode start (#{Time.now.to_s})  --------------------"
    movie = Movie.find(id)
    movie.encode
  end
end
