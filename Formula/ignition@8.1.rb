class IgnitionAT81 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  if OS.mac?
    os = "macOs"
    sha = "5294e5e01f3f0df790056c6a22fb096b02f37e24e3d0dde9301cbe11eeb66dc2"
  else
    os = "linux"
    sha = "73bfbfca2ed62cf5964cd4365e52445d118b231d6f8abcaecf6ac5ac6cc8b989"
  end
  url "https://files.inductiveautomation.com/release/ia/8.1.52/20260113-0940/Ignition-#{os}-x86-64-8.1.52.zip",
      referer: "https://inductiveautomation.com/"
  version "8.1.52"
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

    # Remove modules.json if data directory already existed
    modules_json = data_dir/"modules.json"
    rm modules_json if modules_json.exist?

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

  def plist_name
    "homebrew.mxcl.ignition@8.1"
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
