# Perl and Python video edition

The 14 November 2026 update adds seven explained Python command cards to the
existing installation tutorial. Both Perl and Python users can run saved SAS
programs and scientific examples through MCP4SAS. The Python section begins at
**9:58**; the complete video runs **12 minutes 42 seconds**.

The video covers native Python environment setup on Windows, macOS and Ubuntu,
matching SAS-code and saved-file submissions, clustergram and multi-GWAS examples,
output validation and the separate Python MCP server. The existing 0.1.5 VS Code
plugin continues to configure the Perl runtime. Python is an optional separate
setup and does not require Perl or Cygwin.

The original 52 installation captures retain their creation-time order. The
Python additions are instructional command cards using the tested repository
entry points, not a new recording of a Python installation. The synthetic female
voice and the original SAS/VSIX pronunciation rules are retained. Account setup
remains private, and SAS encryption JARs must be obtained from SAS.

## Recorded media checks

- 1920 × 1080 H.264 video with AAC audio; complete decoding produced no errors.
- The first video frame is a keyframe at timestamp zero showing the GitHub
  homepage. No black interval was detected in the first ten seconds.
- All original screenshot hashes, order and caption timings passed validation.
- One small caption layer is burned into the video. There is no additional
  subtitle stream or automatically loaded subtitle sidecar.
- All seven Python cards passed text-bound checks and were sampled from the
  encoded video for inspection.
- The local browser player passed initial-poster, playback, Codex/Python chapter
  seek and mobile-width checks, with no JavaScript errors.
- The release video is identified by exact size and SHA-256 in `video.json`;
  the Pages build verifies those bytes before publishing.

Editable Python cards and narration are retained in
[`python-demo-scenes.json`](python-demo-scenes.json), with the full
[`transcript`](transcript.md). Runnable commands and their execution evidence
are described in the [paired demo guide](../PYTHON_DEMOS.md).
