# frozen_string_literal: true

module God
  module Conditions
    # Trigger when a process is running or not running depending on attributes.
    #
    # Examples
    #
    #   # Trigger if process IS NOT running.
    #   on.condition(:process_running) do |c|
    #     c.running = false
    #   end
    #
    #   # Trigger if process IS running.
    #   on.condition(:process_running) do |c|
    #     c.running = true
    #   end
    #
    #   # Non-Watch Tasks must specify a PID file.
    #   on.condition(:process_running) do |c|
    #     c.running = false
    #     c.pid_file = "/var/run/mongrel.3000.pid"
    #   end
    class ProcessRunning < PollCondition
      # Public: The Boolean specifying whether you want to trigger if the
      # process is running (true) or if it is not running (false).
      attr_accessor :running

      # Public: The String PID file location of the process in question.
      # Automatically populated for Watches.
      attr_accessor :pid_file

      def pid
        pid_file ? File.read(pid_file).strip.to_i : watch.pid
      end

      def valid?
        valid = true
        valid &= complain("Attribute 'pid_file' must be specified", self) if pid_file.nil? && watch.pid_file.nil?
        valid &= complain("Attribute 'running' must be specified", self) if running.nil?
        valid
      end

      def test
        self.info = []

        pid = self.pid
        active = pid && System::Process.new(pid).exists?

        if running && active
          info.concat(['process is running'])
          true
        elsif !running && !active
          info.concat(['process is not running'])
          true
        else
          info.concat(['process is not running']) if running
          false
        end
      end
    end
  end
end
