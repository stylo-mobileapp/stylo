import scrapy
from scrapy.http import HtmlResponse 
from ..items import SnipesItem
from urllib.parse import urlencode


class SnipesSpider(scrapy.Spider):
    name = "Snipes"
    url = "https://api.snipes.com/sni-pl-prd-stor-we-char/v1/v1/categories/"
    categories = {
        "77": ["Footwear", "Men"],
        "78": ["Apparel", "Men"],
        "80": ["Footwear", "Women"],
        "81": ["Apparel", "Women"],
        "83": ["Footwear", "Kids"],
        "84": ["Apparel", "Kids"],
    }
    headers = {
        "accept": "application/json, text/plain, */*",
        "accept-language": "it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7",
        "origin": "https://www.snipes.com",
        "pragma": "no-cache",
        "priority": "u=1, i",
        "referer": "https://www.snipes.com/",
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-site",
        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36",
        "x-charybdis": "eyJjb25jZXB0IjoiU05JIiwic2NheWxlRW52aXJvbm1lbnQiOiJzbmlwZXMtbGl2ZSIsInNjYXlsZVNob3BJZCI6IjEwMzkiLCJjbXNTcGFjZSI6ImtqZjIyd2Y0d3NvaCIsImNtc0Vudmlyb25tZW50IjoibWFzdGVyIiwiY21zQWNjZXNzVG9rZW4iOiJ5c1A0THNWRzUzQVo1Wm01Wk9ub2Fjc0JOU0o2Rzhib1Nvb3dwTnJEcW1NIiwidHJlZSI6IjEwIiwiaGFkZXMiOmZhbHNlLCJjYW1wYWlnbktleSI6Ii01MF9CbGFja19XZWVrXzIwMjUiLCJjb250ZXh0IjoiaXQtaXQiLCJ1c2VNaXdhIjpmYWxzZSwibG95YWx0eSI6dHJ1ZSwibG95YWx0eUNhbXBhaWduS2V5IjoibG95YWx0eSIsImNvbXBhbnkiOiJzaXQiLCJuZXdzbGV0dGVyUmVnaXN0cmF0aW9uIjoiMiIsInVzZXJSZWdpc3RyYXRpb24iOjQsIm5vdGlmeU1lUmVnaXN0cmF0aW9uIjoiMiIsImxveWFsdHlFbmdpbmUiOiJzbmlwZXMiLCJzb3VyY2UiOiJXZWIiLCJ6ZW5kZXNrU3ViZG9tYWluIjoic25pcGVzc3VwcG9ydCIsImJhc2VzdG9yZVVybCI6IiJ9"
    }
    has_download_delay = True

    def start_requests(self):
        for category in self.categories.keys():
            querystring = {"page": 1, "perPage": 24}
            urlencoded_query = urlencode(querystring)

            yield scrapy.Request(
                url=f"{self.url}{category}?{urlencoded_query}",
                callback=self.parse,
                headers=self.headers,
                meta={"category": category, "querystring": querystring}
            ) 
    
    def parse(self, response: HtmlResponse):
        data = response.json()
        products = data["products"]

        for product in products:
            item = SnipesItem()
            product_id = product["id"]
            item["brand"] = product["attributes"]["brand"]["values"]["label"]
            item["category"] = self.categories[
                response.meta["category"]
            ][0]
            item["gender"] = self.categories[
                response.meta["category"]
            ][1]
            item["image_url"] = (
                product["images"][0]["public_id"],
                product["url"]
            )
            item["original_price"] = product["wasPrice"]
            item["price"] = product["formattedPrice"]

            if item["original_price"] is None:
                item["original_price"] = item["price"]
            
            item["sku"] = product["attributes"]["manufacturerCode"]["values"]["label"]
            item["title"] = product["displayName"]
            item["url"] = product["url"]

            yield scrapy.Request(
                url=f"https://api.snipes.com/sni-pl-prd-stor-we-char/v1/v1/products/{product_id}",
                headers=self.headers,
                callback=self.parse_product,
                meta={"item": item}
            ) 
        
        if response.meta["querystring"]["page"] < data["pagination"]["totalPages"]:
            querystring = response.meta["querystring"]
            querystring["page"] += 1
            category = response.meta["category"]

            urlencoded_query = urlencode(querystring)
            yield scrapy.Request(
                url=f"{self.url}{category}?{urlencoded_query}",
                callback=self.parse,
                headers=self.headers,
                meta={"category": category, "querystring": querystring}
            )
    
    def parse_product(self, response: HtmlResponse):
        data = response.json()
        item = response.meta["item"]
        item["variants"] = data["variants"]
        yield item 