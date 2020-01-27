require 'capybara/dsl'
require 'capybara'
require_relative 'mailer'
require_relative 'custom_logger'

Capybara.run_server = false
Capybara.current_driver = :selenium_headless
Capybara.app_host = "https://www.ontario.ca/page/2020-ontario-immigrant-nominee-program-updates"

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
  File.open("#{__dir__}/run_logs.txt", "a") do |file|
    file.write("Crawling started at #{Time.now}. ")
  end
end

def log_end(updated)
  File.open("#{__dir__}/run_logs.txt", "a") do |file|
    file.write("Finished at #{Time.now}.")
    if updated
      file.write(" The OINP has a new update.\n")
    else
      file.write(" The OINP has no new updates.\n")
    end
  end

  message_to_log = File.read("run_logs.txt")
  CustomLogger.new.log(message_to_log)
end

def run
  log_start
  crawler = MyCapybara::Crawler.new
  pagebody = crawler.read_page_body
  previous_pagebody = File.read("#{__dir__}/pagebody.txt")
  updated = pagebody != previous_pagebody
  if updated
    # Save the older pagebody just for debugging purposes
    File.open("#{__dir__}/debug_older_pagebody.txt", "w") do |file|
      file.write("#{previous_pagebody}")
    end

    # Updates the file with the current pagebody
    File.open("#{__dir__}/pagebody.txt", "w") do |file|
      file.write("#{pagebody}")
    end

    repetition_starts = (pagebody.length - previous_pagebody.length) + 10 # + 10 because there is the month in the beginning of the pagebody "January" that will always be there.
    diff = pagebody[0..repetition_starts] + " (...)"
    send_email_about_oinp_updates(diff)
  end
  log_end(updated)
end

run
