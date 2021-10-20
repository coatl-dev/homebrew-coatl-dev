class Ignition < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  url "https://files.inductiveautomation.com/release/ia/8.1.11/20211019-1212/Ignition-osx-8.1.11.zip",
      referer: "https://inductiveautomation.com/"
  sha256 "b7682c03dedc7b079a98ee6253498f2041e2811cc3da2d6267fd9b4a265f276c"
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

    # Update com.inductiveautomation.ignition.plist
    inreplace "#{libexec}/com.inductiveautomation.ignition.plist" do |s|
      s.gsub! "<string>com.inductiveautomation.ignition</string>", "<string>#{plist_name}</string>"
    end

    # Create symlinks
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition"
    libexec.install_symlink "#{etc}/ignition" => "data"
    libexec.install_symlink "#{var}/ignition" => "logs"
    prefix.install_symlink "#{libexec}/com.inductiveautomation.ignition.plist" => "#{plist_name}.plist"
  end

  def post_install
    # Relocate files
    %w[License.html Notice.txt README.txt].each do |f|
      libexec.install "#{prefix}/#{f}"
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
