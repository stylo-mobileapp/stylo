import scrapy 
from scrapy.http import HtmlResponse 
from ..items import BstnItem
from urllib.parse import urlencode
from json import dumps 


class BstnSpider(scrapy.Spider):
    name = "BSTN"
    url = "https://searcht.bstn.com/multi_search"
    querystring = {"x-typesense-api-key": "NCZstZEMLnMy4MSLPh9NKNrtMLsEF1Zy"}
    categories = ["footwear", "apparel"]
    genders = ["men", "women", "kids"]
   
    def start_requests(self):
        for category in self.categories:
            for gender in self.genders:
                page = 1
                payload = self._create_payload(page, category, gender)
                urlencoded_query = urlencode(self.querystring)

                yield scrapy.Request(
                    url=f"{self.url}?{urlencoded_query}",
                    method="POST",
                    body=dumps(payload),
                    callback=self.parse,
                    meta={"total_products": 0, "category": category, "gender": gender, "page": page},
                )
    
    def parse(self, response: HtmlResponse):
        data = response.json()
        products = data["results"][0]["hits"]

        for product in products:
            item = BstnItem()
            doc: dict = product["document"]
            item["brand"] = doc["brand"]
            item["category"] = response.meta["category"]
            item["gender"] = response.meta["gender"]
            item["image_url"] = doc["image_url"]

            try:
                item["original_price"] = doc["price"]["EUR"]["default_original_formated"]
            except KeyError:
                item["original_price"] = doc["price"]["EUR"]["default_formated"]
            
            item["price"] = doc["price"]["EUR"]["default_formated"]
            item["sku"] = doc["article_number"]
            item["title"] = doc["name"]
            item["url"] = doc["url"]

            swatches_conf: dict = doc["swatches_conf"]

            try:
                first_key = list(
                    swatches_conf.keys()
                )[0]
            except AttributeError:
                continue

            item["variants"] = (
                swatches_conf[first_key]["items"],
                item["price"]
            )

            yield item 
        
        response.meta["total_products"] += len(products)
        
        if response.meta["total_products"] < data["results"][0]["found"]:
            next_page = response.meta["page"] + 1
            payload = self._create_payload(
                next_page, response.meta["category"], response.meta["gender"]
            )
            urlencoded_query = urlencode(self.querystring)

            yield scrapy.Request(
                url=f"{self.url}?{urlencoded_query}",
                method="POST",
                body=dumps(payload),
                callback=self.parse,
                meta={"total_products": response.meta["total_products"], "category": response.meta["category"], "gender": response.meta["gender"], "page": next_page},
            )

    def _create_payload(self, page: int, category: str, gender: str):
        return {
            "searches": [
                {
                    "highlight_full_fields": "categories_it,color_it,group_it,name,sku,categories,color,article_number,brand,brand_color,gender,bstn_collection,is_sustainable,raffle_is_active,group,first_discount_date,created_timestamp_string,first_discount_date,further_reduced,teamsport,silhouette_type,season",
                    "query_by": "categories_it,color_it,group_it,name,sku,categories,color,article_number,brand,brand_color,gender,bstn_collection,is_sustainable,raffle_is_active,group,first_discount_date,created_timestamp_string,first_discount_date,further_reduced,teamsport,silhouette_type,season",
                    "sort_by": "bestseller:desc,first_release_date:desc",
                    "max_facet_values": 9999,
                    "per_page": 96,
                    "collection": "magento2_eu_products",
                    "q": "*",
                    "facet_by": "brand,bstn_collection,categories.level2,color,group,groupextra,is_sustainable,price.EUR.default,raffle,raffle_is_active,sale,season,silhouette_type,sizeaccessory_conf,sizeapparel,sizefootwear_conf.level1,teamsport",
                    "filter_by": f"categories.level0:[`{gender}`] && raffle_is_expired_numeric:[0] && visibility_catalog:[1] && categories.level1:[`{gender} /// {category}`]",
                    "page": page
                }
            ]
        }