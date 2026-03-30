
-- Membuat Zona Buffer (ST_Buffer)
-- Buffer 500 meter untuk Fasilitas Umum
SELECT nama, ST_Buffer(geom::geography, 500)::geometry AS buffer_geom
FROM fasilitas_publik 
WHERE jenis = 'Fasilitas Umum';

-- Buffer 1000 meter untuk Sekolah
SELECT nama, ST_Buffer(geom::geography, 1000)::geometry AS buffer_geom
FROM fasilitas_publik 
WHERE jenis = 'Sekolah';


-- Menggabungkan Buffer Sejenis (ST_Union)
-- Menggabungkan seluruh area layanan Fasilitas Umum
CREATE TABLE cakupan_fasilitas_umum AS
SELECT ST_Union(ST_Buffer(geom::geography, 500)::geometry) AS geom
FROM fasilitas_publik
WHERE jenis = 'Fasilitas Umum';

-- Menggabungkan seluruh area layanan Sekolah
CREATE TABLE cakupan_sekolah AS
SELECT ST_Union(ST_Buffer(geom::geography, 1000)::geometry) AS geom
FROM fasilitas_publik
WHERE jenis = 'Sekolah';


-- Mencari Area Tumpang Tindih (ST_Intersection)
-- Mencari area yang masuk dalam jangkauan Fasilitas Umum DAN Sekolah
SELECT ST_Intersection(fu.geom, sk.geom) AS area_overlap
FROM cakupan_fasilitas_umum fu, cakupan_sekolah sk;

-- Menghitung luas area tumpang tindih tersebut dalam meter persegi
SELECT ST_Area(ST_Intersection(fu.geom, sk.geom)::geography) AS luas_overlap_m2
FROM cakupan_fasilitas_umum fu, cakupan_sekolah sk;


-- Menentukan Titik Pusat untuk Labeling (ST_Centroid)
-- Menghitung Centroid untuk setiap tabel wilayah
SELECT nama, ST_AsText(ST_Centroid(geom)) AS titik_pusat
FROM wilayah_1
UNION ALL
SELECT nama, ST_AsText(ST_Centroid(geom)) FROM wilayah_2
UNION ALL
SELECT nama, ST_AsText(ST_Centroid(geom)) FROM wilayah_3;

-- Menghitung Centroid dari area tumpang tindih (overlap)
SELECT ST_AsText(ST_Centroid(ST_Intersection(fu.geom, sk.geom))) AS label_overlap
FROM cakupan_fasilitas_umum fu, cakupan_sekolah sk;


-- Analisis Tambahan: ST_Difference
-- Area Jatimulyo yang tidak tercover sekolah dalam radius 1km
SELECT ST_Difference(w.geom, sk.geom) AS area_tidak_terlayani
FROM wilayah_1 w, cakupan_sekolah sk
WHERE w.nama = 'JatiMulyo';