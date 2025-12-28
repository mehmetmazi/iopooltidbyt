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
CACHE_TTL = 60  # 1 minute for near real-time updates
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

    if not api_key:
        return render_error("Configure API key")

    pool_data, is_stale = get_pool_data(api_key)

    if pool_data == None:
        return render_error("Failed to fetch data")

    return render_display(pool_data, is_stale)

def get_pool_data(api_key):
    cache_key = "iopool_data"
    last_data_key = "iopool_last_data"
    cached = cache.get(cache_key)

    if cached:
        return json.decode(cached), False

    # Get the list of pools - this endpoint returns all pool data we need
    pools_url = "{}/pools".format(IOPOOL_API_URL)
    headers = {
        "x-api-key": api_key,
    }

    pools_response = http.get(pools_url, headers = headers)

    if pools_response.status_code != 200:
        print("iopool API error getting pools: {}".format(pools_response.status_code))
        print("Response body: {}".format(pools_response.body))
        # Try to use last known good data
        last_data = cache.get(last_data_key)
        if last_data:
            return json.decode(last_data), True
        return None, False

    pools_data = pools_response.json()
    print("Pools API response:")
    print(json.encode(pools_data))
    
    # Get the first pool from the list (or handle empty list)
    if not pools_data or len(pools_data) == 0:
        print("No pools found for this API key")
        return None, False

    # Use the first pool's data directly - it already contains all the info we need
    pool_data = pools_data[0]
    
    # Cache fresh data with normal TTL
    cache.set(cache_key, json.encode(pool_data), ttl_seconds = CACHE_TTL)
    # Also cache as last known good data with longer TTL
    cache.set(last_data_key, json.encode(pool_data), ttl_seconds = LAST_DATA_TTL)
    return pool_data, False

def format_decimal(value):
    # Format a float to 1 decimal place (Starlark doesn't support .1f format spec)
    # Round to 1 decimal place: multiply by 10, round, then format
    abs_value = value if value >= 0 else -value
    rounded = int(abs_value * 10 + 0.5)
    whole = rounded // 10
    decimal = rounded % 10
    if value < 0:
        return "-{}.{}".format(whole, decimal)
    return "{}.{}".format(whole, decimal)

def render_display(pool_data, is_stale = False):
    title = "Jacuzzi"
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

    # Build compact layout with smaller fonts
    title_children = []
    if is_stale:
        title_children.append(
            render.Box(
                width = 2,
                height = 2,
                color = "#ff9800",
            ),
        )
        title_children.append(render.Box(width = 1, height = 1))  # spacer
    title_children.append(
        render.Text(
            content = title[:12],
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
                cross_align = "center",
                children = [
                    # Title row at top
                    render.Row(
                        expanded = True,
                        main_align = "center",
                        children = title_children,
                    ),
                    # Headers row in the middle
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
                                content = "pH",
                                font = "tom-thumb",
                                color = "#888",
                            ),
                            render.Text(
                                content = "ORP",
                                font = "tom-thumb",
                                color = "#888",
                            ),
                        ],
                    ),
                    # Values row at bottom
                    render.Row(
                        expanded = True,
                        main_align = "space_between",
                        children = [
                            render.Text(
                                content = "{}C".format(format_decimal(temp)),
                                font = "tom-thumb",
                                color = temp_color,
                            ),
                            render.Text(
                                content = "{}".format(format_decimal(ph)),
                                font = "tom-thumb",
                                color = ph_color,
                            ),
                            render.Text(
                                content = "{}".format(int(orp)),
                                font = "tom-thumb",
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
        ],
    )
