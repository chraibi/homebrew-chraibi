class Jpscore < Formula
  desc "Core simulation module for JuPedSim"
  homepage "https://www.jupedsim.org/"

  head "https://github.com/JuPedSim/jpscore.git"

  option "with-demos", "Add demo files"
  option "with-jpsfire", "use JPSfire"
  option "with-airouter", "use AIrouter (experimental)"
  option "with-tests", "add tests (unit tests, RiMEA, ...)"
  depends_on "cmake" => :build
  depends_on "boost"
  # timer chrono system filesystem unit_test_framework
  depends_on "zlib" if build.with? "jpsfire"
  depends_on "cgal" if build.with? "airouter"



  def install
    args = std_cmake_args + %W[
           -DCMAKE_BUILD_TYPE=Release
           -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=.
           -DCMAKE_PREFIX_PATH=$(pwd)/deps
    ]

    if build.with? "jpsfire"
      args <<  "-DJPSFIRE=true"
    end
    if build.with? "airouter"
      args << "-DAIROUTER=true"
    end
    if build.with? "tests"
      args << "-DBUILD_TESTING=ON"
      args << "-DBUILD_CPPUNIT_TEST=ON"
    end

    Dir.mkdir "build"
    Dir.chdir "build"
    system "../scripts/setup-deps.sh"
    system "cmake", "..", *args
    system "make"
    # todo fix this
    bin.install "../bin/jpscore"
    doc.install "../README.md", "../CHANGELOG.md", "../LICENSE"
    ohai "jpscore installed in #{bin}"
    if build.with? "demos"
      doc.install Dir["#{buildpath}/demos"]
      ohai "Additional demo files are installed in #{doc}"
    end

  end

  test do
    last_release="0.8.3"
    #assert_match version.to_s, shell_output("jpsreport -v 2>/dev/null")
    test_version=shell_output("../bin/jpsrcore 2>/dev/null | grep Version | awk -F: '{ print $2 }' |  tr -d '[[:space:]]'")
    ohai "checking version:"
    ohai "- expected: <#{last_release}>"
    ohai "- got: <#{test_version}>"
    assert_match last_release, test_version
  end

end
