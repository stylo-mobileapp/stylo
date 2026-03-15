import os
from pathlib import Path
import sys
import argparse
from dataclasses import dataclass


sys.path.insert(
    0, str(Path(__file__).resolve().parent)
)

from config import DATA_DIR
from scraper import run_spiders
from processor import read_all_csv, build_products
from database import save_products

@dataclass
class Args:
    category: str

def main() -> None:
    parser = argparse.ArgumentParser(description="Run the backend pipeline.")
    parser.add_argument(
        "category",
        help="Specific category to run (e.g., 'products', 'banners')."
    )

    args = Args(
        **vars(
            parser.parse_args()
        )
    )
    category = args.category.lower()

    # --- PHASE 1: SCRAPING ---
    run_spiders(category=category, target_file=category)

    # --- PHASE 1: READING & SAVING ---
    category_dir = os.path.join(DATA_DIR, category)

    if category == "products":
        raw_products = read_all_csv(category_dir)
        products = build_products(raw_products)
        save_products(products)
    else:
        pass

if __name__ == "__main__":
    main()
    