require 'capybara/dsl'
require 'capybara'
require_relative 'mailer'
require_relative 'custom_logger'

Capybara.run_server = false
Capybara.current_driver = :selenium_headless
Capybara.app_host = "https://www.ontario.ca/page/2020-ontario-immigrant-nominee-program-updates"
PAGEBODY = "#{__dir__}/pagebody.txt".freeze
LOGS = "#{__dir__}/run_logs.txt".freeze
DEBUG = "#{__dir__}/debug_older_pagebody.txt".freeze


module MyCapybara
  class Crawler
    include Capybara::DSL

    def read_page_body
      visit("/")

      find("#pagebody").text
    end
  end
end

def log_start
  File.open(DEBUG, "a") do |file|
    file.write("[#{Time.now}] Crawling started.\n")
  end
end

def log_end(updated)
  File.open(DEBUG, "a") do |file|
    file.write("[#{Time.now}] Finished.")
    if updated
      file.write(" The OINP has a new update.\n")
    else
      file.write(" The OINP has no new updates.\n")
    end
    file.write("\n")
  end

  message_to_log = File.read(DEBUG)
  CustomLogger.new.log(message_to_log)
end

def log_error(error)
  File.open(DEBUG, "a") do |file|
    file.write("[#{Time.now}] Crawler failed.\n")
    file.write("Error: #{error}. \n\n")
  end
end

def run
  log_start
  puts "Starting the crawler"
  begin
    crawler = MyCapybara::Crawler.new
    pagebody = crawler.read_page_body
  rescue => e
    log_error(e)
  end

  previous_pagebody = File.read(PAGEBODY)
  updated = pagebody != previous_pagebody
  puts "was the page updated? #{updated}"

  if updated
    begin
      # Save the older pagebody just for debugging purposes
      File.open("#{__dir__}/debug_older_pagebody.txt", "w") do |file|
        file.write("#{previous_pagebody}")
      end

      # Updates the file with the current pagebody
      File.open(PAGEBODY, "w") do |file|
        file.write("#{pagebody}")
      end

      repetition_starts = (pagebody.length - previous_pagebody.length) + 10 # + 10 because there is the month in the beginning of the pagebody "January" that will always be there.
      diff = pagebody[0..repetition_starts] + " (...)"
      send_email_about_oinp_updates(diff)
    rescue => e
      log_error(e)
    end
  end
  log_end(updated)
end

run
