class IgnitionAT7917 < Formula
  desc "Unlimited Platform for SCADA and so much more"
  homepage "https://inductiveatumation.com/"
  url "https://files.inductiveautomation.com/release/ia/build7.9.17/20210105-1428/zip-installers/Ignition-osx-7.9.17.zip",
      referer: "https://inductiveautomation.com/"
  sha256 "b6305e68a5ca8d1bbe500a8f39f4a769a95056852a9bfb86ee8aa099161664ae"
  license :cannot_represent

  depends_on "openjdk@8"

  def install
    libexec.install Dir["*"]
    # Make files executable
    %w[gcu.sh gwcmd.sh ignition.sh ignition-gateway].each do |cmd|
      chmod "u=wrx,go=rx", "#{libexec}/#{cmd}"
    end
    # Create symlink for ignition.sh
    bin.install_symlink "#{libexec}/ignition.sh" => "ignition-#{version}"
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
    # Update com.inductiveautomation.ignition.plist
    inreplace "#{libexec}/com.inductiveautomation.ignition.plist" do |s|
      s.gsub! "/usr/local/bin/ignition", "/usr/local/bin/ignition-#{version}"
    end
    # Link plist
    prefix.install_symlink "#{libexec}/com.inductiveautomation.ignition.plist" => "#{plist_name}.plist"
  end

  def post_install
    %w[Notice.txt README.txt].each do |f|
      libexec.install "#{prefix}/#{f}"
    end
  end

  test do
    assert_match "Ignition-Gateway", shell_output("#{bin}/ignition-#{version} status")
  end
end
