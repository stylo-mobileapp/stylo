# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


def serialize_image_url(image_url: str) -> str:
    return image_url.split("?")[0]

def serialize_url(url: str) -> str:
    return f"https://prm.com/it/p/{url}"

def serialize_variants(
        values: tuple[list[dict], float],
) -> dict:
    data = {}
    variants, price = values
    
    for variant in variants:
        size: str = variant["name"]
        
        data[size] = {
            "availability": variant["variation"]["availability"] != "OUT_OF_STOCK",
            "price": price,
        }

    return data 

class PrmItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    brand = scrapy.Field()
    category = scrapy.Field()
    gender = scrapy.Field()
    image_url = scrapy.Field(serializer=serialize_image_url)
    original_price = scrapy.Field()
    price = scrapy.Field()
    sku = scrapy.Field()
    title = scrapy.Field()
    url = scrapy.Field(serializer=serialize_url)
    variants = scrapy.Field(serializer=serialize_variants)
