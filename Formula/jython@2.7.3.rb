class JythonAT273 < Formula
  desc "Python implementation written in Java (successor to JPython)"
  homepage "https://www.jython.org/"
  url "https://repo1.maven.org/maven2/org/python/jython-installer/2.7.3/jython-installer-2.7.3.jar"
  sha256 "3ffc25c5257d2028b176912a4091fe048c45c7d98218e52d7ce3160a62fdc9fc"
  license "PSF-2.0"

  depends_on "openjdk@17"

  def install
    system "java", "-jar", cached_download, "-s", "-t", "standard", "-d", libexec
    (bin/"jython").write_env_script libexec/"bin/jython", Language::Java.overridable_java_home_env
  end

  test do
    jython = shell_output("#{bin}/jython -c \"from java.util import Date; print Date()\"")
    # This will break in the year 2100. The test will need updating then.
    assert_match jython.match(/20\d\d/).to_s, shell_output("/bin/date +%Y")
  end
end
