--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

--
-- Name: GetParameterValue(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "GetParameterValue"(p text) RETURNS text
    LANGUAGE plpgsql
    AS $$ DECLARE
res text;
BEGIN
res:=(select value from config where parameter=p);
RETURN res;

END;$$;


ALTER FUNCTION public."GetParameterValue"(p text) OWNER TO postgres;

--
-- Name: GetPointTypes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "GetPointTypes"() RETURNS json[]
    LANGUAGE plpgsql
    AS $$ DECLARE
feature_pref text;
res text;
json_item json;
json_array json ARRAY;
i record;
BEGIN
json_array:=null;
res:='';
FOR i in (select "id","name","pic","order" from "pointTypes") LOOP
json_item:=json_build_object(
'id', i.id,
'name', i.name,
'pic',i.pic,
'order',i.order
);
json_array:=json_array||json_item;
END LOOP;
--res:=feature_array;
--res:=regexp_replace(res, '\', '','g');
RETURN json_array;

END;$$;


ALTER FUNCTION public."GetPointTypes"() OWNER TO postgres;

--
-- Name: GetPointsByBounds(numeric, numeric, numeric, numeric, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "GetPointsByBounds"(lat1 numeric, long1 numeric, lat2 numeric, long2 numeric, properties text) RETURNS json[]
    LANGUAGE plpgsql
    AS $$ DECLARE
feature_pref text;
res text;
feature_json json;
feature_txt text;
feature_array json ARRAY;
i record;
lat_max numeric;
lat_min numeric;
long_max numeric;
long_min numeric;
BEGIN
feature_array:=null;
res:='';
FOR i in (select p.long,p.lat,p.name,p.id,p.type,pt.name,pt.pic,p.url from points p, "pointTypes" pt 
		   where (p.long between long1 and long2) 
		   AND (p.lat between lat1 and lat2)
		   AND (p.type)=pt.id
		   ) LOOP
feature_json:=json_build_object(
'type', 'Feature',
'geometry', json_build_object(
	'type', 'Point',
	'coordinates', json_build_array(i.long,i.lat)
	),
'properties', json_build_object(
	'id', i.id,
	'name', i.name,
	'url', i.url,
	'type',i.type,
	'icon',json_build_object(
		'iconUrl',"GetParameterValue"('Application.URL')||i.pic,
		'iconSize',json_build_array(25, 25), --size of the icon
		'iconAnchor',json_build_array(25, 25), --point of the icon which will correspond to marker's location
		'popupAnchor',json_build_array(0, -25), --point from which the popup should open relative to the iconAnchor
		'className','dot')
	)
);
feature_array:=feature_array||feature_json;
END LOOP;
--res:=feature_array;
--res:=regexp_replace(res, '\', '','g');
RETURN feature_array;

END;$$;


ALTER FUNCTION public."GetPointsByBounds"(lat1 numeric, long1 numeric, lat2 numeric, long2 numeric, properties text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: collection; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE collection (
    id integer NOT NULL,
    name text,
    data json
);


ALTER TABLE collection OWNER TO postgres;

--
-- Name: collectionOfPlaces; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "collectionOfPlaces" (
    id integer NOT NULL,
    "placeId" integer,
    "collectionId" integer,
    data json
);


ALTER TABLE "collectionOfPlaces" OWNER TO postgres;

--
-- Name: collectionOfPlaces_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "collectionOfPlaces_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "collectionOfPlaces_id_seq" OWNER TO postgres;

--
-- Name: collectionOfPlaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "collectionOfPlaces_id_seq" OWNED BY "collectionOfPlaces".id;


--
-- Name: collection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE collection_id_seq OWNER TO postgres;

--
-- Name: collection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE collection_id_seq OWNED BY collection.id;


--
-- Name: config; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE config (
    parameter text NOT NULL,
    value text
);


ALTER TABLE config OWNER TO postgres;

--
-- Name: geoPoint; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "geoPoint" (
    id integer NOT NULL,
    alt double precision,
    long double precision
);


ALTER TABLE "geoPoint" OWNER TO postgres;

--
-- Name: geoPoint_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "geoPoint_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "geoPoint_id_seq" OWNER TO postgres;

--
-- Name: geoPoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "geoPoint_id_seq" OWNED BY "geoPoint".id;


--
-- Name: photos; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE photos (
    id integer NOT NULL,
    "placeId" integer,
    "photoURL" text,
    data json
);


ALTER TABLE photos OWNER TO postgres;

--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE photos_id_seq OWNER TO postgres;

--
-- Name: photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE photos_id_seq OWNED BY photos.id;


--
-- Name: place; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE place (
    id integer NOT NULL,
    "geoPointId" integer,
    data json,
    name text
);


ALTER TABLE place OWNER TO postgres;

--
-- Name: place_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE place_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE place_id_seq OWNER TO postgres;

--
-- Name: place_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE place_id_seq OWNED BY place.id;


--
-- Name: pointTypes; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "pointTypes" (
    id text NOT NULL,
    name text,
    pic text,
    scale integer,
    "order" integer
);


ALTER TABLE "pointTypes" OWNER TO postgres;

--
-- Name: points; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE points (
    long numeric,
    lat numeric,
    name text,
    url text,
    id uuid NOT NULL,
    type character varying(100),
    dsc text
);


ALTER TABLE points OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name text,
    "picURL" text
);


ALTER TABLE tags OWNER TO postgres;

--
-- Name: tagsOfPlaces; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "tagsOfPlaces" (
    "placeId" integer,
    id integer NOT NULL,
    "tagId" integer,
    data json
);


ALTER TABLE "tagsOfPlaces" OWNER TO postgres;

--
-- Name: tagsOfPlaces_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "tagsOfPlaces_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "tagsOfPlaces_id_seq" OWNER TO postgres;

--
-- Name: tagsOfPlaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "tagsOfPlaces_id_seq" OWNED BY "tagsOfPlaces".id;


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tags_id_seq OWNER TO postgres;

--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY collection ALTER COLUMN id SET DEFAULT nextval('collection_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "collectionOfPlaces" ALTER COLUMN id SET DEFAULT nextval('"collectionOfPlaces_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "geoPoint" ALTER COLUMN id SET DEFAULT nextval('"geoPoint_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY photos ALTER COLUMN id SET DEFAULT nextval('photos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY place ALTER COLUMN id SET DEFAULT nextval('place_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "tagsOfPlaces" ALTER COLUMN id SET DEFAULT nextval('"tagsOfPlaces_id_seq"'::regclass);


--
-- Data for Name: collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY collection (id, name, data) FROM stdin;
\.


--
-- Data for Name: collectionOfPlaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "collectionOfPlaces" (id, "placeId", "collectionId", data) FROM stdin;
\.


--
-- Name: collectionOfPlaces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"collectionOfPlaces_id_seq"', 1, false);


--
-- Name: collection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('collection_id_seq', 1, false);


--
-- Data for Name: config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY config (parameter, value) FROM stdin;
Application.URL	http://52.24.146.63
\.


--
-- Data for Name: geoPoint; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "geoPoint" (id, alt, long) FROM stdin;
\.


--
-- Name: geoPoint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"geoPoint_id_seq"', 1, false);


--
-- Data for Name: photos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY photos (id, "placeId", "photoURL", data) FROM stdin;
\.


--
-- Name: photos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('photos_id_seq', 1, false);


--
-- Data for Name: place; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY place (id, "geoPointId", data, name) FROM stdin;
1	1	{\r\n      "type": "Feature",\r\n      "properties": {},\r\n      "geometry": {\r\n        "type": "Point",\r\n        "coordinates": [\r\n          37.55401611328125,\r\n          55.57834467218206\r\n        ]\r\n      }\r\n    }	test3
2	2	\N	\N
3	3	{\r\n      "type": "Feature",\r\n      "properties": {},\r\n      "geometry": {\r\n        "type": "Point",\r\n        "coordinates": [\r\n          37.55401611328125,\r\n          55.57834467218206\r\n        ]\r\n      }\r\n    }	test3
\.


--
-- Name: place_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('place_id_seq', 3, true);


--
-- Data for Name: pointTypes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "pointTypes" (id, name, pic, scale, "order") FROM stdin;
nature	Природа	/static/icons/nature.png	\N	1
hotel	Гостиница	/static/icons/hotel.png	\N	2
\.


--
-- Data for Name: points; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY points (long, lat, name, url, id, type, dsc) FROM stdin;
37.518310546875	55.68068160461293	Точка 1	www.yandex.ru	025ae01e-1147-4385-bad5-5658d666eaf5	hotel	\N
37.518310546875	55.68068160461293	Точка 4	www.yandex.ru	1e40494e-204b-44ca-addc-a9cf16590a16	hotel	\N
37.6116943359375	55.896876336360755	Точка 2	www.yandex.ru	6174d8eb-8325-4f51-8982-cdf96de8ac64	nature	\N
38.056640625	55.547280698640805	Точка 3	www.yandex.ru	534ba003-37cf-4f4a-9a31-4d3fc0e0867c	nature	\N
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY tags (id, name, "picURL") FROM stdin;
\.


--
-- Data for Name: tagsOfPlaces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "tagsOfPlaces" ("placeId", id, "tagId", data) FROM stdin;
\.


--
-- Name: tagsOfPlaces_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"tagsOfPlaces_id_seq"', 1, false);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('tags_id_seq', 1, false);


--
-- Name: collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY collection
    ADD CONSTRAINT collection_pkey PRIMARY KEY (id);


--
-- Name: config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_pkey PRIMARY KEY (parameter);


--
-- Name: geoPoint_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "geoPoint"
    ADD CONSTRAINT "geoPoint_pkey" PRIMARY KEY (id);


--
-- Name: photos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: place_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY place
    ADD CONSTRAINT place_pkey PRIMARY KEY (id);


--
-- Name: pointTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "pointTypes"
    ADD CONSTRAINT "pointTypes_pkey" PRIMARY KEY (id);


--
-- Name: points_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY points
    ADD CONSTRAINT points_pkey PRIMARY KEY (id);


--
-- Name: tagsOfPlaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "tagsOfPlaces"
    ADD CONSTRAINT "tagsOfPlaces_pkey" PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

