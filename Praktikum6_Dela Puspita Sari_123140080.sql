
CREATE INDEX idx_fasilitas_geom 
ON fasilitas_publik 
USING GIST (geom);

CREATE INDEX idx_jalan_geom 
ON jalan 
USING GIST (geom);

CREATE INDEX idx_wilayah1_geom 
ON wilayah_1 
USING GIST (geom);

SELECT indexname, tablename 
FROM pg_indexes 
WHERE tablename IN ('fasilitas_publik', 'jalan', 'wilayah_1');

DROP INDEX IF EXISTS idx_fasilitas_geom;

EXPLAIN ANALYZE
SELECT f.nama 
FROM fasilitas_publik f, wilayah_1 w
WHERE ST_Intersects(f.geom, w.geom) AND w.nama = 'JatiMulyo';

CREATE INDEX idx_fasilitas_geom
ON fasilitas_publik
USING GIST (geom);

EXPLAIN ANALYZE
SELECT f.nama 
FROM fasilitas_publik f, wilayah_1 w
WHERE ST_Intersects(f.geom, w.geom) AND w.nama = 'JatiMulyo';

EXPLAIN ANALYZE
SELECT nama FROM fasilitas_publik
WHERE ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(105.315, -5.337), 4326)::geography) < 1000;

EXPLAIN ANALYZE
SELECT nama FROM fasilitas_publik
WHERE ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(105.315, -5.337), 4326)::geography, 1000);
