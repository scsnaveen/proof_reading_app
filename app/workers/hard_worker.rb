class HardWorker
  include Sidekiq::Worker

  def perform
    # Do something
  end
end
