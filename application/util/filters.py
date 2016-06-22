from application import app


@app.template_filter('available_assets')
def available(assets):
    if type(assets) is not list:
        raise TypeError('Argument assets is not a list')
    result = 0
    for a in assets:
        if a.available:
            result += 1
    return result
