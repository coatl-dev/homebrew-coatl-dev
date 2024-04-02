class JythonAT272 < Formula
  desc "Python implementation written in Java (successor to JPython)"
  homepage "https://www.jython.org/"
  url "https://search.maven.org/remotecontent?filepath=org/python/jython-installer/2.7.2/jython-installer-2.7.2.jar"
  sha256 "36e40609567ce020a1de0aaffe45e0b68571c278c14116f52e58cc652fb71552"
  license "PSF-2.0"

  def install
    system "java", "-jar", cached_download, "-s", "-t", "standard", "-d", libexec
    (bin/"jython").write_env_script libexec/"bin/jython", Language::Java.overridable_java_home_env
  end

  test do
    output = shell_output("#{bin}/jython -c \"from java.util import Calendar; print Calendar.getInstance().get(Calendar.YEAR)\"")
    assert_match output.to_s, shell_output("/bin/date +%Y")
  end
end
