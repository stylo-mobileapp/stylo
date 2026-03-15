# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


def serialize_price(price: str) -> float:
    return float(price)

def serialize_variants(
    values: tuple[list[scrapy.Selector], str]
):
    variants, price = values
    price = serialize_price(price)
    data = {}

    for x in variants:
        size: str = x.css("button").attrib["productdata-sizevalue"]

        data[size] = {
            "availability": True if x.css("button::attr(data-instock)").get().lower() == "true" else False,
            "price": price,
        }

    return data

class OutletAsicsItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    brand = scrapy.Field()
    category = scrapy.Field()
    gender = scrapy.Field()
    image_url = scrapy.Field()
    original_price = scrapy.Field(serializer=serialize_price)
    price = scrapy.Field(serializer=serialize_price)
    sku = scrapy.Field()
    title = scrapy.Field()
    url = scrapy.Field()
    variants = scrapy.Field(serializer=serialize_variants)
