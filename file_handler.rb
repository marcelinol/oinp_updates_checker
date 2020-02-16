require "aws-sdk-s3"
require "dotenv"
Dotenv.load("#{__dir__}/.env")

# TODO: Separate the file handling and S3 handling in two different classes
class FileHandler
  BUCKET = "oinp-updates-checker".freeze
  PAGEBODY_FILENAME = "pagebody.txt".freeze
  LOGS_FILENAME = "run_logs.txt".freeze
  PAGEBODY_DEBUG_FILENAME = "debug_older_pagebody.txt".freeze
  USERS_FILENAME = "users.txt".freeze

  def initialize
    Aws.config.update(
      region: ENV["AWS_REGION"],
      credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
    )

    @bucket = Aws::S3::Resource.new.bucket(BUCKET)
  end

  ## PAGEBODY
  def download_saved_pagebody
    download_file(PAGEBODY_FILENAME)
  end

  def save_pagebody_for_debugging
    object = @bucket.object(PAGEBODY_DEBUG_FILENAME)
    object.upload_file(local_path(filename: PAGEBODY_FILENAME))
  end

  def save_pagebody_local(pagebody)
    File.open(local_path(filename: PAGEBODY_FILENAME), "w:UTF-8") do |file|
      file.write(pagebody)
    end
  end

  def save_new_pagebody(pagebody)
    save_pagebody_local(pagebody)

    upload_file(PAGEBODY_FILENAME)
  end

  ## LOGS
  def write_to_run_logs(message)
    download_logs

    write_to_run_logs_local(message)

    upload_file(LOGS_FILENAME)
  end

  def download_logs
    object = @bucket.object(LOGS_FILENAME)
    object.get(response_target: local_path(filename: LOGS_FILENAME))
  end

  def write_to_run_logs_local(message)
    File.open(local_path(filename: LOGS_FILENAME), "a") do |file|
      file.write(message)
    end
  end

  def upload_logs
    upload_file(LOGS_FILENAME)
  end

  ## USERS
  def download_users
    download_file(USERS_FILENAME)
  end


  ## GENERIC
  def upload_file(filename)
    object = @bucket.object(filename)
    object.upload_file(local_path(filename: filename))
  end

  def download_file(filename)
    object = @bucket.object(filename)
    object.get(response_target: local_path(filename: filename))
  end

  # TODO: Use root argument in tests to use fixtures to manipulate files
  def local_path(root: __dir__, filename:)
    "#{root}/data/#{filename}"
  end
end
