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

  describe "#save_pagebody_for_debugging" do
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

      file_handler.save_pagebody_for_debugging

      expect(object)
        .to have_received(:upload_file)
          .with(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME))
          .once
    end
  end

  it "#save_new_pagebody_local" do
    clean_file(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME))

    file_handler.save_new_pagebody_local("xunda")

    content = File.open(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME), "r:UTF-8", &:read)
    expect(content).to match(/xunda/)
  end

  def clean_file(file_path)
    File.open(file_path, "w:UTF-8") do |file|
      file.write("")
    end
  end
end