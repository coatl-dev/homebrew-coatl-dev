class IgnitionAT79 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  url "https://files.inductiveautomation.com/release/ia/build7.9.20/20220512-1016/zip-installers/Ignition-osx-7.9.20.zip",
      referer: "https://inductiveautomation.com/"
  sha256 "82de40532d8bb659be49fd4e54d5c254bcb503e87a6eb35931744a6099e6a333"
  license :cannot_represent

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

    # Update com.inductiveautomation.ignition.plist
    inreplace "#{libexec}/com.inductiveautomation.ignition.plist" do |s|
      s.gsub! "/usr/local/bin/ignition", "/usr/local/bin/ignition7.9"
      s.gsub! "<string>com.inductiveautomation.ignition</string>", "<string>#{plist_name}</string>"
    end

    # Create symlinks
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition7.9"
    libexec.install_symlink "#{etc}/ignition7.9" => "data"
    libexec.install_symlink "#{var}/ignition7.9" => "logs"
    prefix.install_symlink "#{libexec}/com.inductiveautomation.ignition.plist" => "#{plist_name}.plist"
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
