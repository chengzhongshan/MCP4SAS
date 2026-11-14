# Installation video

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
