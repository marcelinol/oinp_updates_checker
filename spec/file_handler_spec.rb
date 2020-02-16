RSpec.describe "FileHandler" do
  describe "#download_saved_pagebody" do
    it "downloads the saved pagebody from AWS S3", :vcr do
      clean_file(FileHandler::PAGEBODY_LOCAL_PATH)

      FileHandler.new.download_saved_pagebody

      content = File.open(FileHandler::PAGEBODY_LOCAL_PATH, "r:UTF-8", &:read)
      expect(content).to match(/February 13/)
    end

    def clean_file(file_path)
      File.open(file_path, "w:UTF-8") do |file|
        file.write("")
      end
    end
  end
end