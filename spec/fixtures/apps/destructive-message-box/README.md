# Destructive Message Box Demo

This manual fixture compares the existing macOS message box with one whose
`Don't Save` button has `NSButton.hasDestructiveAction` enabled.

The prompt mirrors the three-button unsaved-editor flow reported in
[VS Code issue 325273][vscode-issue], which motivated this probe.

## Build and run

From the Electron source directory, use the checkout's configured Build Tools
environment:

```sh
e build
npm start -- spec/fixtures/apps/destructive-message-box
```

`npm start` automatically finds the standard output directories. For a custom
directory, set `ELECTRON_OUT_DIR`, for example:

```sh
ELECTRON_OUT_DIR=MyBuild npm start -- \
  spec/fixtures/apps/destructive-message-box
```

For a manually configured testing checkout, build and run with:

```sh
ninja -C ../out/Testing electron
../out/Testing/Electron.app/Contents/MacOS/Electron \
  spec/fixtures/apps/destructive-message-box
```

## Manual macOS matrix

Enable **System Settings > Keyboard > Keyboard Shortcuts > Keyboard >
Keyboard navigation**, then compare **Open baseline** with **Open destructive
variant**. Start every row from a fresh dialog and record the macOS version.

| Check | Observe |
| --- | --- |
| Initial keyboard focus | Which button has keyboard focus when the dialog opens? |
| Appearance | Is `Don't Save` red or otherwise visually distinguished? |
| Space | Which response fires without moving focus first? |
| Return | Which response fires without moving focus first? |
| Escape | Does response `2` (`Cancel`) fire? |
| Command-D | Does response `1` (`Don't Save`) fire? |

The fixture displays the response index and label in its window and logs the
same result to the terminal. Do not infer keyboard behavior from the
`hasDestructiveAction` property alone; AppKit documents the resulting behavior
as system-dependent.

[vscode-issue]: https://github.com/microsoft/vscode/issues/325273
