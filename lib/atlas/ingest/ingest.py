import os
import re
import shutil
from datetime import UTC, datetime
from hashlib import sha256
from pathlib import Path
from typing import Dict, Iterator, List

from sqlalchemy import create_engine, text
from tinytag import TinyTag

DB_URL = "postgresql://postgres:postgres@localhost:5432/atlas_dev"
LIBRARY = Path("priv/static/music")
SONG_PATTERN = re.compile(
    r"(?P<artist_name>.*)/\((?P<year>\d{4})\) - (?P<album_name>.*)/(?P<number>\d{1,3}\.?) (?P<title>.*)\.(?P<extension>\w{3,4})$"
)

CDN_URL = os.getenv("CDN_URL")
CDN_DIRECTORY = "./artwork"
Path(CDN_DIRECTORY).mkdir(exist_ok=True)


def get_album_art_file_path(album_path: Path) -> str:
    """Find the largest album art file in the album directory."""
    art_dir = album_path / "@eaDir"
    try:
        if not art_dir.exists():
            return ""
    except PermissionError:
        return ""
    track_dir = next(art_dir.iterdir())
    art_files = sorted(
        track_dir.iterdir(), key=lambda x: x.stat().st_size, reverse=True
    )
    return str(art_files[0].relative_to(LIBRARY)) if art_files else ""


def generate_artwork_digest(artist_name, album_name):
    value = "f{artist_name}{album_name}".encode("utf8")
    return sha256(value).hexdigest()


def ingest_album_art(artist_name, album_name, album_art_path):
    filename = sha256(f"{artist_name}{album_name}".encode("utf-8")).hexdigest()
    extension = album_art_path.split(".")[-1]
    if not 0 < len(extension) < 5:
        print(f"Ruh roh: {artist_name} {album_name}")
        return ""
    destination = f"{CDN_URL}{filename}.{extension}"
    shutil.copy(
        src=f"{LIBRARY}/{album_art_path}",
        dst=f"{CDN_DIRECTORY}/{filename}.{extension}",
        follow_symlinks=False,
    )
    return destination


def process_track(
    track_path: Path, album_art_path: str, artist_id: int, album_id: int
) -> Dict[str, str]:
    """Extract track information from file path and return as a dictionary."""

    relative_path = track_path.relative_to(LIBRARY)
    print(relative_path)
    match = SONG_PATTERN.match(str(relative_path))
    if not match:
        return {}

    track_data = match.groupdict()
    album_art_url = ingest_album_art(
        artist_name=track_data["artist_name"],
        album_name=track_data["album_name"],
        album_art_path=album_art_path,
    )

    track_data.update(
        {
            "art_url": album_art_url,
            "audio_url": f"/music/{str(relative_path)}",
            "duration": get_track_duration(track_path),
            "artist_id": artist_id,
            "album_id": album_id,
        }
    )
    return track_data


def get_track_duration(track_path):
    try:
        track = TinyTag.get(track_path)
        return track.duration or 0
    except FileNotFoundError:
        print("Track file not found.")
        return 0


def get_tracks() -> Iterator[Dict[str, str]]:
    """Generate track data for all music files in the library."""
    artist_id, album_id = 0, 0
    for artist_dir in LIBRARY.iterdir():
        if not artist_dir.is_dir():
            continue
        artist_id += 1
        for album_dir in artist_dir.iterdir():
            if not album_dir.is_dir():
                continue

            album_art_path: str = get_album_art_file_path(album_dir)
            album_id += 1
            for track_file in album_dir.iterdir():
                if track_file.is_file() and track_file.suffix.lower() in (
                    ".mp3",
                    ".flac",
                ):
                    track_data = process_track(
                        track_path=track_file,
                        album_art_path=album_art_path,
                        artist_id=artist_id,
                        album_id=album_id,
                    )
                    if track_data:
                        yield track_data


def insert_tracks(tracks: List[Dict[str, str]]):
    """Insert tracks into the database, updating existing entries if necessary."""
    engine = create_engine(DB_URL)
    insert_query = text("""
    INSERT INTO tracks (artist_id, album_id, artist_name, album_name, title, audio_url, art_url, number, year, duration, inserted_at, updated_at)
    VALUES (:artist_id, :album_id, :artist_name, :album_name, :title, :audio_url, :art_url, :number, :year, :duration, :inserted_at, :updated_at)
    """)

    current_time = datetime.now(UTC)
    for track in tracks:
        track["inserted_at"] = current_time
        track["updated_at"] = current_time

    with engine.begin() as conn:
        conn.execute(insert_query, tracks)


def main():
    tracks = list(get_tracks())
    insert_tracks(tracks)
    print(f"Processed {len(tracks)} tracks.")


if __name__ == "__main__":
    main()
