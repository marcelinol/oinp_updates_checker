RSpec.describe "Crawler" do
  let(:file_handler) { FileHandler.new }
  let(:mailer) { OinpMailer.new }
  # let(:custom_logger) { CustomLogger.new(file_handler) }
  # let(:crawler) { Crawler.new(file_handler, custom_logger) }

  describe "#run" do
    describe "error handling" do
      it "logs errors" do
        custom_logger = spy("custom_logger")
        allow(custom_logger).to receive(:log_start).and_raise(StandardError)
        crawler = Crawler.new(file_handler, custom_logger, mailer)

        crawler.run

        expect(custom_logger).to have_received(:log_error).with(StandardError)
      end

      it "logs start of the process" do
        custom_logger = spy("custom_logger")
        # Stop execution to avoid having to mock everything
        # TODO: Find a better way to  avoid mocking everything (probably this will get solved after refactoring the class)
        allow(custom_logger).to receive(:log_start).and_raise(StandardError)
        crawler = Crawler.new(file_handler, custom_logger, mailer)

        crawler.run

        expect(custom_logger).to have_received(:log_start).once
      end

      context "compares local pagebody with pagebody read from  OINP updates page" do
        it "does not send email when there are no changes" do
          custom_logger = FakeCustomLogger.new
          mailer = spy("mailer")
          crawler = Crawler.new(file_handler, custom_logger, mailer)

          allow(crawler).to receive(:read_page_body).and_return("xunda")
          allow(file_handler).to receive(:download_saved_pagebody)
          allow(File)
            .to receive(:open)
            .with(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME), "r:UTF-8")
            .and_return("xunda")


          crawler.run

          expect(mailer).not_to have_received(:send_email_about_oinp_updates)
        end

        it "sends email when there are changes" do
          custom_logger = FakeCustomLogger.new
          mailer = spy("mailer")
          crawler = Crawler.new(file_handler, custom_logger, mailer)

          allow(crawler).to receive(:read_page_body).and_return("dunha xunda")
          allow(file_handler).to receive(:download_saved_pagebody)
          allow(file_handler).to receive(:save_pagebody_for_debugging)
          allow(file_handler).to receive(:save_new_pagebody).with("dunha xunda")
          allow(File)
            .to receive(:open)
              .with(file_handler.local_path(filename: FileHandler::PAGEBODY_FILENAME), "r:UTF-8")
              .and_return("dunha")
          allow(mailer).to receive(:send_email_about_oinp_updates)


          crawler.run

          expect(mailer).to have_received(:send_email_about_oinp_updates)
        end
      end
    end
  end
end

# class FakeFileHandler
#   def initialize; end
#
#   def download_saved_pagebody; end
#
#   def local_path(filename:)
#     "fake"
#   end
# end
#
class FakeCustomLogger
  def initialize; end

  def log_start; end

  def log_error(e)
    puts e
  end
end