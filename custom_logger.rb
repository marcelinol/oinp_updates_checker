require_relative "file_handler"

# Should this class log everything locally and later send the file to S3?
class CustomLogger
  def initialize(file_handler)
    @file_handler = file_handler
  end

  def log_start
    @file_handler.write_to_run_logs("[#{current_time}] Crawling started.\n")
  end

  def log_end(updated)
    message = "[#{current_time}] Finished."
    if updated
      message << " The OINP has a new update.\n"
    else
      message << " The OINP has no new updates.\n"
    end
    message << "\n"
    @file_handler.write_to_run_logs(message)
  end

  def log_error(error)
    @file_handler.write_to_run_logs("[#{current_time}] Crawler failed.\nError: #{error}. \n\n")
  end

  private

  def current_time
    Time.now.utc.localtime("-05:00")
  end
end
