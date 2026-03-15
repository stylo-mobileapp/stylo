# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html

import scrapy
from bs4 import BeautifulSoup


def serialize_image_url(image_url: str | None) -> str | None:
    if not image_url:
        return None

    return image_url.split("?")[0]

def serialize_price(price: str | None) -> float | None:
    try:
        return float(price)
    except ValueError:
        return None

def serialize_sku(
        values: list[scrapy.Selector]
    ) -> str | None:
    for value in values:
        soup = BeautifulSoup(value.get(), "html.parser")

        if "Codice produttore" in soup.text:
            return soup.find("strong").text

    return None

def serialize_variants(
        values: tuple[
            str, list[scrapy.Selector]
        ]
) -> dict:
    price, variants = values

    try:
        price = float(price)
    except ValueError:
        return {}
    
    data = {}

    for variant in variants:
        size: str = variant.css("::attr(data-display-value)").get() 

        data[size] = {
            "availability": True,
            "price": price,
        }

    return data
class CisalfaSportItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    brand = scrapy.Field()
    category = scrapy.Field()
    gender = scrapy.Field()
    image_url = scrapy.Field(serializer=serialize_image_url)
    original_price = scrapy.Field(serializer=serialize_price)
    price = scrapy.Field(serializer=serialize_price)
    sku = scrapy.Field(serializer=serialize_sku)
    title = scrapy.Field()
    url = scrapy.Field()
    variants = scrapy.Field(serializer=serialize_variants)