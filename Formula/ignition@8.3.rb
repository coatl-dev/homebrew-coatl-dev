class IgnitionAT83 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  if OS.mac?
    os = "macOs"
    arch = "aarch64-64"
    sha = "0424381f9f0f1d2ede6ea82bef88da67ba9067338a5178c2ae32f5aa8029e52d"
  else
    os = "linux"
    arch = "x86-64"
    sha = "42645c064dc5f102470159976445dd5c5273ca8e8f15db0bdd3a8b94dd854934"
  end
  url "https://releases.inductiveautomation.com/release/8.3.9/20260825-1153/Ignition-#{os}-#{arch}-8.3.9.zip",
      referer: "https://inductiveautomation.com/"
  version "8.3.9"
  sha256 sha.to_s
  license :cannot_represent

  livecheck do
    url "https://inductiveautomation.com/downloads/ignition/"
    strategy :page_match
    regex(/"version"\s*:\s*"(8.3.(:?\d+)*)"/i)
  end

  def install
    # Relocate data
    data_dir = etc/"ignition/8.3/data"
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
    logs_dir = var/"ignition/8.3/logs"
    logs_dir.mkpath

    if logs_dir.exist?
      rm_r "logs"
    else
      mv "logs", logs_dir
    end

    # Install everything else
    libexec.install Dir["*"]

    # Make files executable
    %w[gwcmd.sh ignition.sh ignition-secrets-tool.sh ignition-util.sh ignition-gateway].each do |cmd|
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
      libexec.install "#{prefix}/#{f}" if File.exist?("#{prefix}/#{f}")
    end

    # Unzip the new runtime
    system bin/"ignition", "checkruntimes"

    # Update ignition.conf
    system bin/"ignition", "runupgrader"
  end

  def caveats
    s = <<~EOS
      The data and logs folders have been symlinked to:
        data: #{etc}/ignition/8.3/data
        logs: #{var}/ignition/8.3/logs
    EOS
    s += find_other_installations
    s
  end

  def find_other_installations
    n = 0
    s = ""
    # Check for the typical location
    n +=1 if Dir.exist?("/usr/local/ignition")
    # Check for other Homebrew installations
    Dir["#{HOMEBREW_PREFIX}/Cellar/ignition**"].each do
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
