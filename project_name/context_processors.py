import os
from django.conf import settings

def static(request):
    "Shorthand static URLs. In debug mode, the JavaScript is not minified."
    static_url = settings.STATIC_URL
    prefix = 'src' if settings.DEBUG else 'min'
    return {
        'CSS_URL': os.path.join(static_url, 'stylesheets/css'),
        'IMAGES_URL': os.path.join(static_url, 'images'),
        'JAVASCRIPT_URL': os.path.join(static_url, 'scripts/javascript', prefix),
    }
