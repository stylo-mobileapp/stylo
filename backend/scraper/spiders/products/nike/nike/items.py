# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


def serialize_variants(values: list) -> dict[str, bool | float]:
    variants, price, sku = values[0], values[1], values[2]
    data = {}

    for x in variants:
        if x["productCode"] == sku:
            size = x["localizedLabel"]

            data[size] = {
                "availability": x["availability"]["isAvailable"],
                "price": price,
            }
    
    return data

class NikeItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    brand = scrapy.Field()
    category = scrapy.Field()
    gender = scrapy.Field()
    image_url = scrapy.Field()
    original_price = scrapy.Field()
    price = scrapy.Field()
    sku = scrapy.Field()
    title = scrapy.Field()
    url = scrapy.Field()
    variants = scrapy.Field(serializer=serialize_variants)
