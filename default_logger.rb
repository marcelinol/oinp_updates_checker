require "logstash-logger"
require "dotenv"
Dotenv.load("#{__dir__}/.env")

class DefaultLogger
  def initialize
    LogStashLogger.configure do |config|
      config.customize_event do |event|
        event["token"] = ENV["LOGZ_IO_TOKEN"]
      end
    end
    @logger = LogStashLogger.new(type: :tcp, host: "listener.logz.io", port: 5050)
  end

  def info(message)
    @logger.info(message)
  end

  def error(message)
    @logger.error("[ERROR] #{message}")
  end
end

DefaultLogger.new