class HardWorker
  include Sidekiq::Worker
  	sidekiq_options :retry => false

  def perform
    # Do something
  end
end
