class IgnitionAT81 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  if OS.mac?
    os = "macOs"
    sha = "890f78be27ba87ad7f5c345084b47c2b4c50f1fb25bdd9cefe3669362a8f09f9"
  else
    os = "linux"
    sha = "79524eef03fb18c1b79c23112f05544be94a80dad957ac3f65a3979117b11f2f"
  end
  url "https://files.inductiveautomation.com/release/ia/8.1.51/20251216-0811/Ignition-#{os}-x86-64-8.1.51.zip",
      referer: "https://inductiveautomation.com/"
  version "8.1.51"
  sha256 sha.to_s
  license :cannot_represent

  livecheck do
    url "https://inductiveautomation.com/downloads/ignition/"
    strategy :page_match
    regex(/"version"\s*:\s*"(8.1.(:?\d+)*)"/i)
  end

  def install
    # Relocate data
    (etc/"ignition/8.1").mkpath unless (etc/"ignition/8.1/data").exist?
    etc.install "data" => "ignition/8.1/data" unless (etc/"ignition/8.1/data").exist?
    rm_r "data"

    # Relocate logs
    (var/"ignition/8.1/logs").mkpath unless (var/"ignition/8.1/logs").exist?
    var.install "logs" => "ignition/8.1/logs" unless (var/"ignition/8.1/logs").exist?
    rm_r "logs"

    # Install
    libexec.install Dir["*"]

    # Make files executable
    %w[gwcmd.sh ignition.sh ignition-util.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", "#{libexec}/#{cmd}"
    end

    # Create symlinks
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition"
    libexec.install_symlink "#{etc}/ignition/8.1/data" => "data"
    libexec.install_symlink "#{var}/ignition/8.1/logs" => "logs"

    # Update com.inductiveautomation.ignition.plist only on macOS
    if OS.mac?
      inreplace "#{libexec}/com.inductiveautomation.ignition.plist" do |s|
        s.gsub! "<string>com.inductiveautomation.ignition</string>", "<string>#{plist_name}</string>"
        s.gsub! "<string>/usr/local/bin/ignition</string>", "<string>#{bin}/ignition</string>"
      end
      prefix.install_symlink "#{libexec}/com.inductiveautomation.ignition.plist" => "#{plist_name}.plist"
    end
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
