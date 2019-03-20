class EncodeWorker
  include Sidekiq::Worker
  # sidekiq_options queue: :encode
  sidekiq_options retry: false

  def perform(id)
    p "---------------------- encode start (#{Time.now.to_s})  --------------------"
    # memo つぶやきのレスから動画投稿時、sleepを入れないとfindのところで止まってしまうので
    sleep 2
    movie = Movie.find(id)
    movie.encode
  end
end
