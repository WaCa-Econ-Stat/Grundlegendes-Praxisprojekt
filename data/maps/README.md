# Cached world geometry

`ne_50m_admin_0_countries.geojson` is the Natural Earth 1:50 million Admin 0 countries file already used by the confirmed world map. It was copied from the existing `Grundlegendes-Praxisprojekt-Neustart-2/data/maps/` cache so this project can run independently and offline.

Natural Earth data are public domain. Original download location:

https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_admin_0_countries.geojson

The pipeline uses PIP region assignments where available, with the map's `REGION_WB` as a fallback. Its displayed rates describe whole regions, not countries.
