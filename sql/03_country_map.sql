-- 03_country_map.sql
-- Project 1: DataCo delivery performance
-- Stage 3: lookup table from raw country name (Spanish) to English name
-- Method: raw names listed with SQL (format with %L), translations drafted with an
--         AI assistant, reviewed by me, and validated with the three checks below.
-- The raw table is never edited. The clean step joins to this map.

CREATE SCHEMA IF NOT EXISTS clean;
DROP TABLE IF EXISTS clean.country_map;
CREATE TABLE clean.country_map (
    country_raw TEXT PRIMARY KEY,
    country_en  TEXT
);

INSERT INTO clean.country_map (country_raw, country_en) VALUES
    ('Afganistán', 'Afghanistan'),
    ('Albania', 'Albania'),
    ('Alemania', 'Germany'),
    ('Angola', 'Angola'),
    ('Arabia Saudí', 'Saudi Arabia'),
    ('Argelia', 'Algeria'),
    ('Argentina', 'Argentina'),
    ('Armenia', 'Armenia'),
    ('Australia', 'Australia'),
    ('Austria', 'Austria'),
    ('Azerbaiyán', 'Azerbaijan'),
    ('Bangladés', 'Bangladesh'),
    ('Barbados', 'Barbados'),
    ('Baréin', 'Bahrain'),
    ('Bélgica', 'Belgium'),
    ('Belice', 'Belize'),
    ('Benín', 'Benin'),
    ('Bielorrusia', 'Belarus'),
    ('Bolivia', 'Bolivia'),
    ('Bosnia y Herzegovina', 'Bosnia and Herzegovina'),
    ('Botsuana', 'Botswana'),
    ('Brasil', 'Brazil'),
    ('Bulgaria', 'Bulgaria'),
    ('Burkina Faso', 'Burkina Faso'),
    ('Burundi', 'Burundi'),
    ('Bután', 'Bhutan'),
    ('Camboya', 'Cambodia'),
    ('Camerún', 'Cameroon'),
    ('Canada', 'Canada'),
    ('Chad', 'Chad'),
    ('Chile', 'Chile'),
    ('China', 'China'),
    ('Chipre', 'Cyprus'),
    ('Colombia', 'Colombia'),
    ('Corea del Sur', 'South Korea'),
    ('Costa de Marfil', 'Ivory Coast'),
    ('Costa Rica', 'Costa Rica'),
    ('Croacia', 'Croatia'),
    ('Cuba', 'Cuba'),
    ('Dinamarca', 'Denmark'),
    ('Ecuador', 'Ecuador'),
    ('Egipto', 'Egypt'),
    ('El Salvador', 'El Salvador'),
    ('Emiratos Árabes Unidos', 'United Arab Emirates'),
    ('Eritrea', 'Eritrea'),
    ('Eslovaquia', 'Slovakia'),
    ('Eslovenia', 'Slovenia'),
    ('España', 'Spain'),
    ('Estados Unidos', 'United States'),
    ('Estonia', 'Estonia'),
    ('Etiopía', 'Ethiopia'),
    ('Filipinas', 'Philippines'),
    ('Finlandia', 'Finland'),
    ('Francia', 'France'),
    ('Gabón', 'Gabon'),
    ('Georgia', 'Georgia'),
    ('Ghana', 'Ghana'),
    ('Grecia', 'Greece'),
    ('Guadalupe', 'Guadeloupe'),
    ('Guatemala', 'Guatemala'),
    ('Guayana Francesa', 'French Guiana'),
    ('Guinea', 'Guinea'),
    ('Guinea-Bissau', 'Guinea-Bissau'),
    ('Guinea Ecuatorial', 'Equatorial Guinea'),
    ('Guyana', 'Guyana'),
    ('Haití', 'Haiti'),
    ('Honduras', 'Honduras'),
    ('Hong Kong', 'Hong Kong'),
    ('Hungría', 'Hungary'),
    ('India', 'India'),
    ('Indonesia', 'Indonesia'),
    ('Irak', 'Iraq'),
    ('Irán', 'Iran'),
    ('Irlanda', 'Ireland'),
    ('Israel', 'Israel'),
    ('Italia', 'Italy'),
    ('Jamaica', 'Jamaica'),
    ('Japón', 'Japan'),
    ('Jordania', 'Jordan'),
    ('Kazajistán', 'Kazakhstan'),
    ('Kenia', 'Kenya'),
    ('Kirguistán', 'Kyrgyzstan'),
    ('Kuwait', 'Kuwait'),
    ('Laos', 'Laos'),
    ('Lesoto', 'Lesotho'),
    ('Líbano', 'Lebanon'),
    ('Liberia', 'Liberia'),
    ('Libia', 'Libya'),
    ('Lituania', 'Lithuania'),
    ('Luxemburgo', 'Luxembourg'),
    ('Macedonia', 'North Macedonia'),
    ('Madagascar', 'Madagascar'),
    ('Malasia', 'Malaysia'),
    ('Mali', 'Mali'),
    ('Marruecos', 'Morocco'),
    ('Martinica', 'Martinique'),
    ('Mauritania', 'Mauritania'),
    ('México', 'Mexico'),
    ('Moldavia', 'Moldova'),
    ('Mongolia', 'Mongolia'),
    ('Montenegro', 'Montenegro'),
    ('Mozambique', 'Mozambique'),
    ('Myanmar (Birmania)', 'Myanmar'),
    ('Namibia', 'Namibia'),
    ('Nepal', 'Nepal'),
    ('Nicaragua', 'Nicaragua'),
    ('Níger', 'Niger'),
    ('Nigeria', 'Nigeria'),
    ('Noruega', 'Norway'),
    ('Nueva Zelanda', 'New Zealand'),
    ('Omán', 'Oman'),
    ('Países Bajos', 'Netherlands'),
    ('Pakistán', 'Pakistan'),
    ('Panamá', 'Panama'),
    ('Papúa Nueva Guinea', 'Papua New Guinea'),
    ('Paraguay', 'Paraguay'),
    ('Perú', 'Peru'),
    ('Polonia', 'Poland'),
    ('Portugal', 'Portugal'),
    ('Qatar', 'Qatar'),
    ('Reino Unido', 'United Kingdom'),
    ('República Centroafricana', 'Central African Republic'),
    ('República Checa', 'Czech Republic'),
    ('República de Gambia', 'Gambia'),
    ('República del Congo', 'Republic of the Congo'),
    ('República Democrática del Congo', 'Democratic Republic of the Congo'),
    ('República Dominicana', 'Dominican Republic'),
    ('Ruanda', 'Rwanda'),
    ('Rumania', 'Romania'),
    ('Rusia', 'Russia'),
    ('Sáhara Occidental', 'Western Sahara'),
    ('Senegal', 'Senegal'),
    ('Serbia', 'Serbia'),
    ('Sierra Leona', 'Sierra Leone'),
    ('Singapur', 'Singapore'),
    ('Siria', 'Syria'),
    ('Somalia', 'Somalia'),
    ('Sri Lanka', 'Sri Lanka'),
    ('Suazilandia', 'Eswatini'),
    ('SudAfrica', 'South Africa'),
    ('Sudán', 'Sudan'),
    ('Sudán del Sur', 'South Sudan'),
    ('Suecia', 'Sweden'),
    ('Suiza', 'Switzerland'),
    ('Surinam', 'Suriname'),
    ('Tailandia', 'Thailand'),
    ('Taiwán', 'Taiwan'),
    ('Tanzania', 'Tanzania'),
    ('Tayikistán', 'Tajikistan'),
    ('Togo', 'Togo'),
    ('Trinidad y Tobago', 'Trinidad and Tobago'),
    ('Túnez', 'Tunisia'),
    ('Turkmenistán', 'Turkmenistan'),
    ('Turquía', 'Turkey'),
    ('Ucrania', 'Ukraine'),
    ('Uganda', 'Uganda'),
    ('Uruguay', 'Uruguay'),
    ('Uzbekistán', 'Uzbekistan'),
    ('Venezuela', 'Venezuela'),
    ('Vietnam', 'Vietnam'),
    ('Yemen', 'Yemen'),
    ('Yibuti', 'Djibouti'),
    ('Zambia', 'Zambia'),
    ('Zimbabue', 'Zimbabwe');


-- Check 0: the map has one row per raw country
SELECT COUNT(*) AS map_rows FROM clean.country_map;


-- Check 1: completeness. Raw countries with no match in the map
-- Saw: 0 rows. Every country in the raw data has a translation.
-- Means: no order will lose its country when the clean step joins to the map.
-- Do: nothing. Logged as fixed in Issues Log #7.
SELECT DISTINCT r."Order Country"
FROM raw.stg_dataco AS r
LEFT JOIN clean.country_map AS m
       ON r."Order Country" = m.country_raw
WHERE m.country_raw IS NULL;


-- Check 2: how many names changed
-- Saw: 102 of 164 countries changed name; 62 were already the same in English.
-- Means: the map is real translation work, not a copy of the raw names.
-- Do: record 102 in Issues Log #7 (rows affected).
SELECT COUNT(*) AS translated
FROM clean.country_map
WHERE country_raw <> country_en;


-- Check 3: duplicates. English names used by more than one raw name
-- Saw: 0 rows. Each English name appears once.
-- Means: no two raw spellings were merged into the same country by mistake.
-- Do: nothing. If rows appear, review each pair: it is either a real duplicate to
--     merge on purpose or a translation typo.
SELECT country_en, COUNT(*) AS raw_names
FROM clean.country_map
GROUP BY 1
HAVING COUNT(*) > 1;