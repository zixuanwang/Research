from django import template
register = template.Library()

@register.filter
def dictKey(h, key):
    return h[key]
