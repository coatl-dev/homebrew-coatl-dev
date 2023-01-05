class IgnitionAT79 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  if OS.mac?
    os = "osx"
    sha = "1ebbb8f35e4811637166213490702912cead0f78e1356b4508bfc81ee2f1cb8c"
  else
    os = "linux-64"
    sha = "d6ff70b1dbda434d1ec8f3627664240de874b4a39586e9ab01762f9ed096774b"
  end
  url "https://files.inductiveautomation.com/release/ia/build7.9.21/20220726-1323/zip-installers/Ignition-#{os}-7.9.21.zip",
      referer: "https://inductiveautomation.com/"
  version "7.9.21"
  sha256 sha.to_s
  license :cannot_represent
  revision 2

  livecheck do
    url "https://inductiveautomation.com/downloads/ignition/"
    strategy :page_match
    regex(/"version"\s*:\s*"(7.9(:?\.\d+)*)"/i)
  end

  depends_on "openjdk@8"

  def install
    # Relocate data
    mv "data", "ignition7.9"
    etc.install "ignition7.9" unless (etc/"ignition7.9").exist?
    rm_rf "ignition7.9"

    # Relocate logs
    mv "logs", "ignition7.9"
    var.install "ignition7.9" unless (var/"ignition7.9").exist?
    rm_rf "ignition7.9"

    # Install
    libexec.install Dir["*"]

    # Make files executable
    %w[gcu.sh gwcmd.sh ignition.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", "#{libexec}/#{cmd}"
    end

    # Create symlinks
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition7.9"
    libexec.install_symlink "#{etc}/ignition7.9" => "data"
    libexec.install_symlink "#{var}/ignition7.9" => "logs"

    # Update com.inductiveautomation.ignition.plist only on macOS
    if OS.mac?
      inreplace "#{libexec}/com.inductiveautomation.ignition.plist" do |s|
        s.gsub! "<string>com.inductiveautomation.ignition</string>", "<string>#{plist_name}</string>"
        s.gsub! "<string>/usr/local/bin/ignition</string>", "<string>#{bin}/ignition7.9</string>"
      end
      prefix.install_symlink "#{libexec}/com.inductiveautomation.ignition.plist" => "#{plist_name}.plist"
    end
  end

  def post_install
    %w[Notice.txt README.txt].each do |f|
      libexec.install "#{prefix}/#{f}" if File.exist?("#{prefix}/#{f}")
    end

    # Modify data/ignition.conf
    java8_home = Language::Java.java_home("1.8")
    inreplace "#{libexec}/data/ignition.conf" do |s|
      s.gsub! "wrapper.java.command=java",
      "#wrapper.java.command=java"
      s.gsub! "#set.JAVA_HOME=/java/path",
      "set.JAVA_HOME=#{java8_home}"
      s.gsub! "#wrapper.java.command=%JAVA_HOME%/bin/java",
      "wrapper.java.command=%JAVA_HOME%/bin/java"
    end
  end

  def caveats
    s = <<~EOS
      The data and logs folders have been symlinked to:
        data: #{etc}/ignition7.9
        logs: #{var}/ignition7.9
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
    output = shell_output("#{bin}/ignition7.9 2>&1", 1)
    assert_match "#{bin}/ignition7.9", output
  end
end
