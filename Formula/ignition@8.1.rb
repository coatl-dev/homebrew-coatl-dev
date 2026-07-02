class IgnitionAT81 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  if OS.mac?
    os = "macOs"
    sha = "03b4098966cb30b98d9dc0b21912af41d7858821928a326725700ea5ac882994"
  else
    os = "linux"
    sha = "b96513ae01cb0d43f38f054ec4f92b199c3bd945f5be2bf0814f524cbe788332"
  end
  url "https://files.inductiveautomation.com/release/ia/8.1.54/20260630-1137/Ignition-#{os}-x86-64-8.1.54.zip",
      referer: "https://inductiveautomation.com/"
  version "8.1.54"
  sha256 sha.to_s
  license :cannot_represent

  livecheck do
    url "https://inductiveautomation.com/downloads/ignition/"
    strategy :page_match
    regex(/"version"\s*:\s*"(8\.1\.\d+)"/i)
  end

  def install
    # Relocate data
    data_dir = etc/"ignition/8.1/data"
    # Create parent directory if needed
    data_dir.parent.mkpath

    if data_dir.exist?
      rm_r "data"
    else
      mv "data", data_dir
    end

    # Relocate logs
    logs_dir = var/"ignition/8.1/logs"
    logs_dir.mkpath

    if logs_dir.exist?
      rm_r "logs"
    else
      mv "logs", logs_dir
    end

    # Install everything else
    libexec.install Dir["*"]

    # Make files executable
    %w[gwcmd.sh ignition.sh ignition-util.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", libexec/cmd
    end

    # Create symlinks
    bin.install_symlink libexec/"ignition.sh" => "ignition"
    libexec.install_symlink data_dir => "data"
    libexec.install_symlink logs_dir => "logs"
  end

  def post_install
    # Relocate files
    %w[License.html Notice.txt README.txt].each do |f|
      source = prefix/f
      libexec.install source if source.exist?
    end

    # Unzip the new runtime
    system bin/"ignition", "checkruntimes"

    # Update ignition.conf
    system bin/"ignition", "runupgrader"
  end

  def caveats
    s = <<~EOS
      The data and logs folders have been symlinked to:
        data: #{etc}/ignition/8.1/data
        logs: #{var}/ignition/8.1/logs
    EOS
    s += find_other_installations
    s
  end

  def find_other_installations
    n = 0
    s = ""

    # Check for the typical location
    n += 1 if Dir.exist?("/usr/local/ignition")

    # Check for other Homebrew installations
    Dir["#{HOMEBREW_PREFIX}/Cellar/ignition*"].each do
      n += 1
    end

    if n > 1
      s = <<~EOS

        Other installations have been found which may interfere with a Homebrew-built
        Ignition Gateway from starting up correctly.
      EOS
    end
    s
  end

  test do
    output = shell_output("#{bin}/ignition")
    assert_match "#{libexec}/ignition.sh", output.lines.first
  end
end
