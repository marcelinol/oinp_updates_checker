RSpec.describe "FileHandler" do
  let(:file_handler) { FileHandler.new }
  describe "#download_saved_pagebody" do
    it "downloads the saved pagebody from AWS S3", :vcr do
      clean_file(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME))

      file_handler.download_saved_pagebody

      content = File.open(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME), "r:UTF-8", &:read)
      expect(content).to match(/February 13/)
    end
  end

  describe "#save_pagebody_remote" do
    it "uploads pagebody to AWS S3" do
      bucket = double("bucket")

      allow_any_instance_of(Aws::S3::Resource)
        .to receive(:bucket)
          .with(FileHandler::BUCKET)
          .and_return(bucket)

      object = spy("object")
      allow(bucket)
        .to receive(:object)
          .with(FileHandler::PAGEBODY_DEBUG_FILENAME)
          .and_return(object)

      file_handler.save_pagebody_remote(filename: FileHandler::PAGEBODY_DEBUG_FILENAME)

      expect(object)
        .to have_received(:upload_file)
          .with(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME))
          .once
    end
  end

  it "#save_pagebody_local" do
    clean_file(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME))

    file_handler.save_pagebody_local("xunda")

    content = File.open(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME), "r:UTF-8", &:read)
    expect(content).to match(/xunda/)
  end

  describe "#write_to_run_logs" do
    it "#download_logs" do
      bucket = double("bucket")

      allow_any_instance_of(Aws::S3::Resource)
        .to receive(:bucket)
          .with(FileHandler::BUCKET)
          .and_return(bucket)

      object = spy("object")
      allow(bucket)
        .to receive(:object)
          .with(FileHandler::LOGS_FILENAME)
          .and_return(object)

      file_handler.download_logs

      expect(object)
        .to have_received(:get)
          .with(response_target: file_handler.local_path(filename: FileHandler::LOGS_FILENAME))
          .once
    end

    it "#write_to_run_logs_local" do
      clean_file(file_handler.local_path(filename: FileHandler::LOGS_FILENAME))

      file_handler.write_to_run_logs_local("xunda")

      content = File.open(file_handler.local_path(filename: FileHandler::LOGS_FILENAME), "r:UTF-8", &:read)
      expect(content).to match(/xunda/)
    end
  end

  def clean_file(file_path)
    File.open(file_path, "w:UTF-8") do |file|
      file.write("")
    end
  end
end