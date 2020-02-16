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

  def initialize(file_handler, custom_logger, mailer)
    @file_handler = file_handler
    @custom_logger = custom_logger
    @mailer = mailer
  end

  def run
    @custom_logger.log_start

    page_body = page_body_changed
    if page_body.changed
      save_page_body(page_body.current)
      send_email(page_body)
    end

    @custom_logger.log_end(page_body.changed)
  rescue => e
    @custom_logger.log_error(e)
  end

  private

  def send_email(page_body)
    diff = pagebodies_diff(page_body.current, page_body.previous)
    @mailer.send_email_about_oinp_updates(diff)
  end

  def save_page_body(current_page_body)
    @file_handler.save_pagebody_for_debugging
    @file_handler.save_new_pagebody(current_page_body)
  end

  def page_body_changed
    pagebody = read_page_body

    @file_handler.download_saved_pagebody
    previous_pagebody = File.open(@file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME), "r:UTF-8", &:read)
    pagebody_changed = pagebody != previous_pagebody
    return OpenStruct.new({
      current: pagebody,
      previous: previous_pagebody,
      changed: pagebody_changed
    })
  end

  def read_page_body
    visit("/")

    find("#pagebody").text
  end

  def pagebodies_diff(pagebody, previous_pagebody)
    repetition_starts = (pagebody.length - previous_pagebody.length) + 10 # + 10 because there is the month in the beginning of the pagebody "January" that will always be there.
    pagebody[0..repetition_starts] + " (...)"
  end
end

# RUN
file_handler = FileHandler.new
custom_logger = CustomLogger.new(file_handler)
mailer = OinpMailer.new
Crawler.new(file_handler, custom_logger, mailer).run
