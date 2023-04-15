class OpenconnectX5 < Formula
  desc "Open client for Cisco AnyConnect VPN"
  homepage "https://www.infradead.org/openconnect/"
  url "https://gitlab.com/L11R/openconnect/-/archive/v9.02/openconnect-v9.02.tar.gz"
  sha256 "4c02b07b06531ad48fddd1067e4ebc1358ae9978a24fd73ab09637c399e79cb5"
  license "LGPL-2.1-only"
  revision 2

  bottle do
    sha256 arm64_ventura: "4ea75910149826533dfac5d5609cb813dc2e9d953380d2d3c4cb0aaa69f74f07"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gnutls"
  depends_on "stoken"

  resource "vpnc-script" do
    url "https://gitlab.com/openconnect/vpnc-scripts/raw/e52f8e66391c4c55ee818841d236ebbb6ae284ed/vpnc-script"
    sha256 "6d95e3625cceb51e77628196055adb58c3e8325b9f66fcc8e97269caf42b8575"
  end

  def install
    (etc/"vpnc").install resource("vpnc-script")
    chmod 0755, etc/"vpnc/vpnc-script"

    ENV["LIBTOOLIZE"] = "glibtoolize"
    system "./autogen.sh"

    args = %W[
      --prefix=#{prefix}
      --sbindir=#{bin}
      --localstatedir=#{var}
      --with-vpnc-script=#{etc}/vpnc/vpnc-script
    ]

    system "./configure", *args
    system "make", "install"
  end

  def caveats
    s = <<~EOS
      A `vpnc-script` has been installed at #{etc}/vpnc/vpnc-script.
    EOS

    s += if (etc/"vpnc/vpnc-script.default").exist?
      <<~EOS
        To avoid destroying any local changes you have made, a newer version of this script has
        been installed as `vpnc-script.default`.
      EOS
    end.to_s

    s
  end

  test do
    # We need to pipe an empty string to `openconnect` for this test to work.
    assert_match "POST https://localhost/", pipe_output("#{bin}/openconnect localhost 2>&1", "")
  end
end
