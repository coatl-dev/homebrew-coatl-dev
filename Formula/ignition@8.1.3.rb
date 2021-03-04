class IgnitionAT813 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveautomation.com/"
  url "https://files.inductiveautomation.com/release/ia/8.1.3/20210303-0915/Ignition-osx-8.1.3.zip",
      referer: "https://inductiveautomation.com/"
  sha256 "e06fbdc70adbd14a72c1018392ed4fd676d06605c2e5cc7c7dda96739b6bc48d"
  license :cannot_represent

  bottle :unneeded

  def install
    libexec.install Dir["*"]
    # Make files executable
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
    output = shell_output("#{bin}/ignition-#{version} 2>&1", 1)
    assert_match "#{bin}/ignition-#{version}", output
  end
end
