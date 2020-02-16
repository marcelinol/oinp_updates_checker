require "vcr"
require "dotenv"
VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!

  # Filter sensitive data
  env_vars = Dotenv.load("#{__dir__}/.env")
  env_vars.each do |key, value|
    c.filter_sensitive_data("<#{key}>") { value }
  end
end