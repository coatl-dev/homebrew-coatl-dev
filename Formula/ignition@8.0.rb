class IgnitionAT80 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  url "https://files.inductiveautomation.com/release/ia/8.0.17/20201112-1050/Ignition-osx-8.0.17.zip",
      referer: "https://inductiveautomation.com/"
  sha256 "e873f8cc0a7f1f7d92379a212f71c15646712bede748c6444b47fe2a21e31447"
  license :cannot_represent

  livecheck do
    url "https://inductiveautomation.com/downloads/ignition/"
    strategy :page_match
    regex(/"version"\s*:\s*"(8.0(:?\.\d+)*)"/i)
  end

  deprecate! date: "2020-11-12", because: :unmaintained

  def install
    # Relocate data
    mv "data", "ignition8.0"
    etc.install "ignition8.0" unless (etc/"ignition8.0").exist?
    rm_rf "ignition8.0"

    # Relocate logs
    mv "logs", "ignition8.0"
    var.install "ignition8.0" unless (var/"ignition8.0").exist?
    rm_rf "ignition8.0"

    # Install
    libexec.install Dir["*"]

    # Make files executable
    %w[gwcmd.sh ignition.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", "#{libexec}/#{cmd}"
    end

    # Update com.inductiveautomation.ignition.plist
    inreplace "#{libexec}/com.inductiveautomation.ignition.plist" do |s|
      s.gsub! "/usr/local/bin/ignition", "/usr/local/bin/ignition8.0"
      s.gsub! "<string>com.inductiveautomation.ignition</string>", "<string>#{plist_name}</string>"
    end

    # Create symlinks
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition8.0"
    libexec.install_symlink "#{etc}/ignition8.0" => "data"
    libexec.install_symlink "#{var}/ignition8.0" => "logs"
    prefix.install_symlink "#{libexec}/com.inductiveautomation.ignition.plist" => "#{plist_name}.plist"
  end

  def post_install
    # Relocate files
    %w[License.html Notice.txt README.txt].each do |f|
      libexec.install "#{prefix}/#{f}" if File.exist?("#{prefix}/#{f}")
    end

    # Unzip the new runtime
    system "tar", "-C", "#{libexec}/lib/runtime", "-xf", "#{libexec}/lib/runtime/jre-mac.tar.gz"

    # Update ignition.conf
    system "#{libexec}/lib/runtime/jre-mac/bin/java",
           "-classpath",
           "#{libexec}/lib/core/common/common.jar",
           "com.inductiveautomation.ignition.common.upgrader.Upgrader",
           ".",
           "#{libexec}/data",
           "#{libexec}/logs",
           "file=ignition.conf"
  end

  def caveats
    s = <<~EOS
      The data and logs folders have been symlinked to:
        data: #{etc}/ignition8.0
        logs: #{var}/ignition8.0
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
    output = shell_output("#{bin}/ignition8.0 2>&1", 1)
    assert_match "#{bin}/ignition8.0", output
  end
end
