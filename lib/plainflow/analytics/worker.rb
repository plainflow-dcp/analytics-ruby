require 'plainflow/analytics/defaults'
require 'plainflow/analytics/utils'
require 'plainflow/analytics/defaults'
require 'plainflow/analytics/request'

module Plainflow
  class Analytics
    class Worker
      include Plainflow::Analytics::Utils
      include Plainflow::Analytics::Defaults

      # public: Creates a new worker
      #
      # The worker continuously takes messages off the queue
      # and makes requests to the plainflow.com api
      #
      # queue   - Queue synchronized between client and worker
      # secret_key  - String of the project's Write key
      # options - Hash of worker options
      #           batch_size - Fixnum of how many items to send in a batch
      #           on_error   - Proc of what to do on an error
      #
      def initialize(queue, secret_key, options = {})
        symbolize_keys! options
        @queue = queue
        @secret_key = secret_key
        @batch_size = options[:batch_size] || Queue::BATCH_SIZE
        @on_error = options[:on_error] || Proc.new { |status, error| }
        @batch = []
        @lock = Mutex.new
      end

      # public: Continuously runs the loop to check for new events
      #
      def run
        until Thread.current[:should_exit]
          return if @queue.empty?

          @lock.synchronize do
            until @batch.length >= @batch_size || @queue.empty?
              @batch << @queue.pop
            end
          end

          res = Request.new.post @secret_key, @batch

          @on_error.call res.status, res.error unless res.status == 200

          @lock.synchronize { @batch.clear }
        end
      end

      # public: Check whether we have outstanding requests.
      #
      def is_requesting?
        @lock.synchronize { !@batch.empty? }
      end
    end
  end
end
