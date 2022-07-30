{ stdenv
, lib
, fetchFromGitHub
, bison
, cmake
, diffutils
, fmt_8
, gnutar
, pkg-config
, ronn
, boost
, bzip2
, double-conversion
, fuse
, glog
, gtest
, jemalloc
, libaio
, libarchive
, libelf
, libevent
, libiberty
, libsodium
, libunwind
, lz4
, lzma
, openssl
, snappy
, xxHash
, zlib
, zstd
}:

stdenv.mkDerivation rec {
  pname = "dwarfs";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "mhx";
    repo = "dwarfs";
    rev = "v${version}";
    hash = "sha256-bGJkgcq8JxueRTX08QpJv1A0O5wXbiIgUY7BrY0Ln/M=";
    fetchSubmodules = true;
  };

  buildInputs = [
    boost
    bzip2
    double-conversion
    fuse
    glog
    gtest
    libarchive
    libelf
    libevent
    libiberty
    libsodium
    libunwind
    lz4
    lzma
    openssl
    snappy
    xxHash
    zlib
    zstd
  ] ++ lib.optionals stdenv.isLinux [
    jemalloc
    libaio
  ];

  nativeBuildInputs = [
    bison
    cmake
    fmt_8
    pkg-config
    ronn
  ];

  nativeCheckInputs = [
    diffutils
    gnutar
  ];

  cmakeFlags = [
    "-DWITH_TESTS=ON"
    "-DPREFER_SYSTEM_GTEST=ON"
    "-DPREFER_SYSTEM_ZSTD=ON"
    "-DPREFER_SYSTEM_XXHASH=ON"
  ] ++ lib.optionals (!stdenv.isLinux) [
    "-DUSE_JEMALLOC=OFF"
  ];

  postPatch = ''
    substituteInPlace cmake/version.cmake \
      --replace 'git log --pretty=format:%h -n 1' 'echo nix:v${version}' \
      --replace 'git describe --tags --match "v*" --dirty' 'echo v${version}' \
      --replace 'git rev-parse --abbrev-ref HEAD' 'echo main'
  '';

  NIX_CFLAGS_COMPILE = lib.optionals stdenv.isDarwin [
    "-DTARGET_OS_SIMULATOR=0"
    "-DTARGET_OS_IPHONE=0"
    "-DTARGET_IPHONE_SIMULATOR=0"
  ];

  meta = {
    broken = stdenv.isDarwin;
  };
}
