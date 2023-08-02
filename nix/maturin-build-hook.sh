#!/usr/bin/env sh

customBuildHook() {
    echo "Executing customBuildHook"

    runHook preBuild

    if [ ! -z "${buildAndTestSubdir-}" ]; then
        pushd "${buildAndTestSubdir}"
    fi

    cd ..
    (
    set -x
    pwd
    env \
      "CC_@rustBuildPlatform@=@ccForBuild@" \
      "CXX_@rustBuildPlatform@=@cxxForBuild@" \
      "CC_@rustTargetPlatform@=@ccForHost@" \
      "CXX_@rustTargetPlatform@=@cxxForHost@" \
      maturin build \
        --jobs=$NIX_BUILD_CORES \
        --frozen \
        --target @rustTargetPlatformSpec@ \
        --manylinux off \
        --strip \
        --release \
        ${maturinBuildFlags-}
    )

    runHook postBuild

    if [ ! -z "${buildAndTestSubdir-}" ]; then
        popd
    fi

    # Move the wheel to dist/ so that regular Python tooling can find it.
    set -x
    cd /build
    mkdir -p dist
    mv source/rust/target/wheels/*.whl dist/

    echo "Finished customBuildHook"
}

buildPhase=customBuildHook
