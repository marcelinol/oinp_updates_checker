require_relative "file_handler"

class CustomLogger
  def initialize
    @file_handler = FileHandler.new
  end

  def log_start
    @file_handler.write_to_run_logs("[#{Time.now}] Crawling started.\n")
  end

  def log_end(updated)
    message = "[#{Time.now}] Finished."
    if updated
      message << " The OINP has a new update.\n"
    else
      message << " The OINP has no new updates.\n"
    end
    message << "\n"
    @file_handler.write_to_run_logs(message)
  end

  def log_error(error)
    @file_handler.write_to_run_logs("[#{Time.now}] Crawler failed.\nError: #{error}. \n\n")
  end
end
