from dataclasses import dataclass, asdict 
from typing import Generator
import ast 

from ..affiliate import create_affiliate_link


@dataclass
class Product:
    availability: bool 
    brand: str 
    category: str 
    gender: str
    image_url: str
    original_price: float 
    price: float 
    discount_percentage: float
    sku: str | None 
    title: str
    url: str
    variants: dict
    all_sizes: list[str]
    available_sizes: list[str]
    text_search: str
    source: str

    def to_dict(self) -> dict:
        return asdict(self)


def build_products(
    rows: Generator[dict, None, None]
) -> list[dict]:
    data: list[dict] = []
    ignored_count = 0
    total_count = 0

    for row in rows:
        total_count += 1

        brand: str | None = row["brand"]
        category: str = row["category"]
        gender: str = row["gender"]
        image_url: str | None = row["image_url"]
        original_price: str | None = row["original_price"]
        price: str | None = row["price"]
        sku: str | None = row["sku"]
        title: str | None = row["title"]
        url: str | None = row["url"]
        variants: str | None = row["variants"]
        source: str = row["source"]

        if not brand or not image_url or not original_price or not price or not title or not url or not variants:
            ignored_count += 1
            continue

        variants: dict = ast.literal_eval(variants)

        if not variants:
            ignored_count += 1
            continue

        original_price, price = float(original_price), float(price)
        discount_percentage = round(
            number=(
                (original_price - price) / original_price
            ) * 100
        )

        availability = any(
            v["availability"] for v in variants.values()
        )
        all_sizes = list(
            variants.keys()
        )
        available_sizes = [
            size for size, v in variants.items() if v["availability"]
        ]   

        parts = [brand, title, sku]
        text_search = " ".join(
            part for part in parts if part
        ) 

        product = Product(
            availability=availability,
            brand=brand,
            category=category,
            gender=gender,
            image_url=image_url,
            original_price=original_price,
            price=price,
            discount_percentage=discount_percentage,
            sku=sku,
            title=title,
            url=create_affiliate_link(url, source),
            variants=variants,
            all_sizes=all_sizes,
            available_sizes=available_sizes,
            text_search=text_search,
            source=source
        )
        data.append(
            product.to_dict()
        )
    
    print(f"Ignored {ignored_count} out of {total_count} products due to missing critical fields.")
    print("Finshed building products.")

    return data


        
