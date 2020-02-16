RSpec.describe "FileHandler" do
  describe "#download_saved_pagebody" do
    it "downloads the saved pagebody from AWS S3" do
      bucket = double("bucket")

      allow_any_instance_of(Aws::S3::Resource)
        .to receive(:bucket)
        .with(FileHandler::BUCKET)
        .and_return(bucket)

      object = spy("object")
      allow(bucket)
        .to receive(:object)
        .with(FileHandler::PAGEBODY_FILENAME)
        .and_return(object)

      FileHandler.new.download_saved_pagebody

      expect(object)
        .to have_received(:get)
        .with(response_target: FileHandler::PAGEBODY_LOCAL_PATH)
        .once
    end
  end
end