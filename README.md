# Restream two languages to two YouTube streams

This project takes a single stereo SRT stream (e.g. from [OBS](https://obsproject.com/)) with dual-language audio (left channel = language 1, right channel = language 2) and restreams it to two separate YouTube Live events.

## Features

- **SRT Input:** Listens for an incoming SRT connection (e.g., from OBS).
- **Audio Splitting:** Automatically splits the stereo input into two mono streams (left to one YouTube key, right to another).
- **Passphrase Support:** Secure your SRT stream with an optional passphrase.
- **Auto-Restart:** Automatically reconnects and resumes if the input stream drops.
- **Dockerized:** Easy deployment using Docker and Docker Compose.

## Prerequisites

- Docker and Docker Compose installed.
- Two YouTube Live stream keys.

## Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/martin-pfister/restream-dual-language-to-youtube.git
   cd restream-dual-language-to-youtube
   ```

2. **Configure environment variables:**
   Create a `.env` file from the provided template:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and fill in your YouTube stream keys and an optional SRT passphrase.

3. **Start the service:**
   ```bash
   docker compose up -d
   ```

4. **Increase receive socket buffer size to 64MB:**
   Run this on the host:
   ```bash
   sudo tee /etc/sysctl.d/99-srt-tuning.conf > /dev/null <<EOF
   # FFmpeg SRT UDP Buffer Tuning
   # Increases max network receive buffers to 64MB to prevent packet drops
   net.core.rmem_max=67108864
   net.core.rmem_default=67108864
   EOF
   sudo sysctl --system
   ```

## Configuration

| Variable | Description |
|----------|-------------|
| `YOUTUBE_KEY_LEFT` | YouTube stream key for the Left audio channel. |
| `YOUTUBE_KEY_RIGHT` | YouTube stream key for the Right audio channel. |
| `SRT_INPUT_PASSPHRASE` | (Optional) Passphrase required for the incoming SRT stream (min 10 chars recommended). |
| `SRT_INPUT_PORT` | (Optional) Port to listen for the incoming SRT stream (default: 9000). |

## Usage (OBS Setup)

1. Go to **Settings > Stream**.
2. Set **Service** to `Custom...`.
3. Set **Server** to `srt://<your-server-ip>:<port>`. (Default port is 9000).
4. If you set a passphrase, append it to the URL: `srt://<your-server-ip>:<port>?passphrase=YOUR_PASSPHRASE`.
   - **Note:** The passphrase must be between 10 and 79 characters long.
5. Ensure your audio output is Stereo, with your primary language on the Left channel and the secondary on the Right.

## License

MIT
