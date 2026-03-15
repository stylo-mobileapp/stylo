# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


def serialize_category(category: str) -> str:
    return category.title()

def serialize_gender(gender: str) -> str:
    return gender.title()

def serialize_price(price: str) -> float:
    return float(
        price.replace(".", "").replace(",", ".").split()[0]
    )

def serialize_url(url: str) -> str:
    return f"https://www.bstn.com/eu_it/{url}"

def serialize_variants(
        values: tuple[list, str]
) -> list[dict]:
    variants, price = values 
    price = serialize_price(price)
    data = {}

    for x in variants:
        size = x["label"]
        
        data[size] = {
            "availability": x["in_stock"] > 0,
            "price": price,
        }

    return data

class BstnItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    brand = scrapy.Field()
    category = scrapy.Field(serializer=serialize_category)
    gender = scrapy.Field(serializer=serialize_gender)
    image_url = scrapy.Field()
    original_price = scrapy.Field(serializer=serialize_price)
    price = scrapy.Field(serializer=serialize_price)
    sku = scrapy.Field()
    title = scrapy.Field()
    url = scrapy.Field(serializer=serialize_url)
    variants = scrapy.Field(serializer=serialize_variants)
