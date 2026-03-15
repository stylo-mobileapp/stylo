import scrapy 
from scrapy.http import HtmlResponse 
from ..items import BirkenstockItem
from chompjs import parse_js_object
from urllib.parse import urlencode


class BirkenstockSpider(scrapy.Spider):
    name = "Birkenstock"
    url = "https://www.birkenstock.com/it-en/{}/"
    genders = {
        "men-collection": "Men",
        "women-collection": "Women",
        "kids": "Kids",
    }

    def start_requests(self):
        for gender in self.genders.keys():
            querystring = {"start": 0, "sz": 24}
            urlencoded_query = urlencode(querystring)

            url = self.url.format(gender)
            yield scrapy.Request(
                url=f"{url}?{urlencoded_query}",
                callback=self.parse,
                meta={
                    "querystring": querystring,
                    "gender": gender,
                }
            )

    def parse(self, response: HtmlResponse):
        tags = response.css("div.l-plp_grid-tiles div[role='listitem']")

        for tag in tags:
            url = tag.css("a::attr(href)").get()
            url = f"https://www.birkenstock.com{url}"
            item = BirkenstockItem()
            item["brand"] = "Birkenstock"
            item["category"] = "Footwear"
            item["gender"] = self.genders[
                response.meta["gender"]
            ]
            item["image_url"] = tag.css("img::attr(src)").get()
            item["title"] = parse_js_object(
                tag.css("a::attr(data-analytics)").get()
            )["item_name"]
            item["url"] = url

            yield scrapy.Request(
                url=url,
                callback=self.parse_product,
                meta={"item": item}
            )
        
        if response.css("button[data-tau='load_more']"):
            querystring = response.meta["querystring"]
            querystring["start"] += 24
            gender = response.meta["gender"]
            urlencoded_query = urlencode(querystring)

            url = self.url.format(gender)

            yield scrapy.Request(
                url=f"{url}?{urlencoded_query}",
                callback=self.parse,
                meta={
                    "querystring": querystring,
                    "gender": gender,
                }
            )
    
    def parse_product(self, response: HtmlResponse):
        item = response.meta["item"]
        item["original_price"] = response.css("div.b-product_details-price span.b-price-item.m-old::text").get()
        item["price"] = response.css("div.b-price::attr(data-price)").get()

        if item["original_price"] is None:
            item["original_price"] = item["price"]

        item["sku"] = response.css("span[data-tau='product_details_id']::text").get()
        item["variants"] = (
            response.css("#panel-EU div[role='radiogroup'] button"),
            item["price"]
        )
        yield item 