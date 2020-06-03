require "capybara/dsl"
require "capybara"
require "sequel"
require_relative "mailer"
require_relative "custom_logger"
require_relative "file_handler"

# For the DB (move it to the db client later)
require "dotenv"
Dotenv.load("#{__dir__}/.env")

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
    page_body = read_page_body
    previous_page_body = db_client[:readings].order(:timestamp).last[:content]
    # Comparing the whole string was causing problems with telephone numbers not being loaded
    # so I'm now comparing only the first 1k characters, that should be enough to identify changes
    # in the page body
    chars_to_compare = 1000
    page_body_changed = page_body[0..chars_to_compare] != previous_page_body[0..chars_to_compare]

    puts "changed? #{page_body_changed}"
    if page_body_changed
      db_client[:readings].insert(
        content: page_body,
        timestamp: Time.now.getutc.to_i
      )

      diff = page_bodies_diff(page_body, previous_page_body)
      puts "diff: #{diff}"

      send_email_about_oinp_updates(diff)
    end

    @custom_logger.log_end(page_body_changed)
  rescue => e
    @custom_logger.log_error(e)
  end

  private

  # TODO: create DB client class
  def db_client
    @_db_client ||= Sequel.connect(
      adapter: :postgres,
      user: ENV["RDS_USERNAME"],
      password: ENV["RDS_PASSWORD"],
      host: ENV["RDS_HOST"],
      port: ENV["RDS_PORT"],
      database: "postgres",
      max_connections: 10,
    )
  end

  def read_page_body
    visit("/")

    find("#pagebody").text
  end

  def page_bodies_diff(page_body, previous_page_body)
    repetition_starts = (page_body.length - previous_page_body.length) + 10 # + 10 because there is the month in the beginning of the page_body "January" that will always be there.
    page_body[0..repetition_starts] + " (...)"
  end
end

Crawler.new.run
