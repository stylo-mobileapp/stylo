import csv
import os
from typing import Generator


def normalize(value):
    if isinstance(value, str):
        value = value.strip()
        return value or None
    
    return value

def read_all_csv(directory: str) -> Generator[dict, None, None]:
    if not os.path.exists(directory):
        print(f"Directory does not exist: {directory}")
        return

    for filename in sorted(
        os.listdir(directory)
    ):
        if not filename.endswith(".csv"):
            continue

        filepath = os.path.join(directory, filename)
        source = filename.replace(".csv", "")

        print(f"Reading: {filename}")

        with open(filepath, "r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                row = {
                    k: normalize(v) for k, v in row.items()
                }
                row["source"] = source
                yield row
