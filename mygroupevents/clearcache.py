from django.conf import settings

# obviously change CACHES to your settings
CACHES = {
	'default': {
		'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
		'LOCATION': 'unique-snowflake'
		 }
	}

settings.configure(CACHES=CACHES) # include any other settings you might need

from django.core.cache import cache
cache.clear()

