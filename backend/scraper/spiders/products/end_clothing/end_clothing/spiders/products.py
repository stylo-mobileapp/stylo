import scrapy 
from scrapy.http import HtmlResponse 
from ..items import EndClothingItem
from urllib.parse import urlencode
from json import dumps 


class EndClothingSpider(scrapy.Spider):
    name = "EndClothing"
    url = "https://search1web.endclothing.com/1/indexes/*/queries"
    querystring = {
        "x-algolia-agent": "Algolia for JavaScript (5.23.4); Search (5.23.4); Browser",
        "x-algolia-api-key": "dfa5df098f8d677dd2105ece472a44f8",
        "x-algolia-application-id": "KO4W2GBINK"
    }
    headers = {
        "accept": "application/json",
        "Content-Type": "application/json",
        "Referer": "https://www.endclothing.com/",
        "sec-ch-ua-mobile": "?0",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36"
    }
    categories = {
        "clothing": "Apparel",
        "footwear": "Footwear",
    }
    genders = {
        "Men - N/A": "Men",
        "Women": "Women",
    }

    def start_requests(self):
        for category in self.categories.keys():
            for gender in self.genders.keys():
                page = 0
                payload = self._create_payload(page, category, gender)
                urlencoded_query = urlencode(self.querystring)

                yield scrapy.Request(
                    url=f"{self.url}?{urlencoded_query}",
                    method="POST",
                    body=dumps(payload),
                    headers=self.headers,
                    callback=self.parse,
                    meta={"page": page, "category": category, "gender": gender},
                )  
    
    def parse(self, response: HtmlResponse):
        data = response.json()
        products: list[dict] = data["results"][0]["hits"]

        for product in products:
            item = EndClothingItem()
            item["brand"] = product["brand"]
            item["category"] = self.categories[
                response.meta["category"]
            ]
            item["gender"] = self.genders[
                response.meta["gender"]
            ]
            item["image_url"] = product["media_gallery"]
            item["original_price"] = product["full_price_3"]
            item["price"] = product["final_price_3"]
            item["sku"] = product["sku"]
            item["title"] = product["name"]
            item["url"] = product["url_key"]

            try:
                item["variants"] = (
                    product["size"],
                    item["price"],
                )
            except KeyError:
                continue

            yield item 
        
        if response.meta["page"] < data["results"][0]["nbPages"]:
            next_page = response.meta["page"] + 1
            category, gender = response.meta["category"], response.meta["gender"]
            payload = self._create_payload(next_page, category, gender)
            urlencoded_query = urlencode(self.querystring)

            yield scrapy.Request(
                url=f"{self.url}?{urlencoded_query}",
                method="POST",
                body=dumps(payload),
                headers=self.headers,
                callback=self.parse,
                meta={"page": next_page, "category": category, "gender": gender},
            )  

    def _create_payload(self, page: int, category: str, gender: str) -> dict:
        tag = f"{gender}_{category}".lower() if "N/A" not in gender else category

        return {
            "requests": [
                {
                    "indexName": "Catalog_products_v3_gb_products",
                    "userToken": "anonymous-8423648d-5dea-49c4-b33d-b6691b83a599",
                    "analyticsTags": ["browse", "web", "v3", "it", "IT", tag],
                    "page": page,
                    "facetFilters": [
                        [f"categories:{gender} / {category}" if "N/A" not in gender else f"categories:{category}"], ["websites_available_at:3"]
                    ],
                    "filters": "",
                    "facets": ["*"],
                    "hitsPerPage": 120,
                    "ruleContexts": ["browse", "web", "v3", "it", "IT", tag],
                    "clickAnalytics": True
                }
            ]
        }