# Build notes

The repository intentionally contains `project.yml` instead of a hand-maintained `.xcodeproj`. GitHub Actions can install XcodeGen and generate a deterministic project before invoking `xcodebuild`.

The unsigned IPA workflow will:

1. Select an installed Xcode version.
2. Install XcodeGen.
3. Run `Scripts/generate_project.sh`.
4. Build the `DavWriter` scheme for `generic/platform=iOS` with code signing disabled.
5. Place `DavWriter.app` in a `Payload` directory.
6. Zip `Payload` as an unsigned IPA artifact.

A repository-specific workflow can be added after the project is uploaded.
