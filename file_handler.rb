require "aws-sdk-s3"
require "dotenv"
Dotenv.load("#{__dir__}/.env")

# TODO: Separate the file handling and S3 handling in two different classes
class FileHandler
  BUCKET = "oinp-updates-checker"
  PAGEBODY_FILENAME = "pagebody.txt".freeze
  LOGS_FILENAME = "run_logs.txt".freeze
  PAGEBODY_DEBUG_FILENAME = "debug_older_pagebody.txt".freeze
  USERS_FILENAME = "users.txt".freeze

  LOGS_LOCAL_PATH = "#{__dir__}/data/#{LOGS_FILENAME}".freeze
  USERS_LOCAL_PATH = "#{__dir__}/data/#{USERS_FILENAME}".freeze

  def initialize
    Aws.config.update(
      region: ENV["AWS_REGION"],
      credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
    )

    @bucket = Aws::S3::Resource.new.bucket(BUCKET)
  end

  def download_saved_pagebody
    object = @bucket.object(PAGEBODY_FILENAME)
    object.get(response_target: local_path(filename: PAGEBODY_FILENAME))
  end

  def save_pagebody_for_debugging
    object = @bucket.object(PAGEBODY_DEBUG_FILENAME)
    object.upload_file(local_path(filename: PAGEBODY_FILENAME))
  end

  def save_new_pagebody_local(pagebody)
    File.open(local_path(filename: PAGEBODY_FILENAME), "w:UTF-8") do |file|
      file.write(pagebody)
    end
  end

  def save_new_pagebody(pagebody)
    object = @bucket.object(PAGEBODY_FILENAME)
    File.open(local_path(filename: PAGEBODY_FILENAME), "w:UTF-8") do |file|
      file.write(pagebody)
    end
    object.upload_file(local_path(filename: PAGEBODY_FILENAME))
  end

  def write_to_run_logs(message)
    object = @bucket.object(LOGS_FILENAME)
    object.get(response_target: LOGS_LOCAL_PATH)

    File.open(LOGS_LOCAL_PATH, "a") do |file|
      file.write(message)
    end

    object.upload_file(LOGS_LOCAL_PATH)
  end
  
  def download_users
    object = @bucket.object(USERS_FILENAME)
    object.get(response_target: USERS_LOCAL_PATH)
  end

  def local_path(root: __dir__, filename:)
    "#{root}/data/#{filename}"
  end
end
