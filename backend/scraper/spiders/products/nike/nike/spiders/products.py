import scrapy
from scrapy.http import HtmlResponse 
from ..items import NikeItem
from urllib.parse import urlencode


class NikeSpider(scrapy.Spider):
    name = "Nike"
    url = "https://api.nike.com/discover/product_wall/v1/marketplace/IT/language/it/consumerChannelId/d9a5bc42-4b9c-4976-858a-f159cf99c647"
    categories = {
        "/it/w/uomo-scarpe-nik1zy7ok": ["Footwear", "Men", "16633190-45e5-4830-a068-232ac7aea82c,0f64ecc7-d624-4e91-b171-b83a03dd8550"],
        "/it/w/uomo-abbigliamento-6ymx6znik1": ["Apparel", "Men", "a00f0bb2-648b-4853-9559-4cd943b7d6c6,0f64ecc7-d624-4e91-b171-b83a03dd8550"],
        "/it/w/donna-scarpe-5e1x6zy7ok": ["Footwear", "Women", "16633190-45e5-4830-a068-232ac7aea82c,7baf216c-acc6-4452-9e07-39c2ca77ba32"],
        "/it/w/donna-abbigliamento-5e1x6z6ymx6": ["Apparel", "Women", "a00f0bb2-648b-4853-9559-4cd943b7d6c6,7baf216c-acc6-4452-9e07-39c2ca77ba32"],
        "/it/w/kids-scarpe-v4dhzy7ok": ["Footwear", "Kids", "16633190-45e5-4830-a068-232ac7aea82c,145ce13c-5740-49bd-b2fd-0f67214765b3"],
        "/it/w/kids-abbigliamento-6ymx6zv4dh": ["Apparel", "Kids", "145ce13c-5740-49bd-b2fd-0f67214765b3,a00f0bb2-648b-4853-9559-4cd943b7d6c6"]
    } 
    headers = {
        "accept": "*/*",
        "accept-language": "it-IT,it;q=0.9,en-US;q=0.8,en;q=0.7",
        "anonymousid": "C1BC2A97076674E532287CAECFB276D4",
        "Cookie": "anonymousId=C1BC2A97076674E532287CAECFB276D4; AnalysisUserId=e4f93561-1545-4abf-9930-1f3c30ac730a; s_ecid=MCMID%7C51860906401517951230904116211884545541; AMCV_F0935E09512D2C270A490D4D%40AdobeOrg=1994364360%7CMCMID%7C51860906401517951230904116211884545541%7CMCAID%7CNONE%7CMCOPTOUT-1723032950s%7CNONE%7CvVersion%7C3.4.0; CONSUMERCHOICE=it/it-it; NIKE_COMMERCE_COUNTRY=IT; NIKE_COMMERCE_LANG_LOCALE=it-IT; ni_d=CC978D74-281E-451A-aFE9-BCDAD10DDFEA; _fbp=fb.1.1727192360893.482616870868; _scid=S3OXVuDt1RG7s2gAdtBg11-IU9ARygGv; FPID=FPID2.2.h0005bfybmmo9h5CTcIc4XV%2Bp%2BZRO%2FTQBWHk0NnCgv4%3D.1727192361; _pin_unauth=dWlkPU1qQmtaakZqTVRjdE1UWTVNaTAwTkdJNExUaGtOakl0WW1JM05HSmtNV014TmpBNQ; ni_c=1PA=1|BEAD=1|PERF=1|PERS=1; _abck=771E2D99F4F95F266ED9F7348D09F97F~-1~YAAQij4WArkfRyCSAQAAEvyvJAx1kpYYiyNUt09O5ph6IHbrioONW4f/mA02TwCzwg+V+NhCcX+gf8hz6sqoODMdPtaninDDFKzd/aEKU6uZL0G0lxAwFCg92UrfaIFxjzLs30W1erFNMQK4MU8Xt4XWrbz0dedahhGw9b5Dzf10SDBeHkzFA4BFTrRBTxPync1EvYmFwt9NHVp2mXsOIYSsOStLuyNnAG6LSxg1k9awlG5Y6tm7WpQicxHNYLbPDW1mrm/6SjLMOGLAdVm84sNNlhqNqeKxSTXvpIqyOh3AOuHPUwWoC2NHH/LjOJ2grFtDqFvmgdmrRbxeduyMEZel2+yFj3K2VnY7BdssJicdP9CjpjU34/bGMgffDSLnD0J2mNrxqQWHLgY1/q5SKzJhpA9jGWyx3+LzK+qgKiBgEztilVHKPcGDu0E0b7U3XQh8ES0E2UJZq3CDy6PYtWTpiGyOpytgDa0xbStQRr5Y1kukjy27yCzOkgk0H/syvO5sT/OwTT0y8tg665Jp~-1~-1~-1; bc_nike_great_britain_triggermail=%7B%22distinct_id%22%3A%20%22195675f587517b-0647ef82b12951-1c525636-13c680-195675f5876d15%22%2C%22bc_persist_updated%22%3A%201741196056695%7D; _tt_enable_cookie=1; _ttp=01JNQX9JDFC963ASNA94PJ9693_.tt.1; bc_nike_italy_triggermail=%7B%22distinct_id%22%3A%20%22195675f587517b-0647ef82b12951-1c525636-13c680-195675f5876d15%22%2C%22bc_persist_updated%22%3A%201741338905475%2C%22g_search_engine%22%3A%20%22google%22%7D; bc_nike_romania_triggermail=%7B%22distinct_id%22%3A%20%22195675f587517b-0647ef82b12951-1c525636-13c680-195675f5876d15%22%2C%22bc_persist_updated%22%3A%201741563754891%2C%22g_search_engine%22%3A%20%22google%22%7D; _gcl_au=1.1.1579587902.1744054874; FPAU=1.1.1579587902.1744054874; _rdt_uuid=1748793229584.62ffc2ae-4324-4e9b-92f7-063852f08c1d; lantern=1f28b5ea-d706-4e42-86da-f1fa368738f0; _ScCbts=%5B%5D; geoloc=cc=IT,rc=,tp=vhigh,tz=GMT+1,la=45.47,lo=9.20; at_check=true; AKA_A2=A; ak_bmsc=003E5C47884516A7BAF2809C24CD97B5~000000000000000000000000000000~YAAQHQwVArqq5i6XAQAAunS4SRwjVYQjmTgGEBQzC2qasNNbN/+ZsTrKb9Z9VdD0y67r3B5cJQ6mDFFn//LlDh/w06KQ3zcjevIUvs+0WUCSAhWFa2t5lYfxj5ohTVwgA9xj+4QoEda5SCdHwWjTPWYSxCavd6IzDofnKyqA6ACdsRjYre7SADUDBS/sxyN7caD9yx+tPLZDEORfe1MQMWAgIKKOmkVxLOZtCP7hw0IrX4y4PN9xmX+ao3j8BdbP/qBSSRbDnr2Edg2IfEEQAKjsyNZlx5qKJztNYGJMEQ1itHBrn9FvyPvg8poU9mgpVCC57PAm947HXC6GFEMXdY44HTaM44kUNEq2Ksu9uBJtCfADukwMuPlir6bFlLb1Zn/+LTFfEg==; forterToken=aed97da7a98848de9bb2408e4170eef0_1749288515190__UDF43-m4_11ck; mboxEdgeCluster=37; sq=3; kndctr_F0935E09512D2C270A490D4D_AdobeOrg_cluster=irl1; kndctr_F0935E09512D2C270A490D4D_AdobeOrg_identity=CiY1MTg2MDkwNjQwMTUxNzk1MTIzMDkwNDExNjIxMTg4NDU0NTU0MVIRCOaq%5FbrWMhgBKgRJUkwxMAPwAe6S4s30Mg%3D%3D; ni_cs=e58753f8-eb20-4915-a227-d81b54919e90; _gcl_gs=2.1.k1$i1749288518$u239889820; KP_UIDz-ssn=02ksJw0Rjc8dWUIbhzeCi25qR3PrG8nC8FjQJXzRkbdZkIGLYjUGna74RLdJemhk6FHl5VJ1Wtoebd9QIJOEI7MQKeF1sV30Dqzi23QzeZ3HHYinjYzcMfMenqT7ETgsGaqDPtjh8BUW0dL555UA92Di13dBhzKfG9Tuyc; KP_UIDz=02ksJw0Rjc8dWUIbhzeCi25qR3PrG8nC8FjQJXzRkbdZkIGLYjUGna74RLdJemhk6FHl5VJ1Wtoebd9QIJOEI7MQKeF1sV30Dqzi23QzeZ3HHYinjYzcMfMenqT7ETgsGaqDPtjh8BUW0dL555UA92Di13dBhzKfG9Tuyc; _gid=GA1.2.1193520457.1749288520; FPLC=4ZycNVlNG%2BoDx6AmS9oh8adKefrCKnRR%2Bg5O%2Fz6OCcupZ%2FBvl8a3I9mTPpMbi20JIRXJgtS50hNY3Ewq6Rkz9a3HwrpNoeIlImZBIb1ojziPL9OJAbKHevVAohneYQ%3D%3D; FPGCLGS=2.1.k1$i1749288518$u239889820; _clck=ohmp33%7C2%7Cfwk%7C0%7C1808; _gcl_aw=GCL.1749288542.Cj0KCQjwxo_CBhDbARIsADWpDH4MQC6WhF14a_EDsCkhgjNmymNNYPS4JklSpTkK1Ap1E3PE6NYizXkaAkbDEALw_wcB; _gcl_dc=GCL.1749288542.Cj0KCQjwxo_CBhDbARIsADWpDH4MQC6WhF14a_EDsCkhgjNmymNNYPS4JklSpTkK1Ap1E3PE6NYizXkaAkbDEALw_wcB; _gac_UA-167630499-3=1.1749288542.Cj0KCQjwxo_CBhDbARIsADWpDH4MQC6WhF14a_EDsCkhgjNmymNNYPS4JklSpTkK1Ap1E3PE6NYizXkaAkbDEALw_wcB; FPGCLAW=2.1.kCj0KCQjwxo_CBhDbARIsADWpDH4MQC6WhF14a_EDsCkhgjNmymNNYPS4JklSpTkK1Ap1E3PE6NYizXkaAkbDEALw_wcB$i1749288547; FPGCLDC=2.1.kCj0KCQjwxo_CBhDbARIsADWpDH4MQC6WhF14a_EDsCkhgjNmymNNYPS4JklSpTkK1Ap1E3PE6NYizXkaAkbDEALw_wcB$i1749288547; EU_COOKIE_LAW_CONSENT=true; EU_COOKIE_LAW_CONSENT_legacy=true; styliticsWidgetSession=78361317-bcf4-49b4-8d3c-d8f3c2dc1d96; pixlee_analytics_cookie=%7B%22CURRENT_PIXLEE_USER_ID%22%3A%226a39d00b-b91f-927c-a3fb-64e0f6775b2a%22%7D; pixlee_analytics_cookie_legacy=%7B%22CURRENT_PIXLEE_USER_ID%22%3A%226a39d00b-b91f-927c-a3fb-64e0f6775b2a%22%2C%22TIME_SPENT%22%3A3%7D; _gat_UA-167630499-3=1; ppd=pw|nikecom>pw>shoes; FPGSID=1.1749288520.1749289055.G-QTVTHYLBQS.3n8zB6JYUlMgME4uwCX73Q; mbox=session%23bf4b7ee53da648caafe059cc7d19a1cd%231749290942%7CPC%231a1aa230ed4a4b2ca33cddf4f4b866f4%2E37%5F0%231812533373; _ga_QTVTHYLBQS=GS2.1.s1749288520$o15$g1$t1749289082$j6$l0$h707882721; _ga_EWJ8FE8V0B=GS2.1.s1749288520$o15$g1$t1749289082$j6$l0$h0; _ga=GA1.2.1661648056.1727192361; _scid_r=W_OXVuDt1RG7s2gAdtBg11-IU9ARygGvMch9aA; _uetsid=cc434f40438111f0b1e071c3524037f2; _uetvid=2b139a507a8b11ef8dd225b892359247; ttcsid=1749288520447::ZJCKw-GyI9ki9PwT7lg6.7.1749289082663; bm_sv=72B22113B1C7C2BB2C4171361F5C785B~YAAQvAwVAtya4i+XAQAALCDBSRw1fmaw2eP1HW4igXWfUdkfqtQJguMqgdByBEAeymC/1pvvGmdr/CdxMf16rtfZr1po6BxfI+wYvumbb9+DJY1/K8BNIVH9Q7YirtHFoWeEnQFtq/+fQahr7UrWZrCZVh4apFdZlfqk+qCY3YxjJ+L8ZD3EpyuurEMcZnkkrSHAEvF28J9jLmGWIGMk3AObnYO1NS/R0bh65yY6jsjVxlTERpD9ANbosDcxKlma~1; ttcsid_CU95O3RC77U5D2GJASTG=1749288520447::dpZsZgMBL3c_u_2s7cwx.7.1749289082903; _clsk=wsvs6t%7C1749289083080%7C27%7C0%7Ci.clarity.ms%2Fcollect",
        "nike-api-caller-id": "nike:dotcom:browse:wall.client:2.0",
        "origin": "https://www.nike.com",
        "priority": "u=1, i",
        "referer": "https://www.nike.com/",
        "sec-ch-ua": '"Google Chrome";v="137", "Chromium";v="137", "Not/A)Brand";v="24"',
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": '"macOS"',
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-site",
        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36"
    }

    def start_requests(self):
        for category, v in self.categories.items():
            querystring = {
                "path": category,
                "attributeIds": v[2],
                "queryType": "PRODUCTS",
                "anchor": 0,
                "count": 24,
            } 
            urlencoded_query = urlencode(querystring)

            yield scrapy.Request(
                url=f"{self.url}?{urlencoded_query}",
                headers=self.headers,
                callback=self.parse,
                meta={
                    "total_products": 0,
                    "querystring": querystring,
                    "category": category,
                }
            )

    def parse(self, response: HtmlResponse):
        data = response.json()
        products = data["productGroupings"]

        if products is not None:
            for product in products:
                if product["products"] is None:
                    continue

                for value in product["products"]:
                    item = NikeItem()
                    item["brand"] = "Nike"
                    item["category"] = self.categories[
                        response.meta["category"]
                    ][0]
                    item["gender"] = self.categories[
                        response.meta["category"]
                    ][1]
                    item["image_url"] = value["colorwayImages"]["portraitURL"]
                    item["original_price"] = value["prices"]["initialPrice"]
                    item["price"] = value["prices"]["currentPrice"]
                    item["sku"] = value["productCode"]
                    item["title"] = value["copy"]["title"]
                    item["url"] = value["pdpUrl"]["url"]
                    group_key = value["groupKey"]

                    yield scrapy.Request(
                        url=f"https://api.nike.com/discover/product_details_availability/v1/marketplace/IT/language/it/consumerChannelId/d9a5bc42-4b9c-4976-858a-f159cf99c647/groupKey/{group_key}",
                        callback=self.parse_product,
                        headers=self.headers,
                        meta={"item": item},
                    )
        
        response.meta["total_products"] += len(products)
        
        if response.meta["total_products"] < data["pages"]["totalResources"]:
            querystring = response.meta["querystring"]
            querystring["anchor"] += 24
            urlencoded_query = urlencode(querystring)

            yield scrapy.Request(
                url=f"{self.url}?{urlencoded_query}",
                headers=self.headers,
                callback=self.parse,
                meta={
                    "total_products": response.meta["total_products"],
                    "querystring": querystring,
                    "category": response.meta["category"],
                }
            )
    
    def parse_product(self, response: HtmlResponse):
        item = response.meta["item"]
        data = response.json()
        item["variants"] = [
            data["sizes"], item["price"], item["sku"],
        ]
        yield item 