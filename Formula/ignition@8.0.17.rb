class IgnitionAT8017 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveatumation.com/"
  url "https://files.inductiveautomation.com/release/ia/8.0.17/20201112-1050/Ignition-osx-8.0.17.zip",
      referer: "https://inductiveautomation.com/"
  sha256 "e873f8cc0a7f1f7d92379a212f71c15646712bede748c6444b47fe2a21e31447"
  license :cannot_represent

  def install
    libexec.install Dir["*"]
    # Make files executable and add symlinks
    %w[gwcmd.sh ignition.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", "#{libexec}/#{cmd}"
    end
    # Create symlink for ignition.sh
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition-#{version}"
    # Update com.inductiveautomation.ignition.plist
    inreplace "#{libexec}/com.inductiveautomation.ignition.plist" do |s|
      s.gsub! "/usr/local/bin/ignition", "/usr/local/bin/ignition-#{version}"
    end
    # Link plist
    prefix.install_symlink "#{libexec}/com.inductiveautomation.ignition.plist" => "#{plist_name}.plist"
  end

  def post_install
    %w[License.html Notice.txt README.txt].each do |f|
      libexec.install "#{prefix}/#{f}"
    end
  end

  test do
    assert_match "Ignition-Gateway", shell_output("#{bin}/ignition-#{version} status")
  end
end
