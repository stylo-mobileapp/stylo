import importlib
import os 
import sys 

from scrapy.crawler import CrawlerRunner
from scrapy.utils.log import configure_logging
from scrapy import Spider
from twisted.internet import defer, reactor
from twisted.internet import reactor as real_reactor
from twisted.internet.interfaces import IReactorCore

from config import DATA_DIR

reactor: IReactorCore = real_reactor


def run_spiders(category: str, target_file: str) -> None:
    base_path = os.path.dirname(
        p=os.path.abspath(__file__)
    )
    spiders_path = os.path.join(base_path, "spiders", category)
    output_path = os.path.join(DATA_DIR, category)

    # Ensure output directory exists
    os.makedirs(output_path, exist_ok=True)

    spiders = import_spiders(spiders_path, target_file)

    if not spiders:
        print(f"No spiders found in {spiders_path}")
        return
    
    configure_logging()
    deferred = crawl(spiders, output_path)
    deferred.addBoth(
        lambda _: reactor.stop()
    )
    reactor.run()

def import_spiders(path: str, target_file: str) -> list[Spider]:
    spiders = []
    
    if not os.path.exists(path):
        print(f"Path does not exist: {path}")
        return spiders

    sys.path.insert(0, path)

    for folder in sorted(os.listdir(path)):
        folder_path = os.path.join(path, folder)
        
        # Skip non-directories and hidden folders
        if not os.path.isdir(folder_path) or folder.startswith('.') or folder == 'data':
            continue

        # Build module path: folder.folder.spiders.target_file
        module_name = f"{folder}.{folder}.spiders.{target_file}"

        try:
            module = importlib.import_module(module_name)
        except ModuleNotFoundError as e:
            print(f"Could not import {module_name}: {e}")
            continue
        except Exception as e:
            print(f"Error importing {module_name}: {e}")
            continue

        class_name = "".join(
            part.capitalize() for part in folder.split("_")
        ) + "Spider"

        try:
            spider_class = getattr(module, class_name)
            spiders.append(spider_class)
            print(f"Loaded: {class_name}")
        except AttributeError:
            print(f"Spider class {class_name} not found in {module_name}")
            continue
    
    return spiders

@defer.inlineCallbacks
def crawl(spiders: list[Spider], output_path: str):
    runner = CrawlerRunner()
    
    for spider in spiders:
        # Configure feed output for this spider
        runner.settings = {
            "LOG_LEVEL": "INFO",
            "FEEDS": {
                f"{output_path}/{spider.name}.csv": {
                    "format": "csv",
                    "overwrite": True,
                }
            }
        }
        
        # Configure download delay if spider has the attribute
        delay = 0
        if getattr(spider, "has_download_delay", False):
            delay = 1 if getattr(spider, "has_greater_delay", False) else 0.3
        runner.settings["DOWNLOAD_DELAY"] = delay
        
        print(f"Running spider: {spider.name}")
        yield runner.crawl(spider)
        print(f"Completed: {spider.name}")