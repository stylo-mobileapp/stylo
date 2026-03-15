import scrapy 
from scrapy.http import HtmlResponse 
from ..items import PrmItem
from chompjs import parse_js_object
from urllib.parse import urlencode


class PrmSpider(scrapy.Spider):
    name = "Prm"
    url = "https://prm.com/it/k/"
    genders = {
        "uomo": "Men",
        "donna": "Women"
    }
    categories = {
        "scarpe": "Footwear",
        "abbigliamento": "Apparel",
    }

    def start_requests(self):
        for gender in self.genders.keys():
            for category in self.categories.keys():
                querystring = {"page": 1}
                urlencoded_query = urlencode(querystring)

                yield scrapy.Request(
                    url=f"{self.url}{gender}/{category}?{urlencoded_query}",
                    callback=self.parse,
                    meta={"querystring": querystring, "gender": gender, "category": category}
                ) 

    def parse(self, response: HtmlResponse):
        for text in response.css("script::text").getall():
            if "appConfig" in text:
                data = parse_js_object(
                    text.split("window.__PRELOADED_STATE__ = ")[-1]
                )
                products =  data["products"]["ware"]["list"]

                for product in products:
                    item = PrmItem()
                    product_id = product["id"]
                    item["brand"] = product["productBrand"]["name"]
                    item["category"] = self.categories[
                        response.meta["category"]
                    ]
                    item["gender"] = self.genders[
                        response.meta["gender"]
                    ]
                    item["image_url"] = product["productImages"]["mainImageUrl"]
                    item["original_price"] = product["priceRegular"]
                    item["price"] = product["price"]
                    item["sku"] = None 
                    item["title"] = product["name"]
                    item["url"] = product["slug"] + "-" + str(product_id)
                    item["variants"] = (
                        product["allSizes"],
                        item["price"]
                    )
                    yield item 
        
        if response.css("link[rel='next']"):
            querystring = response.meta["querystring"]
            querystring["page"] += 1
            gender, category = response.meta["gender"], response.meta["category"]

            urlencoded_query = urlencode(querystring)
            yield scrapy.Request(
                url=f"{self.url}{gender}/{category}?{urlencoded_query}",
                callback=self.parse,
                meta={"querystring": querystring, "gender": gender, "category": category}
            ) 