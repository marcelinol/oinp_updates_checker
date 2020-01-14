require 'capybara/dsl'
require './mailer'
# require 'byebug'

Capybara.run_server = false
Capybara.current_driver = :selenium
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
  File.open("run_logs.txt", "a") do |file|
    file.write("Crawling started at #{Time.now}. ")
  end
end

def log_end(updated)
  File.open("run_logs.txt", "a") do |file|
    file.write("Finished at #{Time.now}.")
    if updated
      file.write(" The OINP has a new update.\n")
    else
      file.write(" The OINP has no new updates.\n")
    end
  end
end

def run
  log_start
  crawler = MyCapybara::Crawler.new
  pagebody = crawler.read_page_body
  previous_pagebody = File.read("pagebody.txt")
  updated = pagebody != previous_pagebody
  if updated
    # Save the older pagebody just for debugging purposes
    File.open("debug_older_pagebody.txt", "w") do |file|
      file.write("#{previous_pagebody}")
    end

    # Updates the file with the current pagebody
    File.open("pagebody.txt", "w") do |file|
      file.write("#{pagebody}")
    end

    # TODO: SEND EMAIL TO ME AND CARLA
    repetition_starts = (pagebody.length - previous_pagebody.length) + 10 # + 10 because there is the month in the beginning of the pagebody "January" that will always be there.
    diff = pagebody[0..repetition_starts] + " (...)"
    send_email_about_oinp_updates(diff)
  end
  log_end(updated)
end

run
