require_relative "../custom_logger.rb"
require_relative "../file_handler.rb"
require_relative "../vcr_setup"
require "webmock/rspec"

ENV["AWS_REGION"] = "us-east-1"
ENV["AWS_ACCESS_KEY_ID"] = "AKabcde"
ENV["AWS_SECRET_ACCESS_KEY"] = "abcde"
