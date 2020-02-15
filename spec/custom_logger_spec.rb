require "timecop"

RSpec.describe CustomLogger do

  let(:file_handler) { spy("file_handler") }
  let(:custom_logger) { CustomLogger.new(file_handler) }
  let(:current_time) { Time.now.utc.localtime("-05:00") }
  it "#log_start" do
    Timecop.freeze(current_time) do
      custom_logger.log_start
    end

    expect(file_handler)
      .to have_received(:write_to_run_logs)
      .with("[#{current_time}] Crawling started.\n")
  end

  describe "#log_end" do
    it "logs new updates when there is an update" do
      Timecop.freeze(current_time) do
        custom_logger.log_end(true)
      end

      expect(file_handler)
        .to have_received(:write_to_run_logs)
        .with("[#{current_time}] Finished. The OINP has a new update.\n\n")
    end

    it "logs no new updates when there is no updates" do
      Timecop.freeze(current_time) do
        custom_logger.log_end(false)
      end

      expect(file_handler)
        .to have_received(:write_to_run_logs)
        .with("[#{current_time}] Finished. The OINP has no new updates.\n\n")
    end
  end

  it "#log_error" do
    Timecop.freeze(current_time) do
      custom_logger.log_error("This is an error! OH MY GOD!")
    end

    "[#{current_time}] Crawler failed.\nError: This is an error! OH MY GOD!. \n\n"
  end
end
