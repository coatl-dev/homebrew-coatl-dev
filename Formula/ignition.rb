class Ignition < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  if OS.mac?
    os = "macOs"
    sha = "35857d9da2ef8a3f10e6d2413603e46296f53706d13f6fd4ff2ac1fb0e863f72"
  else
    os = "linux"
    sha = "07c1cf453d70ea5e161d28ab80a8aafc90900a0fc1df4627104bbd3c1aba5b29"
  end
  url "https://files.inductiveautomation.com/release/ia/8.1.34/20231128-1740/Ignition-#{os}-x86-64-8.1.34.zip",
      referer: "https://inductiveautomation.com/"
  version "8.1.34"
  sha256 sha.to_s
  license :cannot_represent

  livecheck do
    url "https://inductiveautomation.com/downloads/ignition/"
    strategy :page_match
    regex(/"version"\s*:\s*"(\d+(:?\.\d+)*)"/i)
  end

  def install
    # Relocate data
    mv "data", "ignition"
    etc.install "ignition" unless (etc/"ignition").exist?
    rm_rf "ignition"

    # Relocate logs
    mv "logs", "ignition"
    var.install "ignition" unless (var/"ignition").exist?
    rm_rf "ignition"

    # Install
    libexec.install Dir["*"]

    # Make files executable
    %w[gwcmd.sh ignition.sh ignition-util.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", "#{libexec}/#{cmd}"
    end

    # Create symlinks
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition"
    libexec.install_symlink "#{etc}/ignition" => "data"
    libexec.install_symlink "#{var}/ignition" => "logs"

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
        data: #{etc}/ignition
        logs: #{var}/ignition
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
    Dir["#{HOMEBREW_PREFIX}/Cellar/ignition@**"].each do
      n += 1
    end
    if n == 1
      s = <<~EOS

        Another installation has been found which may interfere with a Homebrew-built
        Ignition Gateway from starting up correctly.
      EOS
    elsif n > 1
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
