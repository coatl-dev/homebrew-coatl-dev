class IgnitionAT83 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  if OS.mac?
    os = "macOs"
    arch = "aarch64-64"
    sha = "9859a4bd7aa7d619eb374639b4acb210794efcc31147e02c1b1adab3f3131b28"
  else
    os = "linux"
    arch = "x86-64"
    sha = "3e31f4da74c1f48f7d1ba5959e53bf33c68e49148b4acc9092fbbb71749feb5a"
  end
  url "https://files.inductiveautomation.com/release/ia/8.3.0-beta3/20250811-1327/Ignition-#{os}-#{arch}-8.3.0-beta3.zip",
      referer: "https://inductiveautomation.com/"
  version "8.3.0-beta3"
  sha256 sha.to_s
  license :cannot_represent

  livecheck do
    url "https://inductiveautomation.com/downloads/ignition/"
    strategy :page_match
    regex(/"version"\s*:\s*"(8.3.(?:\d+-(?:beta|rc)\d+\b)?)"/i)
  end

  def install
    # Relocate data
    (etc/"ignition/8.3").mkpath unless (etc/"ignition/8.3/data").exist?
    etc.install "data" => "ignition/8.3/data" unless (etc/"ignition/8.3/data").exist?
    rm_r "data"

    # Relocate logs
    (var/"ignition/8.3/logs").mkpath unless (var/"ignition/8.3/logs").exist?
    var.install "logs" => "ignition/8.3/logs" unless (var/"ignition/8.3/logs").exist?
    rm_r "logs"

    # Install
    libexec.install Dir["*"]

    # Make files executable
    %w[gwcmd.sh ignition.sh ignition-secrets-tool.sh ignition-util.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", "#{libexec}/#{cmd}"
    end

    # Create symlinks
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition"
    libexec.install_symlink "#{etc}/ignition/8.3/data" => "data"
    libexec.install_symlink "#{var}/ignition/8.3/logs" => "logs"
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
