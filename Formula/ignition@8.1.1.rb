class IgnitionAT811 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveatumation.com/"
  url "https://files.inductiveautomation.com/release/ia/8.1.1/20201208-0843/Ignition-osx-8.1.1.zip", using: :curl, referer: "https://inductiveautomation.com/"
  sha256 "a332a9ff9705bba3e2254976378be4835de7ed85a3ff448d70111585b61419ea"
  license :cannot_represent

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
    assert_match "Ignition-Gateway", shell_output("#{bin}/ignition-#{version} status")
  end
end
