"""
Django settings for spreadr project for selenium tests with gistr.
"""

# Import default settings
from spreadr.settings import *  # noqa

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'spreadr_gistr_test',
        'TEST': {'CHARSET': 'utf8'}
    }
}
