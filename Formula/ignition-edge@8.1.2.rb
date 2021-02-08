class IgnitionEdgeAT812 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  url "https://files.inductiveautomation.com/release/ia/8.1.2/20210203-1115/Ignition-Edge-osx-8.1.2.zip",
      referer: "https://inductiveautomation.com/"
  sha256 "92805d37ad136002aaac64527acbbb26703f39451270307d760389d2a082fb3f"
  license :cannot_represent

  bottle :unneeded

  def install
    libexec.install Dir["*"]
    # Make files executable
    %w[gwcmd.sh ignition.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", "#{libexec}/#{cmd}"
    end
    # Create symlink for ignition.sh
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition-edge-#{version}"
    # Update com.inductiveautomation.ignition.plist
    inreplace "#{libexec}/com.inductiveautomation.ignition.plist" do |s|
      s.gsub! "/usr/local/bin/ignition", "/usr/local/bin/ignition-edge-#{version}"
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
    output = shell_output("#{bin}/ignition-edge-#{version} 2>&1", 1)
    assert_match "#{bin}/ignition-edge-#{version}", output
  end
end