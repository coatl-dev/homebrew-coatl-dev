class IgnitionAT81 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  os, sha = if OS.mac?
    ["macOs", "a079ae7cbc81551a0a5dca99aaf92e6c7e9d006ef9e0f33cc7dbf3922e589807"]
  else
    ["linux", "bda8e213fecf1cdd1392fd7fe28c173df29da6b2d4f5e42db3e48074238a6244"]
  end
  url "https://releases.inductiveautomation.com/release/8.1.56/20261125-1142/Ignition-#{os}-x86-64-8.1.56.zip",
      referer: "https://inductiveautomation.com/"
  version "8.1.56"
  sha256 sha
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

  post_install_steps do
    # Relocate files
    if_path_exists "License.html", base: :prefix do
      move "License.html", "libexec/License.html"
    end
    if_path_exists "Notice.txt", base: :prefix do
      move "Notice.txt", "libexec/Notice.txt"
    end
    if_path_exists "README.txt", base: :prefix do
      move "README.txt", "libexec/README.txt"
    end

    # Unzip the new runtime
    run "ignition", args: ["checkruntimes"], base: :bin

    # Update ignition.conf
    run "ignition", args: ["runupgrader"], base: :bin
  end

  def caveats
    s = <<~EOS
      The data and logs folders have been symlinked to:
        data: #{etc}/ignition/8.1/data
        logs: #{var}/ignition/8.1/logs
    EOS

    n = 0
    # Check for the typical location
    n += 1 if Dir.exist?("/usr/local/ignition")
    # Check for other Homebrew installations
    n += Dir["#{HOMEBREW_PREFIX}/Cellar/ignition**"].size

    s += <<~EOS if n > 1

      Other installations have been found which may interfere with a Homebrew-built
      Ignition Gateway from starting up correctly.
    EOS
    s
  end

  test do
    output = shell_output("#{bin}/ignition")
    assert_match "#{libexec}/ignition.sh", output.lines.first
  end
end
