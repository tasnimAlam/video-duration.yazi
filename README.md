# video-duration.yazi

A [Yazi](https://github.com/sxyazi/yazi) plugin to display the total duration of selected video files.

## Features

- Calculate total duration of selected video files
- Automatically skips non-video files
- Works with single or multiple file selections
- Displays duration in human-readable format (hours, minutes, seconds)
- Supports wide range of video formats

## Demo

<video src="https://github.com/user-attachments/assets/f97b7381-08bb-4dc7-b904-0bbe72617bca" controls width="100%"></video>

## Prerequisites

- [Yazi](https://github.com/sxyazi/yazi) file manager
- [MediaInfo](https://mediaarea.net/en/MediaInfo) command-line tool

## Installation

```bash
ya pkg add tasnimAlam/video-duration
```

## Configuration

Add this keybinding to `~/.config/yazi/keymap.toml`:

```toml
[[manager.prepend_keymap]]
on   = "V"
run  = "plugin video-duration"
desc = "Show total video duration"
```

## Supported Video Formats

The plugin recognizes the following video file extensions:

- `.mp4`, `.mkv`, `.avi`, `.mov`
- `.webm`, `.flv`, `.wmv`, `.m4v`
- `.mpg`, `.mpeg`, `.3gp`
- `.ts`, `.mts`, `.m2ts`
- `.ogv`, `.vob`

## License

MIT

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
