# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


def serialize_image_url(
        image_url: list[str]
    ) -> str:
    image_url = image_url[0]
    return f"https://media.endclothing.com/media/f_auto,q_auto:eco,w_768/prodmedia/media/catalog/product{image_url}"

def serialize_price(price: int) -> float:
    return float(price)

def serialize_url(url: str) -> str:
    return f"https://www.endclothing.com/it/{url}.html"

def serialize_variants(
        values: tuple[list[str], int]
) -> dict:
    variants, price = values 
    price = serialize_price(price)

    data = {}

    for x in variants:
        data[x] = {
            "availability": True,
            "price": price
        }

    return data 

class EndClothingItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    brand = scrapy.Field()
    category = scrapy.Field()
    gender = scrapy.Field()
    image_url = scrapy.Field(serializer=serialize_image_url)
    original_price = scrapy.Field(serializer=serialize_price)
    price = scrapy.Field(serializer=serialize_price)
    sku = scrapy.Field()
    title = scrapy.Field()
    url = scrapy.Field(serializer=serialize_url)
    variants = scrapy.Field(serializer=serialize_variants)
