class IgnitionEdgeAT816 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  url "https://files.inductiveautomation.com/release/ia/8.1.6/20210525-1228/Ignition-Edge-osx-8.1.6.zip",
      referer: "https://inductiveautomation.com/"
  sha256 "e9ec64d1d82ea2878c9b9ae936e04a1dd48fc9c139724ebb87b4872caa27960f"
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
