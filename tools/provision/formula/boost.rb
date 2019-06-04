require File.expand_path("../Abstract/abstract-osquery-formula", __FILE__)

class Boost < AbstractOsqueryFormula
  desc "Collection of portable C++ source libraries"
  homepage "https://www.boost.org/"
  license "BSL-1.0"
  url "https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.bz2"
  sha256 "8f32d4617390d1c2d16f26a27ab60d97807b35440d45891fa340fc2648b04406"
  head "https://github.com/boostorg/boost.git"
  revision 100

  bottle do
    root_url "https://osql-packages.nyc3.digitaloceanspaces.com/bottles"
    cellar :any_skip_relocation
    sha256 "757c5df2129108e680c0f48a5fdc5f77ea5825361bc8815a022118b73a215b8a" => :sierra
    sha256 "84de1c93ae35791208a03c9c927b4a8dc7b1afb7d2390137c01e005173b59dfc" => :x86_64_linux
  end

  depends_on "bzip2" unless OS.mac?

  def install
    ENV.cxx11
    ENV.universal_binary if build.universal?

    # libdir should be set by --prefix but isn't
    bootstrap_args = [
      "--prefix=#{prefix}",
      "--libdir=#{lib}",
      "--with-toolset=cc",
    ]

    # layout should be synchronized with boost-python
    args = [
      "--prefix=#{prefix}",
      "--libdir=#{lib}",
      "-d2",
      "-j#{ENV.make_jobs}",
      "--layout=tagged",
      "--ignore-site-config",
      "--disable-icu",
      "threading=multi",
      "link=static",
      "optimization=space",
      "variant=release",
      "toolset=clang",
    ]

    args << "cxxflags=-std=c++11 #{ENV["CXXFLAGS"]}"

    # Fix error: bzlib.h: No such file or directory
    # and /usr/bin/ld: cannot find -lbz2
    args += [
      "include=#{HOMEBREW_PREFIX}/include",
      "linkflags=#{ENV["LDFLAGS"]}"
    ] unless OS.mac?

    system "./bootstrap.sh", *bootstrap_args

    # The B2 script will not read our user-config.
    # You will encounter: ERROR: rule "cc.init" unknown in module "toolset".
    # If the lines from project-config are moved into a --user-config b2 will
    # complain about duplicate initializations:
    #  error: duplicate initialization of clang-linux
    if OS.mac?
      inreplace "project-config.jam", "cc ;", "darwin ;"
    else
      inreplace "project-config.jam", "cc ;", "clang ;"
    end

    system "./b2", "install", *args
  end
end
