class JythonAT271 < Formula
  desc "Python implementation written in Java (successor to JPython)"
  homepage "https://www.jython.org/"
  url "https://search.maven.org/remotecontent?filepath=org/python/jython-installer/2.7.1/jython-installer-2.7.1.jar"
  sha256 "6e58dad0b8565b95c6fb14b4bfbf570523d1c5290244cfb33822789fa53b1d25"
  license :cannot_represent

  # This isn't accidental; there is actually a compile process here.
  def install
    system "java", "-jar", cached_download, "-s", "-d", libexec
    bin.install_symlink libexec/"bin/jython"
  end

  test do
    jython = shell_output("#{bin}/jython -c \"from java.util import Date; print Date()\"")
    # This will break in the year 2100. The test will need updating then.
    assert_match jython.match(/20\d\d/).to_s, shell_output("/bin/date +%Y")
  end
end
