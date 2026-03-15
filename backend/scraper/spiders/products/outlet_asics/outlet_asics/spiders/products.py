import scrapy 
from scrapy.http import HtmlResponse 
from ..items import OutletAsicsItem
from chompjs import parse_js_object
from urllib.parse import urlencode


class OutletAsicsSpider(scrapy.Spider):
    name = "OutletAsics"
    url = "https://outlet.asics.com/it/en-it/"
    categories = {
        "mens-shoes/c/ao10200000/" : ("Footwear", "Men"),
        "mens-clothing/c/ao10300000/": ("Apparel", "Men"),
        "womens-shoes/c/ao20200000/" : ("Footwear", "Women"),
        "womens-clothing/c/ao20300000/": ("Apparel", "Women"),
        "kids-shoes/c/ao30200000/" : ("Footwear", "Kids"),
    }
    has_download_delay = True

    def start_requests(self):
        for category in self.categories.keys():
            querystring = {"page": 1}
            urlencoded_query = urlencode(querystring)

            yield scrapy.Request(
                url=f"{self.url}{category}?{urlencoded_query}",
                callback=self.parse,
                meta={"querystring": querystring, "category": category},
            )

    def parse(self, response: HtmlResponse):
        tags = response.css("div[data-test='product-grid'] div.productTile__root")

        for tag in tags:
            url = tag.css("a::attr(href)").get()
            url = f"https://outlet.asics.com{url}"
            item = OutletAsicsItem()
            item["brand"] = "ASICS"
            item["category"] = self.categories[
                response.meta["category"]
            ][0]
            item["gender"] = self.categories[
                response.meta["category"]
            ][1]
            item["original_price"] = tag.css("div[data-test='product-tile-price']::attr(data-max-price)").get()
            item["price"] = tag.css("div[data-test='product-tile-price']::attr(data-min-price)").get()

            yield scrapy.Request(
                url=url,
                callback=self.parse_product,
                meta={"item": item}
            ) 
        
        if response.css("a[data-test='plp-load-more']"):
            querystring = response.meta["querystring"]
            querystring["page"] += 1
            category = response.meta["category"]

            urlencoded_query = urlencode(querystring)

            yield scrapy.Request(
                url=f"{self.url}{category}?{urlencoded_query}",
                callback=self.parse,
                meta={"querystring": querystring, "category": category},
            )

    def parse_product(self, response: HtmlResponse):
        item = response.meta["item"]
        data = parse_js_object(
            response.css("script[type='application/ld+json']::text").get()
        )
        item["image_url"] = data["image"][0]
        item["sku"] = data["sku"]
        item["title"] = data["name"]
        item["url"] = response.url 
        item["variants"] = (
            response.css("div[data-test='pdp-size-selector-grid'] div.grid-c_span_1"),
            item["price"]
        )
        yield item