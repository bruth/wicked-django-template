from django.conf import settings

def static(request):
    """Provides a context variable that differentiates between the base
    JavaScript URL when in debug mode vs. not.
    """
    CSS_URL = '{}stylesheets/css/'.format(settings.STATIC_URL)    
    JAVASCRIPT_URL = '{}scripts/javascript/'.format(settings.STATIC_URL)

    if settings.DEBUG:
        JAVASCRIPT_URL += 'src/'
    else:
        JAVASCRIPT_URL += 'min/'

    return {
        'CSS_URL': CSS_URL,    
        'JAVASCRIPT_URL': JAVASCRIPT_URL,
    }
