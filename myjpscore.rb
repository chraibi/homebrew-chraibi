class Myjpscore < Formula
  desc "Core simulation module for JuPedSim"
  homepage "https://www.jupedsim.org/"
  license "LGPL-3.0-or-later"
  head "https://github.com/JuPedSim/jpscore.git"

  option "with-demos", "Add demo files"
  # dependencies
  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "boost"
  depends_on "fmt"
  depends_on "spdlog"
  depends_on "cli11"

  def install
    args = std_cmake_args + %W[
           -DCMAKE_BUILD_TYPE=Release
           -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=.
           -GNinja
    ]

    Dir.mkdir "build"
    Dir.chdir "build"
  
    system "cmake", "..", *args
    system "ninja"
    # move executables to the bin directory of the formula
    bin.install "bin/jpscore"
    bin.install "bin/jpsreport"
    doc.install "../README.md", "../LICENSE"
    ohai "jpscore installed in #{bin}"
    if build.with? "demos"
      doc.install Dir["#{buildpath}/demos"]
      ohai "Additional demo files are installed in #{doc}"
    end

  end

  test do
    last_release="0.8.4"
    #assert_match version.to_s, shell_output("jpsreport -v 2>/dev/null")
    test_version=shell_output("../bin/jpsrcore 2>/dev/null | grep Version | awk -F: '{ print $2 }' |  tr -d '[[:space:]]'")
    ohai "checking version:"
    ohai "- expected: <#{last_release}>"
    ohai "- got: <#{test_version}>"
    assert_match last_release, test_version
  end

end
