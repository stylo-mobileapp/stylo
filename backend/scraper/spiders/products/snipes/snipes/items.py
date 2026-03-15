# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


def serialize_brand(brand: str) -> str:
    return brand.strip()

def serialize_image_url(
        values: tuple[str, str]
) -> str:
    image_id, url = values 
    url = url.split("/")[-1]
    return f"https://asset.snipes.com/images/{image_id}/{url}"

def serialize_price(price: str) -> float:
    return float(
        price.replace(".", "").replace(",", ".").split()[0]
    )

def serialize_url(url: str) -> str:
    return f"https://www.snipes.com/it-it{url}"

def serialize_variants(
        variants: list[dict]
) -> dict[str, bool | float]:
    def format_price(price: int) -> float:
        return float(price / 100)

    data = {}

    for x in variants:
        size = x["sizeMap"]["size"]["value"]
        price = x["price"]["withTax"]
        
        data[size] = {
            "availability": x["stock"]["quantity"] > 0,
            "price": format_price(price), 
        }
    
    return data

class SnipesItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    brand = scrapy.Field(serializer=serialize_brand)
    category = scrapy.Field()
    gender = scrapy.Field()
    image_url = scrapy.Field(serializer=serialize_image_url)
    original_price = scrapy.Field(serializer=serialize_price)
    price = scrapy.Field(serializer=serialize_price)
    sku = scrapy.Field()
    title = scrapy.Field()
    url = scrapy.Field(serializer=serialize_url)
    variants = scrapy.Field(serializer=serialize_variants)
