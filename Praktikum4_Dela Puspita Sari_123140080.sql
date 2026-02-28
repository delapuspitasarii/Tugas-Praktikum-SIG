
-- membuat query spasial untuk menganalisis Jarak wilayah menggunakan fungsi (ST_Distance)
-- menggunakan satuan meter dalam mengukur jarak wilayah (Geography)
SELECT ST_Distance(
    a.geom::geography,
    b.geom::geography
) AS jarak_meter
FROM fasilitas_publik a, fasilitas_publik b
WHERE a.nama = 'musholla nurul iman'
AND b.nama = 'Gereja Katolik Santo Fransiskus Xaverius, Stasi Jatimulyo';

-- menggunakan satuan meter dalam mengukur jarak wilayah (UTM)
SELECT ST_Distance(
    ST_Transform(a.geom, 32748),
    ST_Transform(b.geom, 32748)
) AS jarak_meter
FROM fasilitas_publik a, fasilitas_publik b
WHERE a.nama = 'musholla nurul iman'
AND b.nama = 'Gereja Katolik Santo Fransiskus Xaverius, Stasi Jatimulyo';




-- membuat query spasial untuk menganalisis luas wilayah (ST_Area)
-- luas wilayah_1 = Jatimulyo
SELECT
    nama,
    ST_Area(ST_Transform(geom, 32748)) AS luas_m2,
    ST_Area(ST_Transform(geom, 32748)) / 10000 AS luas_ha
FROM wilayah_1;

-- luas wilayah_2 = Margodadi
SELECT
    nama,
    ST_Area(ST_Transform(geom, 32748)) AS luas_m2,
    ST_Area(ST_Transform(geom, 32748)) / 10000 AS luas_ha
FROM wilayah_2;

-- luas wilayah_3 = Margolestari
SELECT
    nama,
    ST_Area(ST_Transform(geom, 32748)) AS luas_m2,
    ST_Area(ST_Transform(geom, 32748)) / 10000 AS luas_ha
FROM wilayah_3;


-- mengecek apakah titik fasilitas berada di dalam poligon wilayah
SELECT f.nama, f.jenis
FROM fasilitas_publik f
JOIN wilayah_1 w
ON ST_Within(f.geom, w.geom);


-- mengidentifikasi jalan yang melewati atau memotong wilayah
SELECT j.nama
FROM jalan j
JOIN wilayah_1 w
ON ST_Intersects(j.geom, w.geom);


-- pengimplementasian K-NN untuk mencari fasilitas terdekat
SELECT
    nama,
    ST_Distance(
        geom::geography,
        ST_GeomFromText(
            'POINT(105.31503955583739 -5.336917274983146)', 4326
        )::geography
    ) AS jarak_meter
FROM fasilitas_publik
ORDER BY geom <->
ST_GeomFromText(
    'POINT(105.31503955583739 -5.336917274983146)', 4326
)
LIMIT 3;


-- Jumlah Fasilitas Publik per Wilayah
SELECT
    w.nama AS wilayah,
    COUNT(f.id) AS jumlah_fasilitas
FROM wilayah_1 w
LEFT JOIN fasilitas_publik f
ON ST_Contains(w.geom, f.geom)
GROUP BY w.nama;


-- umlah Fasilitas Berdasarkan Jenis di Wilayah Jatimulyo
SELECT
    f.jenis,
    COUNT(f.id) AS jumlah
FROM fasilitas_publik f
JOIN wilayah_1 w
ON ST_Within(f.geom, w.geom)
GROUP BY f.jenis;


-- Total Panjang Jalan per Wilayah
SELECT
    w.nama AS wilayah,
    ROUND(
        SUM(
            ST_Length(
                ST_Transform(j.geom, 32748)
            )
        )::numeric, 2
    ) AS total_panjang_jalan_meter
FROM wilayah_1 w
JOIN jalan j
ON ST_Intersects(j.geom, w.geom)
GROUP BY w.nama;


-- Rata-rata Jarak Fasilitas ke Musholla Nurul Iman
SELECT
    f.jenis,
    ROUND(
        AVG(
            ST_Distance(
                f.geom::geography,
                m.geom::geography
            )
        )::numeric,
        2
    ) AS rata_rata_jarak_meter
FROM fasilitas_publik f,
     fasilitas_publik m
WHERE m.nama = 'musholla nurul iman'
AND f.id <> m.id
GROUP BY f.jenis;