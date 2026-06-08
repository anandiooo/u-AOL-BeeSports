-- Nearby lobbies RPC using Haversine formula
-- Returns lobbies within a given radius (in km) from a point

CREATE OR REPLACE FUNCTION get_nearby_lobbies(
  p_lat double precision,
  p_lng double precision,
  p_radius_km double precision DEFAULT 10.0,
  p_sport text DEFAULT NULL,
  p_limit integer DEFAULT 20
) RETURNS SETOF lobbies
LANGUAGE sql
STABLE
AS $$
  SELECT l.*
  FROM lobbies l
  WHERE l.status = 'open'
    AND l.latitude IS NOT NULL
    AND l.longitude IS NOT NULL
    AND l.scheduled_at > NOW()
    AND (p_sport IS NULL OR l.sport::text = p_sport)
    AND (
      6371 * acos(
        cos(radians(p_lat)) * cos(radians(l.latitude)) *
        cos(radians(l.longitude) - radians(p_lng)) +
        sin(radians(p_lat)) * sin(radians(l.latitude))
      )
    ) <= p_radius_km
  ORDER BY (
    6371 * acos(
      cos(radians(p_lat)) * cos(radians(l.latitude)) *
      cos(radians(l.longitude) - radians(p_lng)) +
      sin(radians(p_lat)) * sin(radians(l.latitude))
    )
  ) ASC
  LIMIT p_limit;
$$;
