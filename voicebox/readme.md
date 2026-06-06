# Voicebox

Voicebox is a local-first AI voice studio for text-to-speech, voice cloning, transcription, dictation, effects, and MCP voice tools.

## Start

```bash
docker compose up --build -d
```

Then open:

```text
http://127.0.0.1:17493
```

## Notes

- This compose builds Voicebox from the public GitHub repository.
- The service binds to localhost only by default.
- Generated audio is written to `./output`.
- App state is stored in the `voicebox-data` named volume.
- Model downloads are stored in the `huggingface-cache` named volume.
- The default resource limit is `4` CPUs and `8G` RAM. Larger models can need more RAM and disk.

## Tested Locally

This stack was tested on a CPU-only Linux machine with Docker Compose. The container built and served the UI at `127.0.0.1:17493`. Smaller models such as LuxTTS, Chatterbox Multilingual, Qwen TTS 0.6B, and Whisper Base were usable for local trials. TADA 3B Multilingual downloaded but did not load successfully on a 14 GiB RAM host with no swap.
