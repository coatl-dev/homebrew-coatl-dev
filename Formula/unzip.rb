class Unzip < Formula
  desc "Extraction utility for .zip compressed archives"
  homepage "https://infozip.sourceforge.io/UnZip.html"
  url "https://downloads.sourceforge.net/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz"
  version "6.0"
  sha256 "036d96991646d0449ed0aa952e4fbe21b476ce994abc276e49d30e686708bd37"
  revision 4

  bottle do
    cellar :any_skip_relocation
    sha256 "06aeb3114e2a030970f0d05424e9f2b2f845a2a5643065f173ba6a70e99970a3" => :mojave
    sha256 "0e76c4b9f38e8de22409e666894400b95340271144e44bd408975a8d0100b942" => :high_sierra
    sha256 "5445d1be98f82d7d4d4a01f930790d0745c845cdbf1a7ea23d07f7fc295d6f90" => :sierra
  end

  keg_only :provided_by_macos

  # Upstream is unmaintained so we use the Debian patchset:
  # https://packages.debian.org/sid/unzip
  patch do
    url "https://deb.debian.org/debian/pool/main/u/unzip/unzip_6.0-22.debian.tar.xz"
    sha256 "f3c80c1e3917d59cb2fe72f0431159c919f2df7fc96f5b539c91cc96fc02ecfa"
    apply %w[
      patches/01-manpages-in-section-1-not-in-section-1l.patch
      patches/02-this-is-debian-unzip.patch
      patches/03-include-unistd-for-kfreebsd.patch
      patches/04-handle-pkware-verification-bit.patch
      patches/05-fix-uid-gid-handling.patch
      patches/06-initialize-the-symlink-flag.patch
      patches/07-increase-size-of-cfactorstr.patch
      patches/08-allow-greater-hostver-values.patch
      patches/09-cve-2014-8139-crc-overflow.patch
      patches/10-cve-2014-8140-test-compr-eb.patch
      patches/11-cve-2014-8141-getzip64data.patch
      patches/12-cve-2014-9636-test-compr-eb.patch
      patches/13-remove-build-date.patch
      patches/14-cve-2015-7696.patch
      patches/15-cve-2015-7697.patch
      patches/16-fix-integer-underflow-csiz-decrypted.patch
      patches/17-restore-unix-timestamps-accurately.patch
      patches/18-cve-2014-9913-unzip-buffer-overflow.patch
      patches/19-cve-2016-9844-zipinfo-buffer-overflow.patch
      patches/20-cve-2018-1000035-unzip-buffer-overflow.patch
    ]
  end

  def install
    system "make", "-f", "unix/Makefile",
      "CC=#{ENV.cc}",
      "LOC=-DLARGE_FILE_SUPPORT",
      "D_USE_BZ2=-DUSE_BZIP2",
      "L_BZ2=-lbz2",
      "macosx",
      "LFLAGS1=-liconv"
    system "make", "prefix=#{prefix}", "MANDIR=#{man1}", "install"
  end

  test do
    (testpath/"test1").write "Hello!"
    (testpath/"test2").write "Bonjour!"
    (testpath/"test3").write "Hej!"

    system "/usr/bin/zip", "test.zip", "test1", "test2", "test3"
    %w[test1 test2 test3].each do |f|
      rm f
      refute_predicate testpath/f, :exist?, "Text files should have been removed!"
    end

    system bin/"unzip", "test.zip"
    %w[test1 test2 test3].each do |f|
      assert_predicate testpath/f, :exist?, "Failure unzipping test.zip!"
    end

    assert_match "Hello!", File.read(testpath/"test1")
    assert_match "Bonjour!", File.read(testpath/"test2")
    assert_match "Hej!", File.read(testpath/"test3")
  end
end
