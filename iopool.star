"""
Applet: iopool Spa
Summary: Display spa water quality
Description: Shows temperature, pH, and ORP readings from your iopool EcO monitor.
Author: iopooltidbyt
"""

load("cache.star", "cache")
load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")

IOPOOL_API_URL = "https://api.iopool.com/v1"
CACHE_TTL = 300  # 5 minutes
LAST_DATA_TTL = 86400  # 24 hours for fallback data

DEFAULT_POOL_DATA = {
    "title": "My Spa",
    "latestMeasure": {
        "temperature": 38.5,
        "ph": 7.2,
        "orp": 650,
        "isValid": True,
    },
}

def main(config):
    api_key = config.get("api_key", "")
    pool_id = config.get("pool_id", "")

    if not api_key or not pool_id:
        return render_error("Configure API key and Pool ID")

    pool_data, is_stale = get_pool_data(api_key, pool_id)

    if pool_data == None:
        return render_error("Failed to fetch data")

    return render_display(pool_data, is_stale)

def get_pool_data(api_key, pool_id):
    cache_key = "iopool_{}".format(pool_id)
    last_data_key = "iopool_last_{}".format(pool_id)
    cached = cache.get(cache_key)

    if cached:
        return json.decode(cached), False

    # Cache expired or not present, try to fetch fresh data
    url = "{}/pool/{}".format(IOPOOL_API_URL, pool_id)
    headers = {
        "x-api-key": api_key,
    }

    response = http.get(url, headers = headers)

    if response.status_code == 200:
        data = response.json()
        # Cache fresh data with normal TTL
        cache.set(cache_key, json.encode(data), ttl_seconds = CACHE_TTL)
        # Also cache as last known good data with longer TTL
        cache.set(last_data_key, json.encode(data), ttl_seconds = LAST_DATA_TTL)
        return data, False

    # API failed, try to use last known good data
    print("iopool API error: {}, trying last known data".format(response.status_code))
    last_data = cache.get(last_data_key)

    if last_data:
        return json.decode(last_data), True

    # No data available at all
    return None, False

def render_display(pool_data, is_stale = False):
    title = pool_data.get("title", "Spa")
    measure = pool_data.get("latestMeasure", {})

    temp = measure.get("temperature", 0)
    ph = measure.get("ph", 0)
    orp = measure.get("orp", 0)

    # Determine colors based on values
    temp_color = get_temp_color(temp)
    ph_color = get_ph_color(ph)
    orp_color = get_orp_color(orp)

    # Dim title color when showing stale data
    title_color = "#666" if is_stale else "#4fc3f7"

    # Build title row with optional stale indicator
    title_children = []
    if is_stale:
        title_children.append(
            render.Box(
                width = 3,
                height = 3,
                color = "#ff9800",
            ),
        )
        title_children.append(render.Box(width = 2, height = 1))  # spacer
    title_children.append(
        render.Text(
            content = title[:10] if not is_stale else title[:8],
            font = "tom-thumb",
            color = title_color,
        ),
    )

    return render.Root(
        child = render.Box(
            padding = 1,
            child = render.Column(
                expanded = True,
                main_align = "space_between",
                children = [
                    # Title row
                    render.Row(
                        expanded = True,
                        main_align = "center",
                        children = title_children,
                    ),
                    # Temperature row
                    render.Row(
                        expanded = True,
                        main_align = "space_between",
                        children = [
                            render.Text(
                                content = "TEMP",
                                font = "tom-thumb",
                                color = "#888",
                            ),
                            render.Text(
                                content = "{:.1f}C".format(temp),
                                font = "6x13",
                                color = temp_color,
                            ),
                        ],
                    ),
                    # pH row
                    render.Row(
                        expanded = True,
                        main_align = "space_between",
                        children = [
                            render.Text(
                                content = "pH",
                                font = "tom-thumb",
                                color = "#888",
                            ),
                            render.Text(
                                content = "{:.1f}".format(ph),
                                font = "6x13",
                                color = ph_color,
                            ),
                        ],
                    ),
                    # ORP row
                    render.Row(
                        expanded = True,
                        main_align = "space_between",
                        children = [
                            render.Text(
                                content = "ORP",
                                font = "tom-thumb",
                                color = "#888",
                            ),
                            render.Text(
                                content = "{}".format(int(orp)),
                                font = "6x13",
                                color = orp_color,
                            ),
                        ],
                    ),
                ],
            ),
        ),
    )

def render_error(message):
    return render.Root(
        child = render.Box(
            padding = 2,
            child = render.WrappedText(
                content = message,
                font = "tom-thumb",
                color = "#f44336",
                align = "center",
            ),
        ),
    )

def get_temp_color(temp):
    # Ideal spa temperature: 36-40C
    if temp >= 36 and temp <= 40:
        return "#4caf50"  # Green - ideal
    elif temp >= 34 and temp <= 42:
        return "#ffeb3b"  # Yellow - acceptable
    else:
        return "#f44336"  # Red - too cold or hot

def get_ph_color(ph):
    # Ideal pH: 7.2-7.6
    if ph >= 7.2 and ph <= 7.6:
        return "#4caf50"  # Green - ideal
    elif ph >= 7.0 and ph <= 7.8:
        return "#ffeb3b"  # Yellow - acceptable
    else:
        return "#f44336"  # Red - needs attention

def get_orp_color(orp):
    # Ideal ORP: 650-750 mV
    if orp >= 650 and orp <= 750:
        return "#4caf50"  # Green - ideal
    elif orp >= 550 and orp <= 850:
        return "#ffeb3b"  # Yellow - acceptable
    else:
        return "#f44336"  # Red - needs attention

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "api_key",
                name = "API Key",
                desc = "Your iopool API key from the iopool app settings",
                icon = "key",
            ),
            schema.Text(
                id = "pool_id",
                name = "Pool/Spa ID",
                desc = "Your pool or spa ID from iopool",
                icon = "water",
            ),
        ],
    )
