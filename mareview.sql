--
-- PostgreSQL database dump
--

\restrict 09Cnbw4QvVOVWGchQxrAMv9ERZz8p6sDp3O04PUmNh5iMdP54JwrR6QVEmlZBmz

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-11-12 22:33:02

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 17731)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 228 (class 1259 OID 17809)
-- Name: dorm_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dorm_images (
    image_id integer NOT NULL,
    dorm_id integer NOT NULL,
    image_url text NOT NULL,
    image_order smallint NOT NULL,
    CONSTRAINT dorm_images_image_order_check CHECK (((image_order >= 1) AND (image_order <= 4)))
);


ALTER TABLE public.dorm_images OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17808)
-- Name: dorm_images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dorm_images ALTER COLUMN image_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dorm_images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 17872)
-- Name: dorm_ratings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dorm_ratings (
    member_id bigint NOT NULL,
    dorm_id bigint NOT NULL,
    score smallint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT dorm_ratings_score_check CHECK (((score >= 1) AND (score <= 10)))
);


ALTER TABLE public.dorm_ratings OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17895)
-- Name: dorm_rating_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.dorm_rating_stats AS
 SELECT dorm_id,
    count(*) AS rating_count,
    round(avg(score), 1) AS rating_average
   FROM public.dorm_ratings
  GROUP BY dorm_id;


ALTER VIEW public.dorm_rating_stats OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17829)
-- Name: dorm_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dorm_reviews (
    review_id integer NOT NULL,
    dorm_id integer NOT NULL,
    member_id integer NOT NULL,
    rating smallint NOT NULL,
    comment text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT dorm_reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.dorm_reviews OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17828)
-- Name: dorm_reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dorm_reviews ALTER COLUMN review_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dorm_reviews_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 17755)
-- Name: dorm_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dorm_types (
    dorm_type_id smallint NOT NULL,
    dorm_type_name character varying(20) NOT NULL
);


ALTER TABLE public.dorm_types OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17754)
-- Name: dorm_types_dorm_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dorm_types ALTER COLUMN dorm_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dorm_types_dorm_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 17854)
-- Name: dorm_wishlists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dorm_wishlists (
    member_id integer NOT NULL,
    dorm_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.dorm_wishlists OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17775)
-- Name: dormitories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dormitories (
    dorm_id integer NOT NULL,
    dorm_name character varying(150) NOT NULL,
    min_price numeric(10,2) NOT NULL,
    max_price numeric(10,2) NOT NULL,
    dorm_type_id smallint NOT NULL,
    gender_type_id smallint NOT NULL,
    google_map_url text,
    contact_url text,
    description text,
    rating_average numeric(5,3) DEFAULT 0 NOT NULL,
    rating_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT dormitories_check CHECK ((max_price >= min_price)),
    CONSTRAINT dormitories_min_price_check CHECK ((min_price >= (0)::numeric)),
    CONSTRAINT dormitories_rating_average_check CHECK (((rating_average >= (0)::numeric) AND (rating_average <= (10)::numeric))),
    CONSTRAINT dormitories_rating_count_check CHECK ((rating_count >= 0))
);


ALTER TABLE public.dormitories OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17774)
-- Name: dormitories_dorm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.dormitories ALTER COLUMN dorm_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.dormitories_dorm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 17765)
-- Name: gender_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gender_types (
    gender_type_id smallint NOT NULL,
    gender_type_name character varying(20) NOT NULL
);


ALTER TABLE public.gender_types OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17764)
-- Name: gender_types_gender_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.gender_types ALTER COLUMN gender_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.gender_types_gender_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 17734)
-- Name: members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.members (
    member_id bigint NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    display_name character varying(50) NOT NULL,
    avatar_url character varying(500),
    role character varying(10) DEFAULT 'member'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT members_display_name_check CHECK ((char_length(btrim((display_name)::text)) >= 1)),
    CONSTRAINT members_role_check CHECK (((role)::text = ANY ((ARRAY['member'::character varying, 'admin'::character varying])::text[])))
);


ALTER TABLE public.members OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17733)
-- Name: members_member_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.members_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.members_member_id_seq OWNER TO postgres;

--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 219
-- Name: members_member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.members_member_id_seq OWNED BY public.members.member_id;


--
-- TOC entry 4893 (class 2604 OID 17737)
-- Name: members member_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members ALTER COLUMN member_id SET DEFAULT nextval('public.members_member_id_seq'::regclass);


--
-- TOC entry 5104 (class 0 OID 17809)
-- Dependencies: 228
-- Data for Name: dorm_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dorm_images (image_id, dorm_id, image_url, image_order) FROM stdin;
1	1	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/DSCF3026-1536x1152.jpg	1
2	1	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/95183309_119601256378768_6039138607074115584_o-1536x430.jpg	2
3	1	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94506326_119601049712122_863484831055478784_o-1536x392.jpg	3
4	1	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/doortk1.jpg	4
5	2	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94485996_119602126378681_3197602980073308160_n.jpg	1
6	2	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94881758_119602056378688_731128567651368960_n.jpg	2
7	2	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94903510_119602106378683_6646253752149868544_o-1536x445.jpg	3
8	2	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94518220_119602539711973_3150793493018836992_n.jpg	4
9	3	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/95374365_119603309711896_5121647860806320128_n-1.jpg	1
10	3	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94484645_119603263045234_3781513293022101504_o-1536x407.jpg	2
11	3	https://dsa.su.ac.th/dorm/wp-content/uploads/2024/05/1173198_0-1536x1152.jpg	3
12	3	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94421603_119603223045238_5912812155631042560_n.jpg	4
13	4	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94480728_119605263045034_4699476073375596544_n.jpg	1
14	4	https://dsa.su.ac.th/dorm/wp-content/uploads/2025/05/24503_0.jpg	2
15	4	https://dsa.su.ac.th/dorm/wp-content/uploads/2025/05/24492_0.jpg	3
16	4	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/03/5520_%E0%B9%92%E0%B9%90%E0%B9%90%E0%B9%95%E0%B9%90%E0%B9%95_0103-1536x759.jpg	4
17	5	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94489901_119610459711181_7599522937497976832_n.jpg	1
18	5	https://dsa.su.ac.th/dorm/wp-content/uploads/2025/05/24504_0.jpg	2
19	5	https://dsa.su.ac.th/dorm/wp-content/uploads/2025/05/24499_0.jpg	3
20	5	https://dsa.su.ac.th/dorm/wp-content/uploads/2025/05/24491_0.jpg	4
21	6	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94491861_119634506375443_2010350736717643776_n.jpg	1
22	6	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/04/5520_%E0%B9%92%E0%B9%90%E0%B9%90%E0%B9%95%E0%B9%90%E0%B9%95_0030-1536x571.jpg	2
23	6	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/95245007_119634923042068_6830320953646383104_o-1536x458.jpg	3
24	6	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94436803_119634976375396_2668145555288358912_o-1536x364.jpg	4
25	7	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94482373_119635983041962_7618278303765364736_n.jpg	1
26	7	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94932563_119636056375288_1804929438861754368_o-1536x515.jpg	2
27	7	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94488700_119635959708631_6897680579311960064_n.jpg	3
28	7	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94919752_119636453041915_1396604316755689472_o-1536x541.jpg	4
29	8	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94504739_119638059708421_5757610810855653376_n.jpg	1
30	8	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/03/5520_%E0%B9%92%E0%B9%90%E0%B9%90%E0%B9%95%E0%B9%90%E0%B9%95_0071-1536x564.jpg	2
31	8	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94975042_119637869708440_2361190229827649536_n.jpg	3
32	8	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/95135835_119637923041768_3752123209772695552_o-1536x504.jpg	4
33	9	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/95187086_119639323041628_7838956996198924288_n.jpg	1
34	9	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94490593_119639456374948_2422370131993690112_o-1536x453.jpg	2
35	9	https://dsa.su.ac.th/dorm/wp-content/uploads/2024/05/1173429_0-1-1536x1152.jpg	3
36	9	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/94394240_119639216374972_1897288492904349696_n.jpg	4
37	10	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/02/95141315_119640419708185_3794833507025420288_n.jpg	1
38	10	https://dsa.su.ac.th/dorm/wp-content/uploads/2025/02/19161.jpg	2
39	10	https://dsa.su.ac.th/dorm/wp-content/uploads/2021/03/5520_%E0%B9%92%E0%B9%90%E0%B9%90%E0%B9%95%E0%B9%90%E0%B9%95_0049-1536x684.jpg	3
40	10	https://dsa.su.ac.th/dorm/wp-content/uploads/2025/05/25853.jpg	4
41	11	https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/654317467_1352225630264467_3222306806443972_n.jpg?stp=dst-jpg_tt6&cstp=mx624x416&ctp=s590x590&_nc_cat=100&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeGBNiIWE4wzNaWpjenukDlZ3qjgpK-_GnneqOCkr78aeQm8KrvJeJhdOrDrqMbFqUrCZTygnGuq370O2eZH18iI&_nc_ohc=a_MVSoL_fgUQ7kNvwF1teOz&_nc_oc=AdqHUGeb8yAOzX6MeO1NHiY2MLQs05z-qhn7vHcCeuFtz6jz2MDsTYki7GI91WK12t0&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=_NEzH0rQzLgcGJ_agP6TGg&_nc_ss=7b2a8&oh=00_AQRQb8pPIQ6OIU7Sjqk0y4Bbx-iatoUJrdSs_RfpjUU3oA&oe=6AF73150	1
42	11	https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/480752842_2366832710348797_6579335906651231391_n.jpg?stp=dst-jpg_tt6&cstp=mx550x359&ctp=s550x359&_nc_cat=110&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeFwryut1bY6-EF00CzZuWJOUJFeIAN4yoFQkV4gA3jKgX2Bimw_WPxCDHM9DkT5QpCRd8JSOeCVqtJ_6qPu3o84&_nc_ohc=Zo0-2nLxDtcQ7kNvwF5-Lyt&_nc_oc=AdrZ8c_KpI0slNuxPgdHncQkrLjnHpPAItjIBFoI0SA4oi3kGBP6WHEEv3uICLmigtI&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=2RvtaLlFtkYc49wmYUddHA&_nc_ss=7b2a8&oh=00_AQSpwY-vo2411-uud0TLVMzdh-HORpib2Kzbv0HpiNkCig&oe=6AF7184D	2
43	11	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRU5FxRiQZZgAkwCSIaI2V9y6qTrR92kjoR0VZ5jQJx-WJfSBZPompmXTc&s=10	3
44	11	https://scontent.fbkk5-6.fna.fbcdn.net/v/t39.30808-6/480266392_2366832727015462_8488680467932406964_n.jpg?stp=dst-jpg_tt6&cstp=mx624x356&ctp=s624x356&_nc_cat=101&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_ohc=oVwzIjYmcRgQ7kNvwFsMKDd&_nc_oc=AdqIAzd265wC7K_gWcHHHHcU6tXO9_yZstkcVr7qWaCvKndS9D13dU3-txkC4TaHgzU&_nc_zt=23&_nc_ht=scontent.fbkk5-6.fna&_nc_gid=unfGE8bNv4XbWjz_3QLZ0A&_nc_ss=7b2a8&oh=00_AQQrZRsLf5vLr_ibdiDBz-NbSidhTUFbUc_gZcMLsifdPA&oe=6AF7B507	4
66	17	https://images.thaiapartment.com/Apartment/5315/Thivawan-Villa-Apartment-Sanam-Chan-Nakorn-Pathom-5315_Int01.jpg	2
67	17	https://bcdn.renthub.in.th/listing_picture/202604/20260421/9BNhfg1knFVSNeVkep44.jpg?class=moptimized	3
68	17	https://bcdn.renthub.in.th/listing_picture/202604/20260421/daukqHTBxgH5b5MhtgFk.jpg?class=moptimized	4
45	12	https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/845685952_1399458558970763_7381792487443007364_n.jpg?stp=dst-jpg_tt6&cstp=mx720x960&ctp=s720x960&_nc_cat=106&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeGf8joTeQofbHOoPPOPxuc1BJL7z0FOW2QEkvvPQU5bZIErH_4VAkzTd1BF2yYPGw3XlybgEyevsxQ5le4rH8Tx&_nc_ohc=6__AVwV68CgQ7kNvwEkKxRv&_nc_oc=AdqU4aJQNNf-UhZl3a91wIR0MXK6xVqHaDAWCOra58LAjEf29u2u3WB90R8zG0lcyxA&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=Z0DDSjGW3NwIB9UIMC79jw&_nc_ss=7b2a8&oh=00_AQQ1DD1sY2VWICUneSEazzYgFOEdBRXtm6mLjjvWcLRfxA&oe=6AF72D05	1
46	12	https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/843266173_1399458625637423_3507588744641603862_n.jpg?stp=dst-jpg_tt6&cstp=mx720x960&ctp=s720x960&_nc_cat=105&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeE7LZvL1xos0ey4og3SgtC58sJ_XKkG0GLywn9cqQbQYp4zQGad-2KFNWn9CzpQSLpg0h-yBhyS_dCiF9Gfrpgl&_nc_ohc=H5ffgiVDLOQQ7kNvwFIAsoJ&_nc_oc=Adruty3rvSep02zemmauG5dZWcjSSmUvwPE5-faZm8oONnyabrZBHqcv4MkwiyaP7mo&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=lSrQpaSIbiZI3TdnVE6bRQ&_nc_ss=7b2a8&oh=00_AQTM5AhYI8RVAbJtg2XSzaTbh9r1-uBJaNuG5IBQs9Z73g&oe=6AF728F5	2
47	12	https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/481016955_937617348488222_1895995758942172181_n.jpg?stp=cp6_dst-jpg_tt6&cstp=mx1080x1440&ctp=s1080x1440&_nc_cat=108&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeF2lDt1vpVUlCJ3V22sQ8eK0WjFGsK2TU_RaMUawrZNT2DXILRKKnkBD7wEHraiwHvxpwtIOqVGsUGZr1YFMpgG&_nc_ohc=0on-hLM5wCMQ7kNvwFoDLI0&_nc_oc=AdonOWMr97w5LN4zgYyJFBLgmSZU9hoJLC2grN3lcheqzjPAi0jY4UkF8YSK0YhGgVQ&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=EynTnpIBlUMBQQNMSLc-hg&_nc_ss=7b2a8&oh=00_AQRuboLppEBbptcUsv8vitKps8sEadiRJSa2Wk8pOnBZew&oe=6AF73AE6	3
48	12	https://scontent.fbkk17-1.fna.fbcdn.net/v/t39.30808-6/481116620_932197335696890_3615573583081472123_n.jpg?stp=cp6_dst-jpg_tt6&cstp=mx1080x1440&ctp=s1080x1440&_nc_cat=106&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeF_AHVn5V8EoORIoC7luCAvjDUNGyeNRKeMNQ0bJ41Ep6vY1mtv7WeY8bNgyDUgv3P-rSmlFwc_lc1fvgEzfVEi&_nc_ohc=6f44gRuhqIYQ7kNvwH_7Yd9&_nc_oc=AdqzTf43yCIysaWpUJRBpqanJ-CNr_mLz5TpoWwFb6J3KqHEPnpT_7rG2CjhT2luv2w&_nc_zt=23&_nc_ht=scontent.fbkk17-1.fna&_nc_gid=-8bNC7UX_tGjQNRzwCyD-Q&_nc_ss=7b2a8&oh=00_AQT--b_3cAFlgPAn5OQ1QDb89epjllx4mvYkya_QntJepQ&oe=6AF74256	4
49	13	https://scontent.fbkk30-1.fna.fbcdn.net/v/t39.30808-6/480481651_2366832740348794_8809271736347623104_n.jpg?stp=dst-jpg_tt6&cstp=mx552x354&ctp=s552x354&_nc_cat=110&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_ohc=Xxi0CG3C_B8Q7kNvwH-FM48&_nc_oc=AdpmMfdXHehI1I8E9dxUTX9TAaWgC6VvAR4VTXn_Eu7c8L-VO4V5_AowDYIMzx2O8pk&_nc_zt=23&_nc_ht=scontent.fbkk30-1.fna&_nc_gid=2hAct4xNl7Ym7lUuc9xs_A&_nc_ss=7b2a8&oh=00_AQTbje3d39s3qoZ290NF-GSSFJ8En8JTUaXSUpv7OcDozQ&oe=6AF73E16	1
50	13	https://lh3.googleusercontent.com/grass-cs/AABkmLdB-9lOksyV5M5MQ2Jb6YR12i9id3coAZWoDZ6UqRNIHYRW8x2Foqw8cpmZKt6E4keWnAVpKrUG8O2mILe3zy6eCdSCYoAb7zKd3GRrHAyFXzX_nuQPVszj7-o6Hrn4MTRVgO6wO_VInqg=w414-h240-k-no	2
51	13	https://scontent.fbkk30-2.fna.fbcdn.net/v/t39.30808-6/305300537_572658481323842_6108884845973303646_n.jpg?stp=dst-jpg_tt6&cstp=mx2044x1363&ctp=s2044x1363&_nc_cat=100&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=VZQSPMWs15YQ7kNvwFU9jOM&_nc_oc=AdoC64HT4_gkTREP9zmMFH-G4vFVo0Yh1MwldvuBP2JYbO7b9eBcLb02x2efR9taDyI&_nc_zt=23&_nc_ht=scontent.fbkk30-2.fna&_nc_gid=ta2ZE7EhXv6Lgm8D-Gnj2w&_nc_ss=7b2a8&oh=00_AQRboi3mg6VQlDl60SPqiA6Y56S99Mir0JXpI7XrQEUyRw&oe=6AF73645	3
52	13	https://scontent.fbkk30-2.fna.fbcdn.net/v/t39.30808-6/555587448_24468904669418440_2711207804056351867_n.jpg?stp=dst-jpg_tt6&cstp=mx960x720&ctp=s960x720&_nc_cat=101&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=0b6b33&_nc_ohc=j020I67gfrAQ7kNvwFN-9mo&_nc_oc=AdoJMJYDJVFHoqXlZsU9Qq1e8MvbUvQ54wrcVqOSTVJVgX1uuQ0ktejcV_yr13WbvJ8&_nc_zt=23&_nc_ht=scontent.fbkk30-2.fna&_nc_gid=PcUY7439MVMrIQ0fXdPViA&_nc_ss=7b2a8&oh=00_AQRvZDcvjoOJ12_-PNp9kR5K87hDRPkPQhS18aDPTlHPsA&oe=6AF7360C	4
53	14	https://scontent.fbkk30-2.fna.fbcdn.net/v/t1.6435-9/97453488_2119061241572964_5364763651372744704_n.jpg?stp=dst-jpg_tt6&cstp=mx960x720&ctp=s960x720&_nc_cat=103&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=833d8c&_nc_ohc=WjG9n-8owfIQ7kNvwGvwKQF&_nc_oc=AdpiK-TX-ZQm9zEh-fcGvOX8AwCjWWZg04b_D7FyAWsD_btuL8GvEwuEiP2aTkm3kWk&_nc_zt=23&_nc_ht=scontent.fbkk30-2.fna&_nc_gid=Aa1xZjfXQIR_Oz4Flp6Hag&_nc_ss=7b2a8&oh=00_AQQ-dLLYksmes4_qgQRTDrnNpKX4TMx9sz5mhJR9-7lM9g&oe=6B18B53A	1
54	14	https://bcdn.renthub.in.th/listing_picture/201505/20150518/JEYTAVkuzb5HEJai8Tyb.jpg?class=moptimized	2
55	14	https://scontent.fbkk30-2.fna.fbcdn.net/v/t1.6435-9/61903728_1214837992056427_9213585270971039744_n.jpg?stp=dst-jpg_tt6&cstp=mx1875x1407&ctp=s1875x1407&_nc_cat=106&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=B-ZNId4Cvo4Q7kNvwGRsOZE&_nc_oc=AdqMc4Qmt5KCPJEvDnJ-0rcnEwoU3EoJZyH3bagZtb6-8rScQKC-8Rwt7uRJys_fQ9w&_nc_zt=23&_nc_ht=scontent.fbkk30-2.fna&_nc_gid=F5TxzBgRokf2VxEA3nSvig&_nc_ss=7b2a8&oh=00_AQTrqFwnyazydLBDyZLvrxLu3rscHiy5v_W_oGDpyWhRdw&oe=6B18EA36	3
56	14	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_dmQESY3m5WBJDBAtg3ynBG78aLuK9fr3YSMHxY73OSgvzNUvpAoEcOLR&s=10	4
57	15	https://lh3.googleusercontent.com/grass-cs/AABkmLeCkL1vriqInPp8ETltUwSyN1O8_IDB06mQmE704dXhKeTEalcX78kDNEirzswF-88BvTXGb7NX_vHeWP7r8wcK-K9vdbcy8ZoCqk7svMYX7sBjTyWaF9h9OAwPFRLhQy5z2v9t=w408-h272-k-no	1
58	15	https://scontent.fbkk30-2.fna.fbcdn.net/v/t1.6435-9/169966097_293880682124868_2128998557306082671_n.jpg?stp=dst-jpg_tt6&cstp=mx1648x994&ctp=s1648x994&_nc_cat=110&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=ZBnljg4td5YQ7kNvwHnJbVn&_nc_oc=Adqze0U6R8I6eMHrkDWTA6IbpY4YWL-CETuU2t7oCsLvWvB_EgUdNM3VJWaeaPFZ5tQ&_nc_zt=23&_nc_ht=scontent.fbkk30-2.fna&_nc_gid=my1hBIjCNGwRbTn1qWwUIg&_nc_ss=7b2a8&oh=00_AQRb1AOIistwJ8iWHwMJgW9EwGloLxw313p2GdUtpv1sjQ&oe=6B18CE17	2
59	15	https://scontent.fbkk30-1.fna.fbcdn.net/v/t1.6435-9/170240085_293880675458202_8196678844715532744_n.jpg?stp=dst-jpg_tt6&cstp=mx1756x932&ctp=s1756x932&_nc_cat=107&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=vQN6Ib1kbDkQ7kNvwG2DQTn&_nc_oc=AdrT3YPCKGhB5M9elRTcYG0M912HlCOkcVt6lPNpbbwJvOJF-SyXzOM7_F62SEDgdms&_nc_zt=23&_nc_ht=scontent.fbkk30-1.fna&_nc_gid=8IDBSdJz_au8xFWWcukIyQ&_nc_ss=7b2a8&oh=00_AQS_W4GMd9SCpK3lc483RV-f7IOyzFVoUBlwIOVGyEuylA&oe=6B18C8A1	3
60	15	https://scontent.fbkk30-1.fna.fbcdn.net/v/t1.6435-9/166151327_287312526115017_5480735479953355243_n.jpg?stp=dst-jpg_tt6&cstp=mx1900x860&ctp=s1900x860&_nc_cat=102&_nc_map=urlgen_bucketless&ccb=1-7&_nc_sid=127cfc&_nc_ohc=4I9NPdTYkowQ7kNvwE_p1Jh&_nc_oc=AdrxrpCu0G0jAtM9e7j52iYvQsbdZ_Fi7j1DZLnDr8n-jaLcmi-A36HSEXvMdkFJNyM&_nc_zt=23&_nc_ht=scontent.fbkk30-1.fna&_nc_gid=SQdt_Q9KXsOyxg2ukT8QHQ&_nc_ss=7b2a8&oh=00_AQRgVvkUNA9Cnx8iOIMyG109Ish7-6wwxBewK6X-iUDl8A&oe=6B18D7F4	4
61	16	https://lh3.googleusercontent.com/grass-cs/AABkmLcVnamcui50plJBUJlPHAtKje4CD6Ok3sdB2rwQKZz8ioJBQpgHpwpJSi_a5DowLw-Zi358_-mkUEo4rd5xP9PWKl4LRL7jW8pyHnUjTfbdzcceXSUlBUtcvzyuyGFvifu93S-9-w=w408-h455-k-no	1
62	16	https://c2.hongpak.in.th/media/rooms/photos/14/0513/20140513172824-528.jpg	2
63	16	https://bcdn.renthub.in.th/listing_picture/201701/20170120/pichLZSdqhiS8teE3Q9K.jpg?class=moptimized	3
64	16	https://bcdn.renthub.in.th/listing_picture/201701/20170120/8ivv7LCGpQaVkUe4vhD2.jpg?class=moptimized	4
65	17	https://bcdn.renthub.in.th/listing_picture/202604/20260421/mNJ5asQDaVyLdBqrTQa9.jpg?class=moptimized	1
69	18	https://lh3.googleusercontent.com/grass-cs/AABkmLeFeZC2dtR-HJxnFrC52CALdS6SMaQgqN344QZ4_Ccr1XRqkqaJJlkPUKiMvVWLkyWEQIEpNyBn4_7pPlcjrvlGS75TYjTHCFyoSLV505WUzI29euCqkZ0ZUeKceoveFfuzRlMYCB6GN9vw=w408-h306-k-no	1
70	18	https://bcdn.renthub.in.th/listing_picture/202604/20260421/soLL71TpkVqZ4x6o89wp.jpg?class=doptimized	2
71	18	https://bcdn.renthub.in.th/listing_picture/202604/20260421/x9VpCvkuUECM64kya6SP.jpg?class=doptimized	3
72	18	https://bcdn.renthub.in.th/listing_picture/202604/20260421/FVvXVzxRJp7teqxwEyd1.jpg?class=doptimized	4
73	19	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSx01tzIquP4vUKlxgB7HtpSiBwlDEjS4dizw5wAM7FukWnE9o5tsGoQFea&s=10	1
74	19	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHDTvFZA99IfTboAurLmjh5wyQDPvrMDRjy6ymK8Kv9OHgBjaYS82qAj3v&s=10	2
75	19	https://lh3.googleusercontent.com/gps-cs-s/ANWiy9QefE5OPWCpvJ6pzAyTn-BSsTuaWjYXZpqTYuBcrnIIBIhBTPYLIdeDyY7DxlADYAN9z8UBywyjFjwyW4cl1phigbuD4GkvAr_aVMCpa9OrF0BLSUomImGAL_IzpdFN2FXqCpMR-CQTfkM5=s1360-w1360-h1020-rw	3
76	19	https://lh3.googleusercontent.com/gps-cs-s/ANWiy9RvjWT1QRE9VxTInWyBppZkXU6kctTkpIbHlKgyq8jje3dofJsbnVaiAh4ebgBY6MDRTBLy3z4pPt2qQuXaaFq6vIqhkRAp5WoTMASQOhK2jU23Y98_CkNyATT2i0eqrY2e5TCn1x102GE=s1360-w1360-h1020-rw	4
77	20	https://bcdn.renthub.in.th/listing_picture/202402/20240205/zXDpEgbP5LGE2HcE1EmU.jpg?class=doptimized	1
78	20	https://bcdn.renthub.in.th/listing_picture/202402/20240205/VLKXPhb6HqL1rQstcjQu.jpg?class=doptimized	2
79	20	https://bcdn.renthub.in.th/listing_picture/202402/20240205/uTaJ3pfNnr9KuSRnuMS1.jpg?class=doptimized	3
80	20	https://bcdn.renthub.in.th/listing_picture/202402/20240205/kLz3fkDRQ48JPXcB7iUe.jpg?class=moptimized	4
\.


--
-- TOC entry 5108 (class 0 OID 17872)
-- Dependencies: 232
-- Data for Name: dorm_ratings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dorm_ratings (member_id, dorm_id, score, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5106 (class 0 OID 17829)
-- Dependencies: 230
-- Data for Name: dorm_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dorm_reviews (review_id, dorm_id, member_id, rating, comment, created_at) FROM stdin;
\.


--
-- TOC entry 5098 (class 0 OID 17755)
-- Dependencies: 222
-- Data for Name: dorm_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dorm_types (dorm_type_id, dorm_type_name) FROM stdin;
1	หอใน
2	หอนอก
\.


--
-- TOC entry 5107 (class 0 OID 17854)
-- Dependencies: 231
-- Data for Name: dorm_wishlists; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dorm_wishlists (member_id, dorm_id, created_at) FROM stdin;
\.


--
-- TOC entry 5102 (class 0 OID 17775)
-- Dependencies: 226
-- Data for Name: dormitories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dormitories (dorm_id, dorm_name, min_price, max_price, dorm_type_id, gender_type_id, google_map_url, contact_url, description, rating_average, rating_count, created_at, updated_at) FROM stdin;
1	หอพักทับแก้ว 1 (ปิดปรับปรุง)	8000.00	12000.00	1	2	https://maps.app.goo.gl/2ui1dpxzDvne28YL9	https://dsa.su.ac.th/dorm/?page_id=106	 หอพักทับแก้ว 1 – หอพักนักศึกษาชาย \n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพัก 2–3 คน มีเตียง ตู้เสื้อผ้า และโต๊ะอ่านหนังสือ  \n📶 มี WiFi พร้อมสิ่งอำนวยความสะดวกครบครัน  \n🚿 เครื่องซักผ้าหยอดเหรียญและตู้น้ำดื่ม  \n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 ระบบรักษาความปลอดภัยด้วยคีย์การ์ดและกล้อง CCTV \n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักภายในมหาวิทยาลัย สะดวกต่อการเรียนและการใช้ชีวิตนักศึกษา	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
2	หอพักทับแก้ว 2	8000.00	12000.00	1	2	https://maps.app.goo.gl/aYZz7RLSrs5Qb6M36	https://dsa.su.ac.th/dorm/?page_id=109	 หอพักทับแก้ว 2 – หอพักนักศึกษาชาย  \n📍  ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพัก 2–3 คน จำนวน 78 ห้อง พร้อมเตียง ตู้เสื้อผ้า และโต๊ะอ่านหนังสือ  \n📶 มี WiFi ให้บริการ  \n🚿 เครื่องซักผ้าหยอดเหรียญและตู้น้ำดื่ม  \n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 ระบบรักษาความปลอดภัยด้วยคีย์การ์ดและกล้อง CCTV \n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักภายในมหาวิทยาลัย สะดวกสบาย เหมาะสำหรับนักศึกษาชาย	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
3	หอพักทับแก้ว 3	24000.00	24000.00	1	2	https://maps.app.goo.gl/sV7UYeUFqWq3XS746	https://dsa.su.ac.th/dorm/?page_id=112	 หอพักทับแก้ว 3 – หอพักนักศึกษาชาย \n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพัก 2–3 คน จำนวน 80 ห้อง พร้อมเตียง แอร์ ตู้เสื้อผ้า และโต๊ะอ่านหนังสือ  \n📶 มี WiFi ให้บริการ  \n🚿 เครื่องซักผ้าหยอดเหรียญและตู้น้ำดื่ม  \n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 ระบบรักษาความปลอดภัยด้วยคีย์การ์ดและกล้อง CCTV \n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักภายในมหาวิทยาลัย พร้อมสิ่งอำนวยความสะดวกครบครัน สะดวกต่อการเรียนและการใช้ชีวิตนักศึกษา	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
4	หอพักเพชรรัตน์ 1	8000.00	12000.00	1	1	https://maps.app.goo.gl/JTeeoZ3gYnae28rH9	https://dsa.su.ac.th/dorm/?page_id=115	 หอพักเพชรรัตน์ 1 – หอพักนักศึกษาหญิง\n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพัก 2–3 คน จำนวน 90 ห้อง  \n📶 มี WiFi ให้บริการ  \n🚿 ห้องน้ำรวมและพื้นที่ซักรีด  \n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 มีระบบรักษาความปลอดภัย\n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักหญิงภายในมหาวิทยาลัย เดินทางสะดวก ใกล้สถานศึกษา เหมาะสำหรับนักศึกษาที่ต้องการความสะดวกในการใช้ชีวิต	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
5	หอพักเพชรรัตน์ 2	8000.00	12000.00	1	1	https://maps.app.goo.gl/ntRnbh75SHw6DtUq7	https://dsa.su.ac.th/dorm/?page_id=118	🏢 หอพักเพชรรัตน์ 2 – หอพักนักศึกษาหญิง\n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพัก 2–3 คน จำนวน 90 ห้อง\n📶 มี WiFi ให้บริการ\n🚿 ห้องน้ำรวมและพื้นที่ซักรีด\n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 มีระบบรักษาความปลอดภัย\n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักหญิงภายในมหาวิทยาลัย สะดวกต่อการเรียนและการใช้ชีวิตนักศึกษา	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
6	หอพักเพชรรัตน์ 3	8000.00	8000.00	1	1	-	https://dsa.su.ac.th/dorm/?page_id=121	🏢 หอพักเพชรรัตน์ 3 – หอพักนักศึกษาหญิง\n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพักทั้งหมด 75 ห้อง พักได้ห้องละ 2 คน\n📶 มี WiFi ให้บริการ\n🚿 ห้องน้ำรวมและพื้นที่ซักรีด\n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 มีระบบรักษาความปลอดภัย\n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักหญิงภายในมหาวิทยาลัย สะดวกต่อการเรียนและการใช้ชีวิตนักศึกษา	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
7	หอพักเพชรรัตน์ 4	8000.00	8000.00	1	1	https://maps.app.goo.gl/jafMono9hbWzLB4h6	https://dsa.su.ac.th/dorm/?page_id=124	🏢หอพักเพชรรัตน์ 4 – หอพักนักศึกษาหญิง\n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพักทั้งหมด 75 ห้อง พักได้ห้องละ 2 คน\n📶 มี WiFi ให้บริการ\n🚿 ห้องน้ำรวมและพื้นที่ซักรีด\n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 มีระบบรักษาความปลอดภัย\n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักหญิงภายในมหาวิทยาลัย ใกล้สถานศึกษา สะดวกต่อการเรียนและการใช้ชีวิตนักศึกษา	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
8	หอพักเพชรรัตน์ 5	18000.00	18000.00	1	1	https://maps.app.goo.gl/wgXsdazz3oyUD54W9	https://dsa.su.ac.th/dorm/?page_id=127	🏢 หอพักเพชรรัตน์ 5 – หอพักนักศึกษาหญิง\n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพักทั้งหมด 78 ห้อง พักได้ห้องละ 3 คน\n❄️ มีเครื่องปรับอากาศ\n📶 มี WiFi ให้บริการ\n🚿 ห้องน้ำรวมและพื้นที่ซักรีด\n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 มีระบบรักษาความปลอดภัย\n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักหญิงภายในมหาวิทยาลัย พร้อมสิ่งอำนวยความสะดวก เหมาะสำหรับนักศึกษาที่ต้องการพักอาศัยใกล้สถานศึกษา\n	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
9	หอพักเพชรรัตน์ 6	8000.00	8000.00	1	1	https://maps.app.goo.gl/9jRo2JaG8a5GnMMU9	https://dsa.su.ac.th/dorm/?page_id=130	🏢 หอพักเพชรรัตน์ 6 – หอพักนักศึกษาหญิง\n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพักทั้งหมด 91 ห้อง พักได้ห้องละ 2 คน\n📶 มี WiFi ให้บริการ\n🚿 ห้องน้ำรวมและพื้นที่ซักรีด\n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 มีระบบรักษาความปลอดภัย\n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักหญิงภายในมหาวิทยาลัย ใกล้สถานศึกษา สะดวกต่อการเรียนและการใช้ชีวิตนักศึกษา	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
10	หอพักเพชรรัตน์ 7	24000.00	24000.00	1	1	https://maps.app.goo.gl/URRbxALg35zVfcJe6	https://dsa.su.ac.th/dorm/?page_id=133	🏢 หอพักเพชรรัตน์ 7 – หอพักนักศึกษาหญิง\n📍 ภายในมหาวิทยาลัยศิลปากร วิทยาเขตพระราชวังสนามจันทร์\n🛏️ ห้องพักทั้งหมด 209 ห้อง พักได้ห้องละ 4 คน\n❄️ มีเครื่องปรับอากาศ\n📶 มี WiFi ให้บริการ\n🚿 ห้องน้ำรวมและพื้นที่ซักรีด\n🛋️ ห้องคอมมอนรูมสำหรับพักผ่อน\n🔐 มีระบบรักษาความปลอดภัย\n🕠 เปิดให้เข้า–ออก เวลา 05.30–23.30 น. ทุกวัน\n💰 ชำระค่าหอพักเป็นรายภาคการศึกษา\n✨ หอพักหญิงภายในมหาวิทยาลัย พร้อมสิ่งอำนวยความสะดวกครบครัน สะดวกต่อการเรียนและการใช้ชีวิตนักศึกษา	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
11	สมอลล์วิลล์ SmallVille Hotel	6000.00	6000.00	2	3	https://maps.app.goo.gl/9Tkzc5izbbpXxeH97	https://www.facebook.com/p/SmallVille-%E0%B8%99%E0%B8%84%E0%B8%A3%E0%B8%9B%E0%B8%90%E0%B8%A1-100064311272704/?locale=th_TH	🏢 สมอลล์วิลล์ SmallVille Hotel\n📍 เดินเพียง 2 นาทีถึง ม.ศิลปากร พระราชวังสนามจันทร์\n🛏️ เฟอร์นิเจอร์ครบ แอร์ ทีวี ตู้เย็น และเครื่องทำน้ำอุ่น\n🔐 ระบบรักษาความปลอดภัยด้วยคีย์การ์ดในลิฟต์\n🚗 มีที่จอดรถในร่มและลานจอดรถใต้ดิน\n🏪 ใกล้ 7-Eleven และธนาคารกรุงเทพ\n✨ อาคารสูง 8 ชั้น สะดวกสบาย เดินทางง่าย ใกล้มหาวิทยาลัย	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
12	หอชยาทิพย์แมนชั่น	3500.00	4500.00	2	3	https://maps.app.goo.gl/jD2NNhmARLNuSjVA7	https://www.facebook.com/profile.php?id=100067198975515&locale=th_TH	🏢 ชยาทิพย์แมนชั่น\n📍 ใกล้ ม.ศิลปากร พระราชวังสนามจันทร์ เพียง 500 เมตร\n👫 แยกอาคารชาย–หญิง\n🛏️ ห้องพักแบบพัดลมและปรับอากาศ รองรับ 2–3 คน\n🪑 มีเตียง ตู้เสื้อผ้า และโต๊ะอ่านหนังสือ\n📶 มี WiFi ให้บริการ\n🛗 มีลิฟต์ เครื่องซักผ้าหยอดเหรียญ และตู้น้ำดื่ม\n🔐 ระบบรักษาความปลอดภัยด้วยคีย์การ์ดและกล้อง CCTV\n🏪 ใกล้ 7-Eleven ร้านอาหาร และร้านค้าต่าง ๆ\n✨ ทำเลสะดวก มีสิ่งอำนวยความสะดวกครบครัน เหมาะสำหรับนักศึกษา	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
13	Unicomm ยูนิคอมม์	4900.00	5700.00	2	3	https://maps.app.goo.gl/xv5KHBxTZMw7ZBK5A	https://www.facebook.com/unicommune?_rdr	🏢 Unicomm (ยูนิคอมม์)\n📍 เดินเท้าเพียง 5 นาทีถึง ม.ศิลปากร พระราชวังสนามจันทร์\n👫 มี 3 อาคาร แบ่งเป็นหอพักหญิง หอพักหญิงพรีเมียม และหอพักชายพรีเมียม\n🛏️ เฟอร์นิเจอร์ Built-in พร้อมแอร์และเครื่องทำน้ำอุ่น\n📺 ทีวี LED 32 นิ้ว พร้อม WiFi ความเร็วสูงและเคเบิลทีวี\n💪 มีฟิตเนส ตู้กดน้ำ เครื่องซักผ้า และบริการซักรีด\n🚗 มีที่จอดรถ\n🔐 ระบบ Keycard รปภ. และกล้อง CCTV\n🏪 ใกล้ 7-Eleven ร้านอาหาร และร้านถ่ายเอกสาร\n✨ ครบครันทั้งความสะดวกสบายและความปลอดภัย	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
14	คริสตัล วิลล์ (Crystal Ville)	4500.00	6000.00	2	3	https://maps.app.goo.gl/6w1wNNZp5Hmq2PF98	https://www.facebook.com/crystalville.np	🏢 คริสตัล วิลล์ (Crystal Ville)\n📍 ใกล้ ม.ศิลปากร พระราชวังสนามจันทร์ เพียง 500–700 เมตร\n🛏️ เฟอร์นิเจอร์ครบ พร้อมแอร์และเครื่องทำน้ำอุ่น\n📺 มีทีวีและตู้เย็น\n📶 ฟรี WiFi\n🔐 รปภ. 24 ชั่วโมง พร้อมระบบ Keycard / สแกนนิ้ว และกล้อง CCTV\n🏪 ใกล้ 7-Eleven, Mini Big C และโรงพยาบาลกรุงเทพสนามจันทร์\n✨ อพาร์ตเมนต์พร้อมอยู่ ทำเลสะดวก ใกล้มหาวิทยาลัย	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
15	หอพักหญิงแอทโฮม	5000.00	8000.00	2	1	https://maps.app.goo.gl/1f1YuZ5Vzt3FndYTA	https://www.facebook.com/athomedormitory/	🏢 หอพักหญิงแอทโฮม (At Home)\n📍 เดินเพียง 5 นาทีถึง ม.ศิลปากร พระราชวังสนามจันทร์\n🛏️ มีห้องพักแบบ Studio และ Suite พร้อมเฟอร์นิเจอร์และแอร์\n🛗 มีลิฟต์และฟิตเนส\n📚 มีพื้นที่อ่านหนังสือ\n🍽️ มีร้านอาหารใต้หอพักและมินิมาร์ท\n🧺 มีร้านซักรีด เครื่องซักผ้า และตู้น้ำหยอดเหรียญ\n🚗 มีที่จอดรถฟรี\n🔐 กล้อง CCTV รอบอาคารและทุกชั้น พร้อม Keycard\n👮‍♀️ มีเจ้าหน้าที่รักษาความปลอดภัยหญิงดูแล 24 ชั่วโมง\n✨ หอพักหญิง ทำเลใกล้มหาวิทยาลัย พร้อมสิ่งอำนวยความสะดวกครบครัน 💖	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
16	หอพักกินนอน	4500.00	4500.00	2	3	https://maps.app.goo.gl/HhJD4FW2jhcWjzso6	086 886 8358	🏢 หอพักกินนอน\n📍 ใกล้ ม.ศิลปากร พระราชวังสนามจันทร์ เดินเพียง 5 นาที\n👫 หอพักรวม แบ่งอาคารชายและหญิง\n🛏️ ห้องพักโปร่ง โล่ง สบาย พร้อมเฟอร์นิเจอร์ครบ\n❄️ มีแอร์ ตู้เย็น ทีวี และเครื่องทำน้ำอุ่น\n🪑 มีเตียง ตู้เสื้อผ้า และโต๊ะ\n📶 ฟรี Internet\n🚗 มีที่จอดรถ\n✨ เดินทางสะดวก ใกล้มหาวิทยาลัย พร้อมสิ่งอำนวยความสะดวกสำหรับนักศึกษา\n📞 ติดต่อสอบถาม: 086-886-8358	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
17	หอพักทิวาลัยวิลล่า	4400.00	5000.00	2	3	https://maps.app.goo.gl/wKaHQvYBx9oeAptQ7	081 763 1735	🏢 ทิวาลัย วิลล่า\n📍 หอพักแยกชาย–หญิง หน้า ม.ศิลปากร พระราชวังสนามจันทร์\n🛏️ เฟอร์นิเจอร์ครบ แอร์ ทีวี ตู้เย็น เครื่องทำน้ำอุ่น\n📶 WiFi ส่วนตัวทุกห้อง พร้อม Router ภายในห้อง\n🛒 ใกล้ 7-Eleven 24 ชม. ศูนย์อาหารดอยคำ และร้านอาหารมากมาย\n🚐 มีคิวรถตู้ไปกรุงเทพฯ และต่างจังหวัดหน้าหอพัก\n🏬 ใกล้ Lotus’s, Big C โรงพยาบาล และองค์พระปฐมเจดีย์\n✨ ทำเลสะดวก ใกล้มหาวิทยาลัย พร้อมสิ่งอำนวยความสะดวกครบครัน\n	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
18	หอทิวาวัลย์ วิลล่า	4200.00	4400.00	2	1	https://maps.app.goo.gl/idTE9CSQfzXR22qb7	081 337 6140	🏢 ทิวาวัลย์ วิลล่า – หอพักหญิงล้วน\n📍 ทำเลดี หน้า ม.ศิลปากร พระราชวังสนามจันทร์\n🛏️ เฟอร์นิเจอร์ครบ แอร์ ทีวี ตู้เย็น เครื่องทำน้ำอุ่น\n📶 ฟรี WiFi สำหรับผู้เข้าพักทุกคน\n🍣 มีร้านอาหาร Shabu / Sushi & Dessert ใต้หอพัก\n🛒 ใกล้ 7-Eleven 24 ชม. ศูนย์อาหารดอยคำ และร้านอาหารมากมาย\n🚐 เดินทางสะดวก มีท่ารถตู้ไปกรุงเทพฯ และต่างจังหวัด\n✨ หอพักหญิงล้วน ทำเลสะดวก ใกล้มหาวิทยาลัย พร้อมสิ่งอำนวยความสะดวกครบครัน 💖	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
19	APT.28	6200.00	6200.00	2	1	https://maps.app.goo.gl/SYzF7wbLXNWofRXn7	087-7555577 , 089-9111222	🏢หอพักหญิง APT.28 - หอพักหญิงล้วน\nพร้อมเข้าอยู่กรกฎาคม 2568 นี้!\n📍ใกล้ ม.ศิลปากร (นครปฐม) แค่ 180 เมตร\n🛏️ หอใหม่ ห้องใหม่ สะอาด ปลอดภัย\n🪑 ห้องแบบ Studio ขนาด 27 ตร.ม. พร้อมเฟอร์ฯ ครบ\n📶 ฟรี WiFi / ฟิตเนส / ร้านกาแฟ / โซนอ่านหนังสือ และอีกเพียบ! อยากได้เป็นคำอธิบาย\n	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
20	หอพักบ้านศิลป์	4000.00	6000.00	2	3	https://maps.app.goo.gl/89Vwf9MEkqXbVKUc9	https://www.facebook.com/Bansilpofficial/	หอพักบ้านศิลป์ 🏡\nหอพักเอกชนสำหรับนักศึกษา ได้รับใบอนุญาตถูกต้องตาม พ.ร.บ.หอพัก พ.ศ. 2558 และเป็นหอพักเครือข่าย MOU มหาวิทยาลัยศิลปากร พระราชวังสนามจันทร์\n✨ สิ่งอำนวยความสะดวกครบครัน\n📍 เดินทางสะดวก ห่างจากมหาวิทยาลัยเพียง 300 เมตร\n🔒 มั่นใจด้วยมาตรฐานและความปลอดภัย	0.000	0	2026-11-09 22:55:56.237829	2026-11-09 22:55:56.237829
\.


--
-- TOC entry 5100 (class 0 OID 17765)
-- Dependencies: 224
-- Data for Name: gender_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.gender_types (gender_type_id, gender_type_name) FROM stdin;
1	หอหญิง
2	หอชาย
3	หอรวม
\.


--
-- TOC entry 5096 (class 0 OID 17734)
-- Dependencies: 220
-- Data for Name: members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.members (member_id, email, password_hash, display_name, avatar_url, role, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 227
-- Name: dorm_images_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dorm_images_image_id_seq', 80, true);


--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 229
-- Name: dorm_reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dorm_reviews_review_id_seq', 1, false);


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 221
-- Name: dorm_types_dorm_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dorm_types_dorm_type_id_seq', 2, true);


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 225
-- Name: dormitories_dorm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dormitories_dorm_id_seq', 20, true);


--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 223
-- Name: gender_types_gender_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.gender_types_gender_type_id_seq', 3, true);


--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 219
-- Name: members_member_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.members_member_id_seq', 1, false);


--
-- TOC entry 4927 (class 2606 OID 17822)
-- Name: dorm_images dorm_images_dorm_id_image_order_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_images
    ADD CONSTRAINT dorm_images_dorm_id_image_order_key UNIQUE (dorm_id, image_order);


--
-- TOC entry 4929 (class 2606 OID 17820)
-- Name: dorm_images dorm_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_images
    ADD CONSTRAINT dorm_images_pkey PRIMARY KEY (image_id);


--
-- TOC entry 4937 (class 2606 OID 17884)
-- Name: dorm_ratings dorm_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_ratings
    ADD CONSTRAINT dorm_ratings_pkey PRIMARY KEY (member_id, dorm_id);


--
-- TOC entry 4931 (class 2606 OID 17843)
-- Name: dorm_reviews dorm_reviews_dorm_id_member_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_reviews
    ADD CONSTRAINT dorm_reviews_dorm_id_member_id_key UNIQUE (dorm_id, member_id);


--
-- TOC entry 4933 (class 2606 OID 17841)
-- Name: dorm_reviews dorm_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_reviews
    ADD CONSTRAINT dorm_reviews_pkey PRIMARY KEY (review_id);


--
-- TOC entry 4917 (class 2606 OID 17763)
-- Name: dorm_types dorm_types_dorm_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_types
    ADD CONSTRAINT dorm_types_dorm_type_name_key UNIQUE (dorm_type_name);


--
-- TOC entry 4919 (class 2606 OID 17761)
-- Name: dorm_types dorm_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_types
    ADD CONSTRAINT dorm_types_pkey PRIMARY KEY (dorm_type_id);


--
-- TOC entry 4935 (class 2606 OID 17861)
-- Name: dorm_wishlists dorm_wishlists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_wishlists
    ADD CONSTRAINT dorm_wishlists_pkey PRIMARY KEY (member_id, dorm_id);


--
-- TOC entry 4925 (class 2606 OID 17797)
-- Name: dormitories dormitories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dormitories
    ADD CONSTRAINT dormitories_pkey PRIMARY KEY (dorm_id);


--
-- TOC entry 4921 (class 2606 OID 17773)
-- Name: gender_types gender_types_gender_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gender_types
    ADD CONSTRAINT gender_types_gender_type_name_key UNIQUE (gender_type_name);


--
-- TOC entry 4923 (class 2606 OID 17771)
-- Name: gender_types gender_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gender_types
    ADD CONSTRAINT gender_types_pkey PRIMARY KEY (gender_type_id);


--
-- TOC entry 4915 (class 2606 OID 17753)
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (member_id);


--
-- TOC entry 4940 (class 2606 OID 17823)
-- Name: dorm_images dorm_images_dorm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_images
    ADD CONSTRAINT dorm_images_dorm_id_fkey FOREIGN KEY (dorm_id) REFERENCES public.dormitories(dorm_id) ON DELETE CASCADE;


--
-- TOC entry 4945 (class 2606 OID 17890)
-- Name: dorm_ratings dorm_ratings_dorm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_ratings
    ADD CONSTRAINT dorm_ratings_dorm_id_fkey FOREIGN KEY (dorm_id) REFERENCES public.dormitories(dorm_id) ON DELETE CASCADE;


--
-- TOC entry 4946 (class 2606 OID 17885)
-- Name: dorm_ratings dorm_ratings_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_ratings
    ADD CONSTRAINT dorm_ratings_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE CASCADE;


--
-- TOC entry 4941 (class 2606 OID 17844)
-- Name: dorm_reviews dorm_reviews_dorm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_reviews
    ADD CONSTRAINT dorm_reviews_dorm_id_fkey FOREIGN KEY (dorm_id) REFERENCES public.dormitories(dorm_id) ON DELETE CASCADE;


--
-- TOC entry 4942 (class 2606 OID 17849)
-- Name: dorm_reviews dorm_reviews_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_reviews
    ADD CONSTRAINT dorm_reviews_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE CASCADE;


--
-- TOC entry 4943 (class 2606 OID 17867)
-- Name: dorm_wishlists dorm_wishlists_dorm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_wishlists
    ADD CONSTRAINT dorm_wishlists_dorm_id_fkey FOREIGN KEY (dorm_id) REFERENCES public.dormitories(dorm_id) ON DELETE CASCADE;


--
-- TOC entry 4944 (class 2606 OID 17862)
-- Name: dorm_wishlists dorm_wishlists_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dorm_wishlists
    ADD CONSTRAINT dorm_wishlists_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.members(member_id) ON DELETE CASCADE;


--
-- TOC entry 4938 (class 2606 OID 17798)
-- Name: dormitories dormitories_dorm_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dormitories
    ADD CONSTRAINT dormitories_dorm_type_id_fkey FOREIGN KEY (dorm_type_id) REFERENCES public.dorm_types(dorm_type_id);


--
-- TOC entry 4939 (class 2606 OID 17803)
-- Name: dormitories dormitories_gender_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dormitories
    ADD CONSTRAINT dormitories_gender_type_id_fkey FOREIGN KEY (gender_type_id) REFERENCES public.gender_types(gender_type_id);


--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


-- Completed on 2026-11-12 22:33:02

--
-- PostgreSQL database dump complete
--

\unrestrict 09Cnbw4QvVOVWGchQxrAMv9ERZz8p6sDp3O04PUmNh5iMdP54JwrR6QVEmlZBmz

