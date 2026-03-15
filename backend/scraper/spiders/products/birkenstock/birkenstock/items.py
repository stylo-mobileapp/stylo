# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


def serialize_image_url(image_url: str | None) -> str | None:
    if image_url is None:
        return None

    return image_url.split("?")[0]

def serialize_price(price: str) -> float:
    return float(
        price.replace(",", ".").split()[0]
    )

def serialize_variants(
    values: tuple[list[scrapy.Selector], str]
) -> list[dict]:
    variants, price = values 
    price = serialize_price(price)

    data = {}

    for x in variants:
        size: str = x.css("::attr(title)").get().replace("(not available)", "")
        size = size.strip()

        data[size] = {
            "availability": "not available" not in x.css("::attr(aria-label)").get(),
            "price": price,
        }
    
    return data

class BirkenstockItem(scrapy.Item):
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
    url = scrapy.Field()
    variants = scrapy.Field(serializer=serialize_variants)

