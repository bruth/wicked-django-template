from django.conf.urls import url, patterns, include
from django.contrib import admin
from django.views.generic import TemplateView

admin.autodiscover()

urlpatterns = patterns(
    '',

    url(r'^$', TemplateView.as_view(template_name='index.html')),

    # Administrative components
    url(r'^admin/', include(admin.site.urls)),
)
