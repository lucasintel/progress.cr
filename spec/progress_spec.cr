require "./spec_helper"

describe Progress do
  describe "#init" do
    it "renders an empty progress bar" do
      test_stream = File.tempfile(Random::Secure.hex)
      template = "{bar} {total} {step} {percent}"
      capacity = 10_485_760

      progress = Progress.new(
        stream: test_stream,
        total: capacity,
        template: template,
        width: 10,
      )

      progress.init

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\r[          ]  10.0 MiB   0.0 MiB    0%")
    end
  end

  describe "#reset" do
    it "resets the progress bar state" do
      test_stream = File.tempfile(Random::Secure.hex)
      template = "{bar} {total} {step} {percent}"
      capacity = 10_485_760

      progress = Progress.new(
        stream: test_stream,
        total: capacity,
        template: template,
        width: 10,
        step: capacity
      )

      progress.init

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\r[==========]  10.0 MiB  10.0 MiB  100%")

      progress.reset

      stream_content = File.read(test_stream.path)
      stream_content.should eq(
        "\r[==========]  10.0 MiB  10.0 MiB  100%\n" \
        "\r[          ]  10.0 MiB   0.0 MiB    0%"
      )
    end
  end

  describe "#tick" do
    it "ticks the progress bar" do
      test_stream = File.tempfile(Random::Secure.hex)
      template = "{bar} {total} {step} {percent}"
      capacity = 10_485_760

      progress = Progress.new(
        stream: test_stream,
        total: capacity,
        template: template,
        width: 10,
      )

      progress.tick((capacity/2))

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\r[=====     ]  10.0 MiB   5.0 MiB   50%")

      progress.tick((capacity/2))

      stream_content = File.read(test_stream.path)
      stream_content.should eq(
        "\r[=====     ]  10.0 MiB   5.0 MiB   50%" \
        "\r[==========]  10.0 MiB  10.0 MiB  100%"
      )
    end
  end

  describe "#set" do
    it "sets the progress bar step directly" do
      test_stream = File.tempfile(Random::Secure.hex)
      template = "{bar} {total} {step} {percent}"
      capacity = 10_485_760

      progress = Progress.new(
        stream: test_stream,
        total: capacity,
        template: template,
        width: 10,
        step: capacity / 2
      )

      progress.init

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\r[=====     ]  10.0 MiB   5.0 MiB   50%")

      progress.set(capacity * 0.1)

      stream_content = File.read(test_stream.path)
      stream_content.should eq(
        "\r[=====     ]  10.0 MiB   5.0 MiB   50%" \
        "\r[=         ]  10.0 MiB   1.0 MiB   10%"
      )
    end
  end

  describe "Number Formatting" do
    it "does nothing when @humanize_bytes is false" do
      test_stream = File.tempfile(Random::Secure.hex)
      template = "{bar} {total}/{step} packages installed"
      capacity = 5

      progress = Progress.new(
        stream: test_stream,
        total: capacity,
        template: template,
        label: "Test.mp4",
        width: 10,
        humanize_bytes: false,
      )

      progress.set(capacity)

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\r[==========] 5/5 packages installed")
    end

    it "formats MiB" do
      test_stream = File.tempfile(Random::Secure.hex)
      template = "{label} {bar} {total} {step} {percent} [{elapsed}]"
      capacity = 52_428_800

      progress = Progress.new(
        stream: test_stream,
        total: capacity,
        template: template,
        label: "Test.mp4",
        width: 10,
      )

      progress.set(capacity)

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\rTest.mp4 [==========]  50.0 MiB  50.0 MiB  100% [00:00]")
    end

    it "formats GiB" do
      test_stream = File.tempfile(Random::Secure.hex)
      template = "{label} {bar} {total} {step} {percent} [{elapsed}]"
      capacity = 1_610_612_736

      progress = Progress.new(
        stream: test_stream,
        total: capacity,
        template: template,
        label: "Test.mp4",
        width: 10,
      )

      progress.set(capacity)

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\rTest.mp4 [==========]   1.5 GiB   1.5 GiB  100% [00:00]")
    end

    it "formats KiB" do
      test_stream = File.tempfile(Random::Secure.hex)
      template = "{label} {bar} {total} {step} {percent} [{elapsed}]"
      capacity = 17_920

      progress = Progress.new(
        stream: test_stream,
        total: capacity,
        template: template,
        label: "Test.mp4",
        width: 10,
      )

      progress.set(capacity)

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\rTest.mp4 [==========]  17.5 KiB  17.5 KiB  100% [00:00]")
    end
  end

  describe "Customization" do
    it "allows the progress bar to be customized" do
      test_stream = File.tempfile(Random::Secure.hex)

      progress = Progress.new(
        stream: test_stream,
        width: 10,
        total: 100,
        step: 50,
        filled_char: "█",
        empty_char: "▒",
        label: "⌛ Processing...",
        template: "{bar} {label}",
      )

      progress.init

      stream_content = File.read(test_stream.path)
      stream_content.should eq("\r[█████▒▒▒▒▒] ⌛ Processing...")
    end
  end
end
