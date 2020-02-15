require "capybara/dsl"
require "capybara"
require_relative "mailer"
require_relative "custom_logger"
require_relative "file_handler"

Capybara.run_server = false
Capybara.current_driver = :selenium_headless
Capybara.app_host = "https://www.ontario.ca/page/2020-ontario-immigrant-nominee-program-updates"

class Crawler
  include Capybara::DSL

  def initialize
    @file_handler = FileHandler.new
    @custom_logger = CustomLogger.new(@file_handler)
  end

  def run
    @custom_logger.log_start
    pagebody = read_page_body

    @file_handler.download_saved_pagebody
    previous_pagebody = File.open(FileHandler::PAGEBODY_LOCAL_PATH, "r:UTF-8", &:read)
    pagebody_changed = pagebody != previous_pagebody

    if pagebody_changed
      @file_handler.save_pagebody_for_debugging

      @file_handler.save_new_pagebody(pagebody)

      diff = pagebodies_diff(pagebody, previous_pagebody)
      send_email_about_oinp_updates(diff)
    end

    @custom_logger.log_end(pagebody_changed)
  rescue => e
    @custom_logger.log_error(e)
  end

  private

  def read_page_body
    visit("/")

    find("#pagebody").text
  end

  def pagebodies_diff(pagebody, previous_pagebody)
    repetition_starts = (pagebody.length - previous_pagebody.length) + 10 # + 10 because there is the month in the beginning of the pagebody "January" that will always be there.
    pagebody[0..repetition_starts] + " (...)"
  end
end

Crawler.new.run
