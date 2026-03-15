import logging 
from enum import Enum
from typing import Optional
from urllib.parse import quote

from config import SOVRN_API_KEY, AWIN_PUBLISHER_ID

logger = logging.getLogger(__name__)

class AffiliateNetwork(Enum):
    SOVRN = "sovrn"
    AWIN = "awin"
    NONE = "none"

# Affiliate program configuration for each merchant
# Format: merchant_name -> (network, merchant_id or None)
AFFILIATE_PROGRAMS: dict[str, tuple[AffiliateNetwork, Optional[str]]] = {
    "Birkenstock": (AffiliateNetwork.SOVRN, None),
    "BSTN": (AffiliateNetwork.AWIN, "104981"),
    "CisalfaSport": (AffiliateNetwork.SOVRN, None),
    "Deliberti": (AffiliateNetwork.SOVRN, None),
    "EndClothing": (AffiliateNetwork.NONE, None),
    "FootPatrol": (AffiliateNetwork.AWIN, "18937"),
    "JDSports": (AffiliateNetwork.SOVRN, None),
    "MaxiSport": (AffiliateNetwork.SOVRN, None),
    "Nike": (AffiliateNetwork.AWIN, "16337"),
    "OutletAsics": (AffiliateNetwork.SOVRN, None),
    "Prm": (AffiliateNetwork.SOVRN, None),
    "Snipes": (AffiliateNetwork.SOVRN, None),
}

def create_affiliate_link(url: str, source: str) -> str:
    program = AFFILIATE_PROGRAMS.get(source)
    
    if program is None:
        logger.warning(f"Unknown merchant: {source}. Returning original URL.")
        return url
    
    network, merchant_id = program
    
    if network == AffiliateNetwork.NONE:
        return url
    
    encoded_url = quote(url, safe='')
    
    if network == AffiliateNetwork.SOVRN:
        return _create_sovrn_link(url, encoded_url)
    
    if network == AffiliateNetwork.AWIN:
        return _create_awin_link(url, encoded_url, merchant_id)
    
    logger.warning(f"Unknown network type: {network}. Returning original URL.")
    return url

def _create_sovrn_link(original_url: str, encoded_url: str) -> str:
    if not SOVRN_API_KEY:
        logger.warning("SOVRN_API_KEY is not set. Returning original URL.")
        return original_url
    
    return f"https://redirect.viglink.com?u={encoded_url}&key={SOVRN_API_KEY}"

def _create_awin_link(
    original_url: str, 
    encoded_url: str, 
    merchant_id: Optional[str]
) -> str:
    if not AWIN_PUBLISHER_ID:
        logger.warning("AWIN_PUBLISHER_ID is not set. Returning original URL.")
        return original_url
    
    if not merchant_id:
        logger.warning("Awin merchant ID not configured. Returning original URL.")
        return original_url
    
    return (
        f"https://www.awin1.com/cread.php"
        f"?awinmid={merchant_id}"
        f"&awinaffid={AWIN_PUBLISHER_ID}"
        f"&ued={encoded_url}"
    )

def get_supported_merchants() -> list[str]:
    return list(
        AFFILIATE_PROGRAMS.keys()
    )

def has_affiliate_program(source: str) -> bool:
    program = AFFILIATE_PROGRAMS.get(source)

    if program is None:
        return False
    
    return program[0] != AffiliateNetwork.NONE