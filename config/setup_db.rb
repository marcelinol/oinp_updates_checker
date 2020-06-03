require "sequel"
require "dotenv"
Dotenv.load("#{__dir__}/../.env")

DB = Sequel.connect(
  adapter: :postgres,
  user: ENV["RDS_USERNAME"],
  password: ENV["RDS_PASSWORD"],
  host: ENV["RDS_HOST"],
  port: ENV["RDS_PORT"],
  database: "postgres",
  max_connections: 10,
)

unless DB.table_exists?(:readings)
  DB.create_table :readings do
    primary_key :id
    String :content
    Integer :timestamp
  end
end