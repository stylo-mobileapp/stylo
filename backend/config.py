import os 
from dotenv import load_dotenv


load_dotenv()

# Supabase settings
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")

# Affiliate settings
SOVRN_API_KEY = os.getenv("SOVRN_API_KEY", "")

AWIN_PUBLISHER_ID = os.getenv("AWIN_PUBLISHER_ID", "")

# AI services
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

# Paths
BASE_DIR = os.path.dirname(
    p=os.path.abspath(__file__)
)
DATA_DIR = os.path.join(BASE_DIR, "data")

# Spider categories
SPIDER_CATEGORIES = ["products", "banners"]