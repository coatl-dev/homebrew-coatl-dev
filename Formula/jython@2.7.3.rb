class JythonAT273 < Formula
  desc "Python implementation written in Java (successor to JPython)"
  homepage "https://www.jython.org/"
  url "https://search.maven.org/remotecontent?filepath=org/python/jython-installer/2.7.3/jython-installer-2.7.3.jar"
  sha256 "3ffc25c5257d2028b176912a4091fe048c45c7d98218e52d7ce3160a62fdc9fc"
  license "PSF-2.0"

  def install
    system "java", "-jar", cached_download, "-s", "-t", "standard", "-d", libexec
    (bin/"jython").write_env_script libexec/"bin/jython", Language::Java.overridable_java_home_env
  end

  test do
    (testpath/"test.py").write <<~EOF
      from java.util import Calendar

      print Calendar.getInstance().get(Calendar.YEAR)

    EOF
    output = shell_output("#{bin}/jython #{testpath}/test.py 2>&1")
    assert_match output.to_s, shell_output("/bin/date +%Y")
  end
end
