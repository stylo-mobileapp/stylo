import scrapy 
from scrapy.http import HtmlResponse 
from ..items import CisalfaSportItem
from urllib.parse import urlencode


class CisalfaSportSpider(scrapy.Spider):
    name = "CisalfaSport"
    url = "https://www.cisalfasport.it/it-it/"
    categories = {
        "abbigliamento": "Apparel",
        "scarpe": "Footwear",
    }
    genders = {
        "uomo": "Men",
        "donna": "Women",
        "bambino": "Kids",
    }

    def start_requests(self):
        for category in self.categories.keys():
            for gender in self.genders.keys():
                querystring = {"start": 0, "sz": 36}
                urlencoded_query = urlencode(querystring) 

                yield scrapy.Request(
                    url=f"{self.url}{gender}/{category}/?{urlencoded_query}",
                    callback=self.parse,
                    meta={"category": category, "gender": gender, "querystring": querystring}
                )

    def parse(self, response: HtmlResponse):
        tags = response.css("div[itemid='#product'] article.cc-plp__item")

        for tag in tags:
            item = CisalfaSportItem()
            url = tag.css("a::attr(href)").get()
            url = f"https://www.cisalfasport.it{url}"
            item["brand"] = tag.css("span.cc-tile__product-brand::text").get()
            item["category"] = self.categories[
                response.meta["category"]
            ] 
            item["gender"] = self.genders[
                response.meta["gender"]
            ]
            item["image_url"] = tag.css("div.cc-product-image img::attr(src)").get()
            item["url"] = url 

            yield scrapy.Request(
                url=url,
                callback=self.parse_product,
                meta={"item": item}
            )
        
        if response.css("link[rel='next']"):
            response.meta["querystring"]["start"] += 36
            querystring = response.meta["querystring"]
            urlencoded_query = urlencode(querystring)
            gender = response.meta["gender"]
            category = response.meta["category"]

            yield scrapy.Request(
                url=f"{self.url}{gender}/{category}/?{urlencoded_query}",
                callback=self.parse,
                meta={"category": category, "gender": gender, "querystring": querystring}
            )
    
    def parse_product(self, response: HtmlResponse):
        item = response.meta["item"]
        item["original_price"] = response.css("div.prices.cc-pdp__prices s.value.cc-product__prices--default::attr(content)").get()
        item["price"] = response.css("span.cc-product__price span.value::attr(content)").get()

        if item["original_price"] is None:
            item["original_price"] = item["price"]

        item["sku"] = response.css("#specificationsCollapse ul li")
        item["title"] = response.css("span.cc-pdp__product-name::text").get()
        item["variants"] = (
            item["price"],
            response.css("div[aria-label='Seleziona Taglie'] button.size-attribute.cc-pdp__size-attribute.js-size-attribute.cc-available"),
        )
        yield item 