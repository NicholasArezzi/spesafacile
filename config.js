const APP_CONFIG = {
  // OCR
  OCR_API_KEY:    'helloworld',
  OCR_API_URL:    'https://api.ocr.space/parse/image',
  OCR_LANGUAGE:   'ita',

  // API Geolocation
  IP_GEO_URL:     'https://ipwho.is/',
  NOMINATIM_URL:  'https://nominatim.openstreetmap.org/reverse',
  OVERPASS_URL:   'https://overpass-api.de/api/interpreter',

  // Mappa
  TILE_URL:         'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  MAP_CENTER:       [41.9, 12.5],
  MAP_ZOOM_DEFAULT: 6,
  MAP_ZOOM_USER:    15,
  MAP_MAX_ZOOM:     19,
  MAP_MIN_ZOOM:     5,

  // Fallback GPS (Genova — usato come fallback principale)
  FALLBACK_LAT: 44.4056,
  FALLBACK_LNG: 8.9463,

  // Fallback GPS (Italia centrale — usato come fallback mappa)
  FALLBACK_LAT_ITALY: 41.9028,
  FALLBACK_LNG_ITALY: 12.4964,

  // Geolocation timeouts (ms)
  GEO_TIMEOUT_FAST: 8000,
  GEO_TIMEOUT_SLOW: 15000,
  GEO_MAX_AGE:      60000,

  // Ricerca negozi
  SHOP_RADIUS_M:      3000,
  OVERPASS_TIMEOUT_S: 25,

  // Offerte
  OFFERS_COUNT: 12,

  // Soglie badge
  BADGE_LISTE:       1,
  BADGE_SCONTRINI_1: 1,
  BADGE_RICETTE:     1,
  BADGE_SCONTRINI_5: 5,
  BADGE_RISPARMIO:   50,

  // LocalStorage
  STORAGE_USER: 'sf_user',

  // Timing UI (ms)
  MAP_INVALIDATE_DELAY: 200,
  MAP_VIEW_DELAY:       150,
};
