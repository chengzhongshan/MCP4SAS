# Installation video

The current edition includes matching **Perl and Python** commands for SAS
submission, saved files, scientific examples and output checking. The final
section explains native Python setup on Windows, macOS and Ubuntu and the
optional Python MCP server. The existing 0.1.5 plugin keeps its Perl runtime.

The [Python scene source](python-demo-scenes.json) retains the editable command
cards and narration. Read the [paired demo guide](../PYTHON_DEMOS.md) for runnable
commands and evidence limits.

Watch online: https://chengzhongshan.github.io/MCP4SAS/

The README links to the browser player on GitHub Pages. The MP4 and offline
viewer are assets on the existing vscode-v0.1.5 release, keeping the large
video out of Git history. The source HTML, styles, player, poster and transcript
are maintained here. video.json identifies the approved MP4 by size and SHA-256.

The Pages workflow downloads that exact release asset, verifies it and publishes
it with the player. The homepage remains visible until the first decoded frame.
There are no external subtitle tracks to duplicate the smaller captions.

To build a preview from an existing local video:

    node scripts/build_installation_site.cjs --video-file /path/to/video.mp4 --out /path/to/preview

To build from the published release:

    node scripts/build_installation_site.cjs

The video uses supplied installation captures and synthetic English narration.
Private credential files and licensed SAS JARs are not distributed. The actual
SAS connection still requires a valid account or licensed local installation.
