---
name: transcribe-youtube
description: Fetch a YouTube video transcript into a text file using Grant's transcribe Docker project (youtube-transcript-api, not Whisper). Use whenever the user asks to transcribe a YouTube video, get captions from a URL, or save a talk as .txt from watch or youtu.be links—even if they say "transcribe" casually or paste only a URL.
---

# Transcribe YouTube → plain text

## What it is

- **Repo:** dedicated `transcribe` project (Docker Compose).
- **Mechanism:** `youtube-transcript_api` fetches **existing YouTube captions** and writes **one** UTF-8 file. It does **not** run speech-to-audio transcription (no Whisper).
- **Output:** `transcriptions/{NAME}.txt` at the project root (`NAME` is sanitized: unsafe path characters stripped).

## Where to run

- `cd` to the **transcribe project root** (multi-root workspace folder, or path from user / `local-context.mdc`).
- Do not assume a home directory path in user-facing copy; resolve from workspace or ask once.

## Command that always works (recommended)

`docker-compose.yml` uses `env_file: .env`. Values in `.env` (especially `NAME` and `YOUTUBE_VIDEO_URL`) can win over shell exports unless you **inject into the container** with `-e`:

```bash
cd <transcribe-project-root>
docker compose run --rm \
  -e YOUTUBE_VIDEO_URL='https://www.youtube.com/watch?v=VIDEO_ID' \
  -e NAME='Human Readable Title' \
  transcribe
```

- **`--rm`:** remove the one-shot container after exit.
- **Quotes:** use single quotes around URL and name if they contain spaces or `&`.

## Alternatives

**From `.env` only** (after `cp .env.example .env` and editing both vars):

```bash
cd <transcribe-project-root>
docker compose run --rm transcribe
```

**First-time image build:** same command; Compose builds from `Dockerfile` if needed.

## After the run

1. Confirm stdout: `Wrote /app/transcriptions/{NAME}.txt` (path inside container mirrors host volume).
2. On the host, open `transcriptions/{NAME}.txt` next to `docker-compose.yml`.

## Failure modes

- **Missing captions:** API errors—video may have no captions or be restricted.
- **Wrong filename:** If output used `.env`’s `NAME` instead of the user’s title, you forgot `-e NAME=...`; re-run with explicit `-e` flags.

## Optional: Hormozi / long-form follow-up

If the user wants rules extracted from the transcript, see `cursor-rules` → `alex-factory.mdc` and `alex-trigger.mdc`.
