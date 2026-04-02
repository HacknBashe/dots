{
  lib,
  stdenv,
  fetchgit,
  fetchurl,
  cmake,
  onnxruntime,
  callPackage,
}:
let
  moonshine-model = callPackage ./model.nix {};

  # This file is stored in Git LFS (~104MB) and not fetched by sparse checkout.
  # It embeds the speaker-embedding ONNX model as a C++ byte array.
  speaker-embedding-data = fetchurl {
    url = "https://media.githubusercontent.com/media/moonshine-ai/moonshine/33d389f8f66a571afd259d6511e59c737346fdab/core/speaker-embedding-model-data.cpp";
    hash = "sha256-WALJHPTotB3TRivLpxQcIdaKw4bqwMctO6bZe3ijykE=";
  };
in
stdenv.mkDerivation rec {
  pname = "moonshine-voice";
  version = "0.0.51";

  # Use sparse checkout to avoid downloading ~1.7GB of vendored binaries.
  # We only need the core/ C++ source and headers.
  src = fetchgit {
    url = "https://github.com/moonshine-ai/moonshine.git";
    rev = "33d389f8f66a571afd259d6511e59c737346fdab";
    sparseCheckout = [
      "core"
    ];
    hash = "sha256-HY4NHxeXl7pl1tWPo6/FTToYpQ919O2nwPecUBSTIg0=";
  };

  sourceRoot = "${src.name}/core";

  nativeBuildInputs = [cmake];
  buildInputs = [onnxruntime];

  # Copy our CLI wrapper into the source tree before building
  prePatch = ''
    cp ${./moonshine-cli.cpp} moonshine-cli.cpp
  '';

  # Patch the cmake to use system onnxruntime instead of vendored binaries,
  # and add our CLI target to the build
  postPatch = ''
    # The speaker-embedding-model-data.cpp is stored in Git LFS (~104MB) and
    # not fetched by sparse checkout. Replace the LFS pointer with the real file.
    cp ${speaker-embedding-data} speaker-embedding-model-data.cpp
    # Replace the vendored onnxruntime path resolution with system paths
    mkdir -p third-party/onnxruntime
    cat > third-party/onnxruntime/find-ort-library-path.cmake <<'EOF'
    # Use system onnxruntime from Nix
    find_library(ONNXRUNTIME_LIB_PATH onnxruntime REQUIRED)
    function(copy_onnxruntime_dll target_name)
    endfunction()
    EOF

    # Point the include path at system onnxruntime headers
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        "''${CMAKE_CURRENT_LIST_DIR}/third-party/onnxruntime/include" \
        "${lib.getDev onnxruntime}/include"

    # Add our CLI executable to the cmake build
    cat >> CMakeLists.txt <<'EOF'

    # moonshine-cli: command-line transcription tool
    add_executable(moonshine-cli moonshine-cli.cpp)
    set_target_properties(moonshine-cli PROPERTIES
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED YES
        CXX_EXTENSIONS NO
    )
    target_include_directories(moonshine-cli PRIVATE
        ''${CMAKE_CURRENT_LIST_DIR}
        ''${CMAKE_CURRENT_LIST_DIR}/moonshine-utils
    )
    target_compile_definitions(moonshine-cli PRIVATE
        DEFAULT_MODEL_PATH="${moonshine-model}"
    )
    target_link_libraries(moonshine-cli PRIVATE moonshine)
    install(TARGETS moonshine-cli DESTINATION bin)
    EOF

    # Fix the ort-utils include to use system headers
    if [ -f ort-utils/CMakeLists.txt ]; then
      substituteInPlace ort-utils/CMakeLists.txt \
        --replace-fail \
          "''${CMAKE_CURRENT_LIST_DIR}/../third-party/onnxruntime/include" \
          "${lib.getDev onnxruntime}/include" \
        || true
    fi
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-result";

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
    "-DCMAKE_INSTALL_RPATH=${lib.makeLibraryPath [onnxruntime stdenv.cc.cc.lib]}:${placeholder "out"}/lib"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib $out/include
    cp moonshine-cli $out/bin/
    if [ -f libmoonshine${stdenv.hostPlatform.extensions.sharedLibrary} ]; then
      cp libmoonshine${stdenv.hostPlatform.extensions.sharedLibrary}* $out/lib/
    fi
    cp $src/core/moonshine-c-api.h $out/include/
    cp $src/core/moonshine-cpp.h $out/include/
    runHook postInstall
  '';

  # Set rpath so the binary can find libmoonshine and libonnxruntime
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --force-rpath --set-rpath "${lib.makeLibraryPath [onnxruntime stdenv.cc.cc.lib]}:$out/lib" $out/bin/moonshine-cli
    patchelf --force-rpath --set-rpath "${lib.makeLibraryPath [onnxruntime stdenv.cc.cc.lib]}" $out/lib/libmoonshine.so
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Fix moonshine-cli: rewrite @rpath references to absolute paths
    install_name_tool -change @rpath/libmoonshine.dylib $out/lib/libmoonshine.dylib $out/bin/moonshine-cli
    # Fix the versioned onnxruntime dylib reference
    for dep in $(otool -L $out/bin/moonshine-cli | grep -o '@rpath/libonnxruntime[^ ]*'); do
      install_name_tool -change "$dep" ${onnxruntime}/lib/libonnxruntime.dylib $out/bin/moonshine-cli
    done
    # Fix libmoonshine.dylib install name
    install_name_tool -id $out/lib/libmoonshine.dylib $out/lib/libmoonshine.dylib
  '';

  meta = with lib; {
    description = "Fast and accurate automatic speech recognition for edge devices";
    homepage = "https://github.com/moonshine-ai/moonshine";
    license = licenses.mit;
    mainProgram = "moonshine-cli";
  };
}
