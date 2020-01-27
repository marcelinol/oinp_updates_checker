require "aws-sdk-s3"
require "dotenv"
Dotenv.load("#{__dir__}/.env")

# TODO: Separate the file handling and S3 handling in two different classes
class FileHandler
  BUCKET = "oinp-updates-checker"
  PAGEBODY_FILENAME = "pagebody.txt".freeze
  LOGS_FILENAME = "run_logs.txt".freeze
  DEBUG_FILENAME = "debug_older_pagebody.txt".freeze

  PAGEBODY_LOCAL_PATH = "#{__dir__}/data/#{PAGEBODY_FILENAME}".freeze
  LOGS_LOCAL_PATH = "#{__dir__}/data/#{LOGS_FILENAME}".freeze

  def initialize
    Aws.config.update(
      region: ENV["AWS_REGION"],
      credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
    )

    @bucket = Aws::S3::Resource.new.bucket(BUCKET)
  end

  def download_saved_pagebody
    object = @bucket.object(PAGEBODY_FILENAME)
    object.get(response_target: PAGEBODY_LOCAL_PATH)
  end

  def save_pagebody_for_debugging
    object = @bucket.object(DEBUG_FILENAME)
    object.upload_file(PAGEBODY_LOCAL_PATH)
  end

  def save_new_pagebody(pagebody)
    object = @bucket.object(PAGEBODY_FILENAME)
    File.open(PAGEBODY_LOCAL_PATH, "w") do |file|
      file.write(pagebody)
    end
    object.upload_file(PAGEBODY_LOCAL_PATH)
  end

  def write_to_run_logs(message)
    object = @bucket.object(LOGS_FILENAME)
    object.get(response_target: LOGS_LOCAL_PATH)

    File.open(LOGS_LOCAL_PATH, "a") do |file|
      file.write(message)
    end

    object.upload_file(LOGS_LOCAL_PATH)
  end
end
