# PulseAudio Remote Audio for macOS

Stream audio from a remote Linux machine to your Mac over SSH. Microphone input works too.

## Why

When using VNC or other remote desktop solutions that lack audio support, this script fills the gap. Audio from your remote Linux session plays through your Mac speakers, and your Mac microphone works for calls and recording. All with minimal latency via an SSH tunnel.

## How it works

The script installs PulseAudio on macOS, configures it to accept TCP connections on port 4713, and creates a LaunchAgent for automatic startup. Your remote Linux machine sends audio through an SSH reverse tunnel to your Mac's PulseAudio server. The same tunnel carries microphone input in the reverse direction.

## Usage

```bash
./pulseaudio-remote-setup.sh
```

Follow the prompts to select your audio output and input devices. The script will display instructions for configuring your SSH tunnel and Linux server.
