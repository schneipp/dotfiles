# PulseAudio Remote Audio for macOS

Stream audio from a remote Linux machine to your Mac over SSH.

## Why

When using VNC or other remote desktop solutions that lack audio support, this script fills the gap. Audio from your remote Linux session plays through your Mac speakers with minimal latency via an SSH tunnel.

## How it works

The script installs PulseAudio on macOS, configures it to accept TCP connections on port 4713, and creates a LaunchAgent for automatic startup. Your remote Linux machine sends audio through an SSH reverse tunnel to your Mac's PulseAudio server.

## Usage

```bash
./pulseaudio-remote-setup.sh
```

Follow the prompts to select your audio output device. The script will display instructions for configuring your SSH tunnel and Linux server.
