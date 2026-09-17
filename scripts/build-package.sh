#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE="$ROOT/package"
DIST="$ROOT/dist"

VERSION="$(
    python3 - "$PACKAGE/metadata.json" <<'PY'
import json
import sys
from pathlib import Path

metadata = Path(sys.argv[1])

data = json.loads(
    metadata.read_text(encoding="utf-8")
)

print(data["KPlugin"]["Version"])
PY
)"

OUTPUT="$DIST/nostalgia-weather-${VERSION}.plasmoid"

mkdir -p "$DIST"
rm -f "$OUTPUT"

python3 - "$PACKAGE" "$OUTPUT" <<'PY'
import sys
import zipfile
from pathlib import Path

package = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve()

with zipfile.ZipFile(
    output,
    "w",
    compression=zipfile.ZIP_DEFLATED,
) as archive:
    for path in sorted(package.rglob("*")):
        if not path.is_file():
            continue

        relative = path.relative_to(package)

        name = path.name

        if (
            ".bak" in name
            or name.endswith("~")
            or name.endswith(".orig")
            or name.endswith(".rej")
            or name == ".DS_Store"
        ):
            continue

        archive.write(
            path,
            relative.as_posix(),
        )

print(output)
PY

echo
echo "Package built:"
echo "$OUTPUT"
