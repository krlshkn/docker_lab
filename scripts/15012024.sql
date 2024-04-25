--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

-- Started on 2024-01-15 08:49:14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = on;

SET SESSION AUTHORIZATION 'postgres';

--
-- TOC entry 3529 (class 1262 OID 24829)
-- Name: Pottery; Type: DATABASE; Schema: -; Owner: postgres
--



SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = on;

SET SESSION AUTHORIZATION 'pg_database_owner';

--
-- TOC entry 3530 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


SET SESSION AUTHORIZATION 'postgres';

--
-- TOC entry 908 (class 1247 OID 25084)
-- Name: fio; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."fio" AS (
	"first_name" "text",
	"last_name" "text",
	"patronymic" "text"
);


--
-- TOC entry 917 (class 1247 OID 25097)
-- Name: product_info; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."product_info" AS (
	"type" "text",
	"name" "text",
	"price" integer
);


--
-- TOC entry 911 (class 1247 OID 25087)
-- Name: program_full; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."program_full" AS (
	"title" "text",
	"description" "text",
	"price" integer
);


--
-- TOC entry 914 (class 1247 OID 25090)
-- Name: program_info; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."program_info" AS (
	"title" "text",
	"description" "text",
	"price" integer
);


--
-- TOC entry 246 (class 1255 OID 25077)
-- Name: change_members(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE "public"."change_members"(IN "rec_id" integer, IN "memb" integer)
    LANGUAGE "plpgsql"
    AS $$
begin
	if memb <= 0 then
		raise exception 'memers must be positive';
	end if;

	if not exists(select * from record where record.id = rec_id) then
		raise exception 'an record with such an ID was not found';
	end if;
	
	update record
	set members = memb
	where record.id = rec_id;
end; $$;


--
-- TOC entry 248 (class 1255 OID 25080)
-- Name: check_orders_customer(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."check_orders_customer"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
	if (select status from account where account.id = new.customer) != 'действителен' then
		raise exception 'аккаунт не действителен';
	end if;
	return new;
end;$$;


--
-- TOC entry 242 (class 1255 OID 25075)
-- Name: delete_records("date", "date"); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE "public"."delete_records"(IN "date1" "date", IN "date2" "date")
    LANGUAGE "plpgsql"
    AS $$
begin
	if date1 > date2 then
		raise exception 'date2 must be bigger than date1' ;
	end if;
						
	delete from record where
	date <= date2 and date >= date1;
end; $$;


--
-- TOC entry 249 (class 1255 OID 25094)
-- Name: get_program_title("public"."program_info"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."get_program_title"("p" "public"."program_info") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
BEGIN 
	RETURN p.title;
END;
$$;


--
-- TOC entry 241 (class 1255 OID 25074)
-- Name: increase_prices(real); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE "public"."increase_prices"(IN real)
    LANGUAGE "plpgsql"
    AS $_$
begin
	update product
	set price = price * $1;
end;$_$;


--
-- TOC entry 243 (class 1255 OID 25069)
-- Name: master_record_dates("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."master_record_dates"("last_name" "text") RETURNS "date"[]
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
	cur CURSOR FOR SELECT * FROM worker WHERE worker.last_name = $1 AND post = 2;
	dates date[];
BEGIN
	FOR r IN cur LOOP 
		dates = array(select date from record where r.id = record.master);
	END LOOP;
	return dates;
END;
$_$;


--
-- TOC entry 250 (class 1255 OID 25100)
-- Name: money_for_all_date(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."money_for_all_date"() RETURNS TABLE("date" "date", "money" integer)
    LANGUAGE "plpgsql"
    AS $$
	BEGIN
SELECT date, SUM(price) from orderr
GROUP BY date;
END;
$$;


--
-- TOC entry 251 (class 1255 OID 25101)
-- Name: money_for_all_dates(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."money_for_all_dates"() RETURNS TABLE("date" "date", "money" integer)
    LANGUAGE "plpgsql"
    AS $$
	BEGIN
SELECT orderr.date, SUM(price) from orderr
GROUP BY orderr.date;
END;
$$;


--
-- TOC entry 247 (class 1255 OID 25078)
-- Name: post_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."post_delete"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
	if exists (select * from worker where worker.post = old.id) then
		raise exception 'на этой должности есть работники';
	end if;
	return old;
end;$$;


--
-- TOC entry 245 (class 1255 OID 25073)
-- Name: product_for_budget(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."product_for_budget"("spec" integer) RETURNS TABLE("id" integer, "type" "text", "name" "text", "price" integer)
    LANGUAGE "sql"
    AS $$
SELECT id, type, name, price FROM product 
WHERE (price <= spec)
ORDER BY price DESC
LIMIT 5;
$$;


--
-- TOC entry 244 (class 1255 OID 25072)
-- Name: product_for_price(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."product_for_price"("spec" integer) RETURNS TABLE("id" integer, "type" "text", "name" "text", "price" integer)
    LANGUAGE "sql"
    AS $$
SELECT id, type, name, price FROM product 
WHERE (price <= spec)
$$;


--
-- TOC entry 254 (class 1255 OID 25104)
-- Name: product_in_date("public"."product_info"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."product_in_date"("p" "public"."product_info") RETURNS TABLE("date" "date", "count" integer)
    LANGUAGE "plpgsql"
    AS $$
	BEGIN
SELECT orderr.date, count(id) from orderr
where product_info = p
GROUP BY orderr.date;
END;
$$;


--
-- TOC entry 255 (class 1255 OID 25182)
-- Name: program_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."program_status"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
return new;
END; 
$$;


--
-- TOC entry 253 (class 1255 OID 25103)
-- Name: ptype_in_date("public"."product_info"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."ptype_in_date"("p" "public"."product_info") RETURNS TABLE("date" "date", "count" integer)
    LANGUAGE "plpgsql"
    AS $$
	BEGIN
SELECT orderr.date, count(id) from orderr
where product_info = p
GROUP BY orderr.date;
END;
$$;


--
-- TOC entry 252 (class 1255 OID 25102)
-- Name: type_in_date("public"."product_info"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."type_in_date"("p" "public"."product_info") RETURNS TABLE("date" "date", "count" integer)
    LANGUAGE "plpgsql"
    AS $$
	BEGIN
SELECT date, count(id) from orderr
where product_info = p
GROUP BY date;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- TOC entry 215 (class 1259 OID 24841)
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."account" (
    "id" integer NOT NULL,
    "role" character varying(20) NOT NULL,
    "status" character varying(20) DEFAULT 'действителен'::character varying,
    "login" character varying(20) NOT NULL,
    "pwd" character varying(20) NOT NULL,
    "first_name" character varying(20) NOT NULL,
    "last_name" character varying(20) NOT NULL,
    "patronymic" character varying(30),
    "gender" character varying(10) NOT NULL,
    "birthday" "date" NOT NULL,
    "telephone" character varying(12),
    CONSTRAINT "account_birthday_check" CHECK ((("birthday" > '1923-01-01'::"date") AND ("birthday" < CURRENT_DATE))),
    CONSTRAINT "account_gender_check" CHECK (((("gender")::"text" = 'м'::"text") OR (("gender")::"text" = 'ж'::"text")))
);


--
-- TOC entry 214 (class 1259 OID 24840)
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."account_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3531 (class 0 OID 0)
-- Dependencies: 214
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."account_id_seq" OWNED BY "public"."account"."id";


--
-- TOC entry 219 (class 1259 OID 24870)
-- Name: orderr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."orderr" (
    "id" integer NOT NULL,
    "date" "date" NOT NULL,
    "customer" integer,
    "product" integer,
    "status" character varying(20) DEFAULT 'в обработке'::character varying,
    "note" "text",
    "product_info" "public"."product_info",
    "account" integer,
    CONSTRAINT "orderr_date_check" CHECK ((("date" > '2022-01-01'::"date") AND ("date" <= CURRENT_DATE)))
);


--
-- TOC entry 218 (class 1259 OID 24869)
-- Name: orderr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."orderr_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3532 (class 0 OID 0)
-- Dependencies: 218
-- Name: orderr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."orderr_id_seq" OWNED BY "public"."orderr"."id";


--
-- TOC entry 223 (class 1259 OID 24951)
-- Name: post; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."post" (
    "id" integer NOT NULL,
    "title" character varying(30) NOT NULL,
    "salary" integer NOT NULL,
    "description" "text",
    CONSTRAINT "post_salary_check" CHECK (("salary" > 0))
);


--
-- TOC entry 222 (class 1259 OID 24950)
-- Name: post_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."post_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3533 (class 0 OID 0)
-- Dependencies: 222
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."post_id_seq" OWNED BY "public"."post"."id";


--
-- TOC entry 217 (class 1259 OID 24855)
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."product" (
    "id" integer NOT NULL,
    "type" character varying(20) NOT NULL,
    "name" character varying(20) NOT NULL,
    "length" integer NOT NULL,
    "width" integer NOT NULL,
    "height" integer DEFAULT 1,
    "price" integer NOT NULL,
    "picture" character varying(50) NOT NULL,
    "status" character varying(20) DEFAULT 'в продаже'::character varying,
    "note" "text",
    "add1" character varying(50),
    "add2" character varying(50),
    "add3" character varying(50),
    "color" character varying(50),
    "design" character varying(50),
    CONSTRAINT "product_height_check" CHECK (("height" > 0)),
    CONSTRAINT "product_length_check" CHECK (("length" > 0)),
    CONSTRAINT "product_price_check" CHECK (("price" > 0)),
    CONSTRAINT "product_width_check" CHECK (("width" > 0))
);


--
-- TOC entry 237 (class 1259 OID 25119)
-- Name: price_type_ranking; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."price_type_ranking" AS
 SELECT "product"."type",
    "product"."price",
    "product"."name",
    "dense_rank"() OVER (PARTITION BY "product"."type" ORDER BY "product"."price") AS "dense_rank"
   FROM "public"."product";


--
-- TOC entry 216 (class 1259 OID 24854)
-- Name: product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."product_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3534 (class 0 OID 0)
-- Dependencies: 216
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."product_id_seq" OWNED BY "public"."product"."id";


--
-- TOC entry 221 (class 1259 OID 24891)
-- Name: program; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."program" (
    "id" integer NOT NULL,
    "title" character varying(30) NOT NULL,
    "description" "text",
    "max_members" integer NOT NULL,
    "price" integer NOT NULL,
    "picture" character varying(50),
    "status" character varying(20) DEFAULT 'есть записи'::character varying,
    CONSTRAINT "programm_max_members_check" CHECK ((("max_members" > 0) AND ("max_members" < 10))),
    CONSTRAINT "programm_price_check" CHECK (("price" > 0))
);


--
-- TOC entry 220 (class 1259 OID 24890)
-- Name: programm_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."programm_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3535 (class 0 OID 0)
-- Dependencies: 220
-- Name: programm_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."programm_id_seq" OWNED BY "public"."program"."id";


--
-- TOC entry 227 (class 1259 OID 24989)
-- Name: record; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."record" (
    "id" integer NOT NULL,
    "program" integer NOT NULL,
    "date" "date" NOT NULL,
    "time" integer NOT NULL,
    "master" integer NOT NULL,
    "assistant" integer,
    "customer" integer NOT NULL,
    "members" integer NOT NULL,
    "program_info" "public"."program_info",
    CONSTRAINT "record_date_check" CHECK (("date" > '2022-01-01'::"date")),
    CONSTRAINT "record_time_check" CHECK ((("time" >= 9) AND ("time" <= 19)))
);


--
-- TOC entry 226 (class 1259 OID 24988)
-- Name: record_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."record_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3536 (class 0 OID 0)
-- Dependencies: 226
-- Name: record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."record_id_seq" OWNED BY "public"."record"."id";


--
-- TOC entry 225 (class 1259 OID 24961)
-- Name: worker; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."worker" (
    "id" integer NOT NULL,
    "first_name" character varying(20) NOT NULL,
    "last_name" character varying(20) NOT NULL,
    "patronymic" character varying(30),
    "passport" character varying(10) NOT NULL,
    "gender" character varying(10) NOT NULL,
    "birthday" "date" NOT NULL,
    "telephone" character varying(12),
    "post" integer,
    "fio" "public"."fio",
    "kurator" integer,
    CONSTRAINT "worker_birthday_check" CHECK ((("birthday" > '1923-01-01'::"date") AND ("birthday" < CURRENT_DATE))),
    CONSTRAINT "worker_gender_check" CHECK (((("gender")::"text" = 'м'::"text") OR (("gender")::"text" = 'ж'::"text")))
);


--
-- TOC entry 239 (class 1259 OID 25145)
-- Name: vw_cubeeee; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."vw_cubeeee" AS
 SELECT "worker"."fio",
    "program"."title",
    "sum"("program"."price") AS "sum"
   FROM (("public"."worker"
     JOIN "public"."record" ON (("record"."master" = "worker"."id")))
     JOIN "public"."program" ON (("record"."program" = "program"."id")))
  GROUP BY CUBE("worker"."fio", "program"."title");


--
-- TOC entry 235 (class 1259 OID 25110)
-- Name: vw_first_record; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."vw_first_record" AS
 SELECT "program"."title",
    "first_value"("record"."date") OVER (PARTITION BY "record"."date" ORDER BY "program"."title") AS "first_value"
   FROM ("public"."record"
     JOIN "public"."program" ON (("record"."program" = "program"."id")));


--
-- TOC entry 240 (class 1259 OID 25176)
-- Name: vw_kurators; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."vw_kurators" AS
 WITH RECURSIVE "rec"("id", "kurator") AS (
         SELECT "worker"."id",
            "worker"."kurator"
           FROM "public"."worker"
          WHERE ("worker"."kurator" IS NULL)
        UNION ALL
         SELECT "sot"."id",
            "sot"."kurator"
           FROM ("public"."worker" "sot"
             JOIN "rec" ON (("rec"."id" = "sot"."kurator")))
        )
 SELECT "w"."id" AS "w_id",
    "w"."last_name" AS "w_last_name",
    "p1"."title" AS "w_post",
    "k"."id" AS "k_id",
    "k"."last_name" AS "k_last_name",
    "p2"."title" AS "k_post"
   FROM (((("rec" "r"
     JOIN "public"."worker" "w" ON (("r"."id" = "w"."id")))
     LEFT JOIN "public"."worker" "k" ON (("r"."kurator" = "k"."id")))
     JOIN "public"."post" "p1" ON (("p1"."id" = "w"."post")))
     LEFT JOIN "public"."post" "p2" ON (("p2"."id" = "k"."post")));


--
-- TOC entry 238 (class 1259 OID 25140)
-- Name: vw_master_records; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."vw_master_records" AS
 SELECT "worker"."fio",
    "program"."title",
    "sum"("program"."price") OVER (PARTITION BY "record"."master") AS "sum"
   FROM (("public"."worker"
     JOIN "public"."record" ON (("record"."master" = "worker"."id")))
     JOIN "public"."program" ON (("record"."program" = "program"."id")));


--
-- TOC entry 230 (class 1259 OID 25053)
-- Name: vw_max_check_price; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."vw_max_check_price" AS
 SELECT "product"."type",
    "max"("product"."price") AS "макс_цена"
   FROM ("public"."orderr"
     JOIN "public"."product" ON (("orderr"."product" = "product"."id")))
  GROUP BY "product"."type"
  ORDER BY ("max"("product"."price")) DESC;


--
-- TOC entry 229 (class 1259 OID 25049)
-- Name: vw_max_salary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."vw_max_salary" AS
 SELECT "post"."title",
    "max"("post"."salary") AS "макс_ЗП"
   FROM ("public"."worker"
     JOIN "public"."post" ON (("worker"."post" = "post"."id")))
  GROUP BY "post"."title"
  ORDER BY ("max"("post"."salary")) DESC;


--
-- TOC entry 236 (class 1259 OID 25115)
-- Name: vw_program_record; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."vw_program_record" AS
 SELECT "program"."title" AS "program",
    "count"("record"."id") AS "records"
   FROM ("public"."program"
     JOIN "public"."record" ON (("record"."program" = "program"."id")))
  GROUP BY CUBE("program"."title");


--
-- TOC entry 228 (class 1259 OID 25045)
-- Name: vw_worker_post; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."vw_worker_post" AS
 SELECT "post"."title",
    "count"("post"."title") AS "кол_во_должностей"
   FROM ("public"."post"
     JOIN "public"."worker" ON (("worker"."post" = "post"."id")))
  GROUP BY ROLLUP("post"."title");


--
-- TOC entry 224 (class 1259 OID 24960)
-- Name: worker_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."worker_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3537 (class 0 OID 0)
-- Dependencies: 224
-- Name: worker_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."worker_id_seq" OWNED BY "public"."worker"."id";


--
-- TOC entry 3270 (class 2604 OID 24844)
-- Name: account id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."account" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."account_id_seq"'::"regclass");


--
-- TOC entry 3275 (class 2604 OID 24873)
-- Name: orderr id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orderr" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."orderr_id_seq"'::"regclass");


--
-- TOC entry 3279 (class 2604 OID 24954)
-- Name: post id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."post" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."post_id_seq"'::"regclass");


--
-- TOC entry 3272 (class 2604 OID 24858)
-- Name: product id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."product_id_seq"'::"regclass");


--
-- TOC entry 3277 (class 2604 OID 24894)
-- Name: program id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."program" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."programm_id_seq"'::"regclass");


--
-- TOC entry 3281 (class 2604 OID 24992)
-- Name: record id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."record" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."record_id_seq"'::"regclass");


--
-- TOC entry 3280 (class 2604 OID 24964)
-- Name: worker id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."worker" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."worker_id_seq"'::"regclass");


--
-- TOC entry 3511 (class 0 OID 24841)
-- Dependencies: 215
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (22, 'заказчик', 'действителен', 'svetlana79', 'pwd456', 'Светлана', 'Владимирова', 'Олеговна', 'ж', '1979-01-31', '89369197012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (23, 'заказчик', 'действителен', 'ilya86', 'pwd789', 'Илья', 'Егоров', 'Игоревич', 'м', '1986-12-08', '89369258092') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (24, 'заказчик', 'действителен', 'anastasiya94', 'pwd258', 'Анастасия', 'Артемьева', 'Александровна', 'ж', '1994-11-11', '89852149012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (25, 'заказчик', 'действителен', 'stanislav84', 'pwd147', 'Станислав', 'Ильин', 'Дмитриевич', 'м', '1984-10-27', '89399147012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (26, 'заказчик', 'действителен', 'oksana89', 'pwd369', 'Оксана', 'Станиславова', 'Ивановна', 'ж', '1989-09-05', '89147258912') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (27, 'заказчик', 'действителен', 'konstantin91', 'pwd123', 'Константин', 'Максимов', 'Алексеевич', 'м', '1991-08-13', '89369947012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (28, 'заказчик', 'действителен', 'yuliana80', 'pwd456', 'Юлиана', 'Васильева', 'Михайловна', 'ж', '1980-02-29', '89369259012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (29, 'заказчик', 'действителен', 'maxim78', 'pwd789', 'Максим', 'Федоров', 'Константинович', 'м', '1978-11-14', '89859147012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (95, 'заказчик', 'действителен', 'a', 's', 'Саша', 'Белый', 'null', 'м', '1991-01-01', 'null') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (97, 'гость', 'действителен', 'guest', 'guest', 'Гость', 'Уважаемый', NULL, 'м', '1991-01-01', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (1, 'админ', 'действителен', 'admin2003', 'pwd123', 'Иван', 'Иванов', 'Иванович', 'м', '1990-05-15', '89456789019') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (2, 'заказчик', 'действителен', 'maria88', 'pwd456', 'Мария', 'Петрова', 'Ивановна', 'ж', '1988-10-20', '89654321092') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (3, 'заказчик', 'действителен', 'petr75', 'pwd789', 'Петр', 'Сидоров', 'Александрович', 'м', '1975-12-17', '89193789012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (4, 'заказчик', 'действителен', 'elena80', 'pwd147', 'Елена', 'Белякова', 'Петровна', 'ж', '1980-03-25', '89456129012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (5, 'заказчик', 'действителен', 'alex85', 'pwd258', 'Алексей', 'Иванов', 'Павлович', 'м', '1985-08-30', '89399741012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (6, 'заказчик', 'действителен', 'olga95', 'pwd369', 'Ольга', 'Федорова', 'Сергеевна', 'ж', '1995-04-10', '89885214901') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (7, 'заказчик', 'действителен', 'sergey70', 'pwd147', 'Сергей', 'Павлов', 'Алексеевич', 'м', '1970-07-05', '89725836901') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (8, 'заказчик', 'действителен', 'natalya78', 'pwd369', 'Наталья', 'Сергеева', 'Игоревна', 'ж', '1978-01-22', '89836914709') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (9, 'заказчик', 'действителен', 'igor92', 'pwd456', 'Игорь', 'Александров', 'Семенович', 'м', '1992-09-18', '89985236901') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (10, 'заказчик', 'действителен', 'anna83', 'pwd123', 'Анна', 'Алексеева', 'Ивановна', 'ж', '1983-11-13', '89147258012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (11, 'заказчик', 'действителен', 'dmitriy89', 'pwd789', 'Дмитрий', 'Семенов', 'Алексеевич', 'м', '1989-06-14', '88936919703') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (12, 'заказчик', 'действителен', 'evgeniya96', 'pwd258', 'Евгения', 'Дмитриева', 'Сергеевна', 'ж', '1996-02-12', '89739985201') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (13, 'заказчик', 'действителен', 'artem74', 'pwd147', 'Артем', 'Андреев', 'Игоревич', 'м', '1974-04-28', '89985214791') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (14, 'заказчик', 'действителен', 'yulia76', 'pwd369', 'Юлия', 'Андреева', 'Петровна', 'ж', '1976-05-19', '88996914701') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (15, 'заказчик', 'действителен', 'alexandr81', 'pwd123', 'Александр', 'Тимофеев', 'Сергеевич', 'м', '1981-09-24', '89914925801') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (16, 'заказчик', 'действителен', 'ekaterina88', 'pwd456', 'Екатерина', 'Юрьева', 'Александровна', 'ж', '1988-10-30', '89736985901') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (17, 'заказчик', 'действителен', 'andrey93', 'pwd789', 'Андрей', 'Федосеев', 'Иванович', 'м', '1993-12-05', '89369149012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (18, 'заказчик', 'действителен', 'margarita87', 'pwd258', 'Маргарита', 'Кузнецова', 'Петровна', 'ж', '1987-03-16', '89147259022') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (20, 'заказчик', 'действителен', 'tatyana77', 'pwd369', 'Татьяна', 'Николаева', 'Николаевна', 'ж', '1977-07-28', '89258369012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (21, 'заказчик', 'действителен', 'vladimir73', 'pwd123', 'Владимир', 'Игорев', 'Олегович', 'м', '1973-06-23', '89147259012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (19, 'заказчик', 'не действителен', 'anton82', 'pwd147', 'Антон', 'Сергеев', 'Антонович', 'м', '1982-08-21', '852399147012') ON CONFLICT DO NOTHING;
INSERT INTO "public"."account" ("id", "role", "status", "login", "pwd", "first_name", "last_name", "patronymic", "gender", "birthday", "telephone") VALUES (99, 'заказчик', NULL, 'guseva', 'sveta', 'Светлана', 'Гусева', 'null', 'ж', '1998-05-29', 'undefined') ON CONFLICT DO NOTHING;


--
-- TOC entry 3515 (class 0 OID 24870)
-- Dependencies: 219
-- Data for Name: orderr; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (50, '2023-05-19', 19, 18, 'выполнен', 'в пакете', '(чашечка,product2,242)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (33, '2022-01-02', 2, 1, 'выполнен', NULL, '(тарелочка,"с зайцами",275)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (34, '2022-02-03', 3, 2, 'выполнен', NULL, '(тарелочка,"с радугой",330)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (35, '2022-03-04', 4, 3, 'выполнен', NULL, '(тарелочка,"тарелка десертная",220)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (36, '2022-04-05', 5, 4, 'выполнен', NULL, '(тарелочка,"тарелка суповая",308)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (37, '2022-05-06', 6, 5, 'выполнен', NULL, '(тарелочка,"тарелка для пасты",352)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (38, '2022-06-07', 7, 6, 'выполнен', NULL, '(тарелочка,"тарелка для закусок",231)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (39, '2022-07-08', 8, 7, 'выполнен', NULL, '(тарелочка,"тарелка плоская",286)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (40, '2022-08-09', 9, 8, 'выполнен', NULL, '(тарелочка,"с лимончиками",297)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (41, '2022-09-10', 10, 9, 'выполнен', NULL, '(тарелочка,"тарелка овальная",319)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (42, '2022-10-11', 11, 10, 'выполнен', NULL, '(тарелочка,авакадо,341)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (43, '2022-11-12', 12, 11, 'выполнен', NULL, '(тарелочка,"со свинками",264)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (44, '2022-12-13', 13, 12, 'выполнен', NULL, '(тарелочка,"тарелка терракотовая",242)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (45, '2023-01-14', 14, 13, 'выполнен', NULL, '(тарелочка,"тарелка мелкая",220)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (46, '2023-01-15', 15, 14, 'выполнен', NULL, '(тарелочка,"тарелка граненая",286)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (47, '2023-02-16', 16, 15, 'выполнен', NULL, '(тарелочка,"тарелка рифленая",297)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (48, '2023-03-17', 17, 16, 'выполнен', NULL, '(тарелочка,"тарелка позолоченная",385)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (49, '2023-04-18', 18, 17, 'выполнен', NULL, '(чашечка,product1,275)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (51, '2023-06-20', 20, 19, 'выполнен', NULL, '(чашечка,product3,253)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (52, '2023-09-21', 21, 20, 'выполнен', NULL, '(чашечка,product4,264)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (53, '2023-10-02', 22, 21, 'выполнен', NULL, '(чашечка,product5,286)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (54, '2023-10-13', 23, 22, 'выполнен', NULL, '(чашечка,product6,297)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (55, '2023-10-20', 24, 23, 'выполнен', NULL, '(чашечка,product7,308)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (56, '2023-11-05', 25, 24, 'выполнен', NULL, '(чашечка,product8,319)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (57, '2023-11-16', 26, 25, 'выполнен', NULL, '(чашечка,product9,330)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (58, '2023-11-27', 27, 26, 'готов к выдаче', NULL, '(чашечка,product10,341)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (59, '2023-12-03', 28, 27, 'готов к выдаче', NULL, '(чашечка,product11,352)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (60, '2023-12-09', 29, 28, 'идет сборка', NULL, '(чашечка,product12,363)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (61, '2023-12-10', 29, 28, 'идет сборка', NULL, '(чашечка,product12,363)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (62, '2023-12-12', 29, 28, 'идет сборка', NULL, '(чашечка,product12,363)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (63, '2023-12-17', 29, 28, 'в обработке', NULL, '(чашечка,product12,363)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."orderr" ("id", "date", "customer", "product", "status", "note", "product_info", "account") VALUES (64, '2023-12-19', 29, 29, 'в обработке', NULL, '(чашечка,product13,374)', NULL) ON CONFLICT DO NOTHING;


--
-- TOC entry 3519 (class 0 OID 24951)
-- Dependencies: 223
-- Data for Name: post; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."post" ("id", "title", "salary", "description") VALUES (1, 'администратор', 30000, 'есть свой аккаунт') ON CONFLICT DO NOTHING;
INSERT INTO "public"."post" ("id", "title", "salary", "description") VALUES (3, 'ассистент', 30000, 'помощник мастера') ON CONFLICT DO NOTHING;
INSERT INTO "public"."post" ("id", "title", "salary", "description") VALUES (4, 'продавец', 30000, 'продавать должен') ON CONFLICT DO NOTHING;
INSERT INTO "public"."post" ("id", "title", "salary", "description") VALUES (5, 'управляющий', 35000, 'надо управлять всем коллективом') ON CONFLICT DO NOTHING;
INSERT INTO "public"."post" ("id", "title", "salary", "description") VALUES (6, 'менеджер', 33000, 'то что обычно делат менеджеры') ON CONFLICT DO NOTHING;
INSERT INTO "public"."post" ("id", "title", "salary", "description") VALUES (7, 'контент-мейкер', 28000, 'должен делать контент') ON CONFLICT DO NOTHING;
INSERT INTO "public"."post" ("id", "title", "salary", "description") VALUES (2, 'мастер', 44000, 'самая высокооплачиваемая должность, потому что на мастерах все и держится') ON CONFLICT DO NOTHING;


--
-- TOC entry 3513 (class 0 OID 24855)
-- Dependencies: 217
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (2, 'тарелочка', 'с радугой', 18, 18, 1, 330, 'plate2.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (3, 'тарелочка', 'тарелка десертная', 10, 10, 1, 220, 'plate3.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (4, 'тарелочка', 'тарелка суповая', 20, 20, 1, 308, 'plate4.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (5, 'тарелочка', 'тарелка для пасты', 17, 17, 1, 352, 'plate5.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (6, 'тарелочка', 'тарелка для закусок', 12, 12, 1, 231, 'plate6.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (7, 'тарелочка', 'тарелка плоская', 16, 16, 1, 286, 'plate7.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (8, 'тарелочка', 'с лимончиками', 19, 19, 1, 297, 'plate8.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (9, 'тарелочка', 'тарелка овальная', 16, 18, 1, 319, 'plate9.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (10, 'тарелочка', 'авакадо', 20, 15, 1, 341, 'plate10.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (11, 'тарелочка', 'со свинками', 18, 17, 1, 264, 'plate11.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (12, 'тарелочка', 'тарелка терракотовая', 14, 14, 1, 242, 'plate12.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (13, 'тарелочка', 'тарелка мелкая', 10, 8, 1, 220, 'plate13.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (14, 'тарелочка', 'тарелка граненая', 16, 14, 1, 286, 'plate14.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (15, 'тарелочка', 'тарелка рифленая', 17, 16, 1, 297, 'plate15.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (16, 'тарелочка', 'тарелка позолоченная', 19, 18, 1, 385, 'plate16.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (17, 'чашечка', 'product1', 10, 5, 10, 275, 'image1.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (18, 'чашечка', 'product2', 9, 6, 11, 242, 'image2.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (19, 'чашечка', 'product3', 8, 7, 12, 253, 'image3.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (20, 'чашечка', 'product4', 7, 8, 13, 264, 'image4.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (21, 'чашечка', 'product5', 6, 9, 14, 286, 'image5.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (22, 'чашечка', 'product6', 5, 10, 15, 297, 'image6.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (23, 'чашечка', 'product7', 10, 5, 16, 308, 'image7.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (24, 'чашечка', 'product8', 9, 6, 17, 319, 'image8.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (25, 'чашечка', 'product9', 8, 7, 18, 330, 'image9.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (26, 'чашечка', 'product10', 7, 8, 19, 341, 'image10.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (27, 'чашечка', 'product11', 6, 9, 20, 352, 'image11.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (28, 'чашечка', 'product12', 10, 5, 10, 363, 'image12.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (29, 'чашечка', 'product13', 9, 6, 11, 374, 'image13.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (30, 'чашечка', 'product14', 8, 7, 12, 385, 'image14.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (31, 'чашечка', 'product15', 7, 8, 13, 396, 'image15.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (32, 'чашечка', 'product16', 6, 9, 14, 407, 'image16.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (33, 'чайная парочка', 'любовная', 10, 10, 10, 495, 'image1.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (34, 'чайная парочка', 'друзья', 11, 11, 11, 462, 'image2.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (35, 'чайная парочка', 'с лимонами', 12, 12, 12, 473, 'image3.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (36, 'чайная парочка', 'в цветочек', 13, 13, 13, 484, 'image4.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (37, 'чайная парочка', 'в полоску', 14, 14, 14, 506, 'image5.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (38, 'чайная парочка', 'в точку', 15, 15, 15, 517, 'image6.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (39, 'чайная парочка', 'однотонная', 16, 16, 16, 528, 'image7.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (40, 'чайная парочка', 'в кружок', 17, 17, 17, 539, 'image8.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (41, 'чайная парочка', 'в клетку', 18, 18, 18, 550, 'image9.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (42, 'чайная парочка', 'с листьями', 19, 19, 19, 561, 'image10.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (43, 'чайная парочка', 'зверята', 20, 20, 20, 572, 'image11.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (44, 'чайная парочка', 'с позолотом', 10, 10, 10, 583, 'image12.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (45, 'чайная парочка', 'дмитрию', 11, 11, 11, 594, 'image13.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (46, 'чайная парочка', 'травянистая', 12, 12, 12, 605, 'image14.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (47, 'чайная парочка', 'солнечная', 13, 13, 13, 616, 'image15.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (48, 'чайная парочка', 'дождливая', 14, 14, 14, 627, 'image16.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (49, 'чашечка', 'с зайцем', 10, 5, 10, 275, 'image1.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (50, 'чашечка', 'с пчелами', 9, 6, 11, 242, 'image2.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (51, 'чашечка', 'радуга', 8, 7, 12, 253, 'image3.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (52, 'чашечка', 'цветок', 7, 8, 13, 264, 'image4.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (53, 'чашечка', 'в цветочек', 6, 9, 14, 286, 'image5.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (54, 'чашечка', 'в точку', 5, 10, 15, 297, 'image6.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (55, 'чашечка', 'в полоску', 10, 5, 16, 308, 'image7.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (56, 'чашечка', 'с рыбками', 9, 6, 17, 319, 'image8.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (57, 'чашечка', 'с солнцем', 8, 7, 18, 330, 'image9.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (58, 'чашечка', 'облака', 7, 8, 19, 341, 'image10.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (59, 'чашечка', 'яблочко', 6, 9, 20, 352, 'image11.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (60, 'чашечка', 'трава', 10, 5, 10, 363, 'image12.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (61, 'чашечка', 'чаинки', 9, 6, 11, 374, 'image13.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (62, 'чашечка', 'с позолотом', 8, 7, 12, 385, 'image14.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (1, 'тарелочка', 'с зайцами', 15, 15, 1, 275, 'plate1.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (63, 'чашечка', 'апельсинки', 7, 8, 13, 396, 'image15.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."product" ("id", "type", "name", "length", "width", "height", "price", "picture", "status", "note", "add1", "add2", "add3", "color", "design") VALUES (64, 'чашечка', 'арбузик', 6, 9, 14, 407, 'image16.jpg', 'в продаже', NULL, NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;


--
-- TOC entry 3517 (class 0 OID 24891)
-- Dependencies: 221
-- Data for Name: program; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (8, 'индивидуальное занятие', 'индивидуальное занятие для группы не больше 1 человек', 1, 100, 'picture1.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (9, 'для детей', 'для детей для группы не больше 6 человек', 6, 120, 'picture2.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (10, 'для пары', 'для пары для группы не больше 2 человек', 2, 150, 'picture3.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (11, 'для родителей', 'для родителей для группы не больше 4 человек', 4, 80, 'picture4.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (12, 'для друзей', 'для друзей для группы не больше 8 человек', 8, 200, 'picture5.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (13, 'для коллег', 'для коллег для группы не больше 6 человек', 6, 90, 'picture6.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (14, 'для родственников', 'для родственников для группы не больше 9 человек', 9, 60, 'picture7.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (15, 'на праздник', 'на праздник для группы не больше 8 человек', 8, 220, 'picture8.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (16, 'мастер-класс', 'мастер-класс для группы не больше 5 человек', 5, 100, 'picture9.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (17, 'к новому году', 'к новому году для группы не больше 6 человек', 6, 120, 'picture10.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (18, 'к 14 февраля', 'к 14 февраля для группы не больше 6 человек', 6, 150, 'picture11.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (19, 'к 23 февраля', 'к 23 февраля для группы не больше 7 человек', 7, 80, 'picture12.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (20, 'к 8 марта', 'к 8 марта для группы не больше 8 человек', 8, 200, 'picture13.jpg', 'есть записи') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (21, 'к пасхе', 'к пасхе для группы не больше 4 человек', 4, 100, NULL, 'не действительна') ON CONFLICT DO NOTHING;
INSERT INTO "public"."program" ("id", "title", "description", "max_members", "price", "picture", "status") VALUES (22, 'к масленице', 'к масленице для группы не больше 2 человек', 2, 80, NULL, 'не действительна') ON CONFLICT DO NOTHING;


--
-- TOC entry 3523 (class 0 OID 24989)
-- Dependencies: 227
-- Data for Name: record; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (72, 9, '2024-01-13', 14, 2, 7, 2, 2, NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (29, 9, '2022-02-02', 10, 2, 6, 2, 2, '("для детей","для детей для группы не больше 6 человек",120)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (30, 10, '2022-03-03', 11, 3, 7, 3, 3, '("для пары","для пары для группы не больше 2 человек",150)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (31, 11, '2022-04-04', 12, 4, 8, 4, 4, '("для родителей","для родителей для группы не больше 4 человек",80)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (32, 12, '2022-06-05', 13, 5, 9, 5, 5, '("для друзей","для друзей для группы не больше 8 человек",200)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (33, 13, '2022-08-06', 14, 2, 6, 6, 6, '("для коллег","для коллег для группы не больше 6 человек",90)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (34, 14, '2022-09-07', 15, 3, 7, 7, 7, '("для родственников","для родственников для группы не больше 9 человек",60)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (35, 15, '2022-11-08', 16, 4, 8, 8, 8, '("на праздник","на праздник для группы не больше 8 человек",220)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (37, 17, '2022-12-10', 18, 2, 6, 10, 2, '("к новому году","к новому году для группы не больше 6 человек",120)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (38, 18, '2023-01-11', 19, 3, 7, 11, 3, '("к 14 февраля","к 14 февраля для группы не больше 6 человек",150)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (39, 19, '2023-02-12', 9, 4, 8, 12, 4, '("к 23 февраля","к 23 февраля для группы не больше 7 человек",80)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (40, 20, '2023-02-13', 12, 5, 6, 13, 5, '("к 8 марта","к 8 марта для группы не больше 8 человек",200)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (41, 21, '2023-03-14', 13, 2, 7, 14, 6, '("к пасхе","к пасхе для группы не больше 4 человек",100)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (42, 22, '2023-04-15', 14, 3, 8, 15, 7, '("к масленице","к масленице для группы не больше 2 человек",80)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (43, 10, '2023-05-16', 15, 4, 9, 16, 8, '("для пары","для пары для группы не больше 2 человек",150)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (44, 15, '2023-06-17', 16, 5, 6, 17, 9, '("на праздник","на праздник для группы не больше 8 человек",220)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (45, 8, '2023-07-18', 17, 2, 7, 18, 2, '("индивидуальное занятие","индивидуальное занятие для группы не больше 1 человек",100)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (46, 10, '2023-08-19', 18, 3, 8, 19, 3, '("для пары","для пары для группы не больше 2 человек",150)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (47, 16, '2023-09-20', 19, 4, 9, 20, 4, '(мастер-класс,"мастер-класс для группы не больше 5 человек",100)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (48, 18, '2023-10-21', 9, 5, 6, 21, 5, '("к 14 февраля","к 14 февраля для группы не больше 6 человек",150)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (49, 19, '2023-11-22', 12, 2, 7, 22, 6, '("к 23 февраля","к 23 февраля для группы не больше 7 человек",80)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (50, 10, '2023-11-23', 13, 3, 8, 23, 7, '("для пары","для пары для группы не больше 2 человек",150)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (51, 11, '2023-12-13', 14, 4, 9, 24, 8, '("для родителей","для родителей для группы не больше 4 человек",80)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (52, 12, '2023-12-25', 15, 5, 6, 25, 9, '("для друзей","для друзей для группы не больше 8 человек",200)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (56, 16, '2024-01-23', 19, 5, 6, 29, 5, '(мастер-класс,"мастер-класс для группы не больше 5 человек",100)') ON CONFLICT DO NOTHING;
INSERT INTO "public"."record" ("id", "program", "date", "time", "master", "assistant", "customer", "members", "program_info") VALUES (36, 16, '2022-12-09', 17, 5, 9, 9, 6, '(мастер-класс,"мастер-класс для группы не больше 5 человек",100)') ON CONFLICT DO NOTHING;


--
-- TOC entry 3521 (class 0 OID 24961)
-- Dependencies: 225
-- Data for Name: worker; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (1, 'Иван', 'Иванов', 'Иванович', '6301234567', 'м', '1990-05-25', '89123456789', 1, '(Иван,Иванов,Иванович)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (2, 'Петр', 'Петров', 'Петрович', '6307654321', 'м', '1985-12-12', '89123456787', 2, '(Петр,Петров,Петрович)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (3, 'Анна', 'Сидорова', 'Александровна', '6309876543', 'ж', '1993-02-28', '89123456785', 2, '(Анна,Сидорова,Александровна)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (4, 'Дмитрий', 'Смирнов', 'Игоревич', '6301357904', 'м', '1991-10-15', '89123456783', 2, '(Дмитрий,Смирнов,Игоревич)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (5, 'Елена', 'Козлова', 'Сергеевна', '6302468013', 'ж', '1995-07-22', '89123456781', 2, '(Елена,Козлова,Сергеевна)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (15, 'Евгения', 'Смирнова', 'Сергеевна', '6308889990', 'ж', '1998-06-19', '89123456766', 5, '(Евгения,Смирнова,Сергеевна)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (16, 'Владимир', 'Иванов', 'Алексеевич', '6309898989', 'м', '1996-03-15', '89123456765', 6, '(Владимир,Иванов,Алексеевич)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (17, 'Яна', 'Петрова', 'Петровна', '6301010101', 'ж', '1992-12-30', '89123456764', 6, '(Яна,Петрова,Петровна)', NULL) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (6, 'Сергей', 'Иванов', 'Владимирович', '6308024680', 'м', '1989-04-17', '89123456779', 3, '(Сергей,Иванов,Владимирович)', 2) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (7, 'Мария', 'Петрова', 'Дмитриевна', '6306790123', 'ж', '1987-09-11', '89123456777', 3, '(Мария,Петрова,Дмитриевна)', 3) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (8, 'Александр', 'Сидоров', 'Алексеевич', '6301238906', 'м', '1994-06-30', '89123456775', 3, '(Александр,Сидоров,Алексеевич)', 4) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (9, 'Ольга', 'Козлова', 'Александровна', '6309283746', 'ж', '1992-03-26', '89123456773', 3, '(Ольга,Козлова,Александровна)', 5) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (10, 'Игорь', 'Жуков', 'Петрович', '6305678943', 'м', '1990-11-20', '89123456771', 3, '(Игорь,Жуков,Петрович)', 2) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (11, 'Наталья', 'Иванова', 'Дмитриевна', '6301234560', 'ж', '1986-08-16', '89123456770', 3, '(Наталья,Иванова,Дмитриевна)', 3) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (12, 'Алексей', 'Петров', 'Игоревич', '6302223344', 'м', '1988-05-12', '89123456769', 4, '(Алексей,Петров,Игоревич)', 15) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (13, 'Марина', 'Сидорова', 'Алексеевна', '6304445556', 'ж', '1997-02-18', '89123456768', 4, '(Марина,Сидорова,Алексеевна)', 15) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (14, 'Денис', 'Козлов', 'Владимирович', '6306667778', 'м', '1999-09-25', '89123456767', 4, '(Денис,Козлов,Владимирович)', 15) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (18, 'Станислав', 'Сидоров', 'Игоревич', '6302323232', 'м', '1997-07-28', '89123456763', 7, '(Станислав,Сидоров,Игоревич)', 16) ON CONFLICT DO NOTHING;
INSERT INTO "public"."worker" ("id", "first_name", "last_name", "patronymic", "passport", "gender", "birthday", "telephone", "post", "fio", "kurator") VALUES (19, 'Ирина', 'Козлова', 'Владимировна', '6303434343', 'ж', '1995-04-24', '89123456762', 7, '(Ирина,Козлова,Владимировна)', 17) ON CONFLICT DO NOTHING;


--
-- TOC entry 3538 (class 0 OID 0)
-- Dependencies: 214
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."account_id_seq"', 99, true);


--
-- TOC entry 3539 (class 0 OID 0)
-- Dependencies: 218
-- Name: orderr_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."orderr_id_seq"', 72, true);


--
-- TOC entry 3540 (class 0 OID 0)
-- Dependencies: 222
-- Name: post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."post_id_seq"', 7, true);


--
-- TOC entry 3541 (class 0 OID 0)
-- Dependencies: 216
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."product_id_seq"', 64, true);


--
-- TOC entry 3542 (class 0 OID 0)
-- Dependencies: 220
-- Name: programm_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."programm_id_seq"', 22, true);


--
-- TOC entry 3543 (class 0 OID 0)
-- Dependencies: 226
-- Name: record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."record_id_seq"', 72, true);


--
-- TOC entry 3544 (class 0 OID 0)
-- Dependencies: 224
-- Name: worker_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."worker_id_seq"', 19, true);


--
-- TOC entry 3297 (class 2606 OID 24851)
-- Name: account account_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."account"
    ADD CONSTRAINT "account_login_key" UNIQUE ("login");


--
-- TOC entry 3299 (class 2606 OID 24849)
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."account"
    ADD CONSTRAINT "account_pkey" PRIMARY KEY ("id");


--
-- TOC entry 3301 (class 2606 OID 24853)
-- Name: account account_telephone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."account"
    ADD CONSTRAINT "account_telephone_key" UNIQUE ("telephone");


--
-- TOC entry 3316 (class 2606 OID 24879)
-- Name: orderr orderr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orderr"
    ADD CONSTRAINT "orderr_pkey" PRIMARY KEY ("id");


--
-- TOC entry 3328 (class 2606 OID 24959)
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."post"
    ADD CONSTRAINT "post_pkey" PRIMARY KEY ("id");


--
-- TOC entry 3310 (class 2606 OID 24868)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product"
    ADD CONSTRAINT "product_pkey" PRIMARY KEY ("id");


--
-- TOC entry 3321 (class 2606 OID 24901)
-- Name: program programm_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."program"
    ADD CONSTRAINT "programm_pkey" PRIMARY KEY ("id");


--
-- TOC entry 3323 (class 2606 OID 24903)
-- Name: program programm_title_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."program"
    ADD CONSTRAINT "programm_title_key" UNIQUE ("title");


--
-- TOC entry 3346 (class 2606 OID 24997)
-- Name: record record_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."record"
    ADD CONSTRAINT "record_pkey" PRIMARY KEY ("id");


--
-- TOC entry 3334 (class 2606 OID 24970)
-- Name: worker worker_passport_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."worker"
    ADD CONSTRAINT "worker_passport_key" UNIQUE ("passport");


--
-- TOC entry 3336 (class 2606 OID 24968)
-- Name: worker worker_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."worker"
    ADD CONSTRAINT "worker_pkey" PRIMARY KEY ("id");


--
-- TOC entry 3338 (class 2606 OID 24972)
-- Name: worker worker_telephone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."worker"
    ADD CONSTRAINT "worker_telephone_key" UNIQUE ("telephone");


--
-- TOC entry 3302 (class 1259 OID 25019)
-- Name: ix_account_birthday; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_account_birthday" ON "public"."account" USING "btree" ("birthday");


--
-- TOC entry 3303 (class 1259 OID 25021)
-- Name: ix_account_gender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_account_gender" ON "public"."account" USING "btree" ("gender");


--
-- TOC entry 3304 (class 1259 OID 25018)
-- Name: ix_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_account_id" ON "public"."account" USING "btree" ("id");


--
-- TOC entry 3305 (class 1259 OID 25020)
-- Name: ix_account_lastname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_account_lastname" ON "public"."account" USING "btree" ("last_name");


--
-- TOC entry 3311 (class 1259 OID 25031)
-- Name: ix_orderr_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_orderr_customer" ON "public"."orderr" USING "btree" ("customer");


--
-- TOC entry 3312 (class 1259 OID 25030)
-- Name: ix_orderr_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_orderr_date" ON "public"."orderr" USING "btree" ("date");


--
-- TOC entry 3313 (class 1259 OID 25029)
-- Name: ix_orderr_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_orderr_id" ON "public"."orderr" USING "btree" ("id");


--
-- TOC entry 3314 (class 1259 OID 25032)
-- Name: ix_orderr_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_orderr_status" ON "public"."orderr" USING "btree" ("status");


--
-- TOC entry 3324 (class 1259 OID 25022)
-- Name: ix_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_post_id" ON "public"."post" USING "btree" ("id");


--
-- TOC entry 3325 (class 1259 OID 25024)
-- Name: ix_post_salary; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_post_salary" ON "public"."post" USING "btree" ("salary");


--
-- TOC entry 3326 (class 1259 OID 25023)
-- Name: ix_post_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_post_title" ON "public"."post" USING "btree" ("title");


--
-- TOC entry 3306 (class 1259 OID 25033)
-- Name: ix_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_product_id" ON "public"."product" USING "btree" ("id");


--
-- TOC entry 3307 (class 1259 OID 25035)
-- Name: ix_product_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_product_status" ON "public"."product" USING "btree" ("status");


--
-- TOC entry 3308 (class 1259 OID 25034)
-- Name: ix_product_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_product_type" ON "public"."product" USING "btree" ("type");


--
-- TOC entry 3317 (class 1259 OID 25036)
-- Name: ix_program_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_program_id" ON "public"."program" USING "btree" ("id");


--
-- TOC entry 3318 (class 1259 OID 25037)
-- Name: ix_program_maxmembers; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_program_maxmembers" ON "public"."program" USING "btree" ("max_members");


--
-- TOC entry 3319 (class 1259 OID 25038)
-- Name: ix_program_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_program_status" ON "public"."program" USING "btree" ("status");


--
-- TOC entry 3339 (class 1259 OID 25043)
-- Name: ix_record_assistant; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_record_assistant" ON "public"."record" USING "btree" ("assistant");


--
-- TOC entry 3340 (class 1259 OID 25044)
-- Name: ix_record_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_record_customer" ON "public"."record" USING "btree" ("customer");


--
-- TOC entry 3341 (class 1259 OID 25040)
-- Name: ix_record_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_record_date" ON "public"."record" USING "btree" ("date");


--
-- TOC entry 3342 (class 1259 OID 25039)
-- Name: ix_record_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_record_id" ON "public"."record" USING "btree" ("id");


--
-- TOC entry 3343 (class 1259 OID 25042)
-- Name: ix_record_master; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_record_master" ON "public"."record" USING "btree" ("master");


--
-- TOC entry 3344 (class 1259 OID 25041)
-- Name: ix_record_program; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_record_program" ON "public"."record" USING "btree" ("program");


--
-- TOC entry 3329 (class 1259 OID 25028)
-- Name: ix_worker_birthday; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_worker_birthday" ON "public"."worker" USING "btree" ("birthday");


--
-- TOC entry 3330 (class 1259 OID 25025)
-- Name: ix_worker_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_worker_id" ON "public"."worker" USING "btree" ("id");


--
-- TOC entry 3331 (class 1259 OID 25026)
-- Name: ix_worker_lastname; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_worker_lastname" ON "public"."worker" USING "btree" ("last_name");


--
-- TOC entry 3332 (class 1259 OID 25027)
-- Name: ix_worker_post; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "ix_worker_post" ON "public"."worker" USING "btree" ("post");


--
-- TOC entry 3356 (class 2620 OID 25081)
-- Name: orderr check_orders_customer_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_orders_customer_trigger" BEFORE INSERT ON "public"."orderr" FOR EACH ROW EXECUTE FUNCTION "public"."check_orders_customer"();


--
-- TOC entry 3357 (class 2620 OID 25079)
-- Name: post post_delete_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "post_delete_trigger" BEFORE DELETE ON "public"."post" FOR EACH ROW EXECUTE FUNCTION "public"."post_delete"();


--
-- TOC entry 3358 (class 2620 OID 25184)
-- Name: record program_status_t; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "program_status_t" AFTER INSERT ON "public"."record" FOR EACH ROW EXECUTE FUNCTION "public"."program_status"();


--
-- TOC entry 3347 (class 2606 OID 25192)
-- Name: orderr fkfn2oumlsu5c1hmevcvvm9fp84; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orderr"
    ADD CONSTRAINT "fkfn2oumlsu5c1hmevcvvm9fp84" FOREIGN KEY ("account") REFERENCES "public"."account"("id") ON DELETE RESTRICT;


--
-- TOC entry 3348 (class 2606 OID 24880)
-- Name: orderr orderr_customer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orderr"
    ADD CONSTRAINT "orderr_customer_fkey" FOREIGN KEY ("customer") REFERENCES "public"."account"("id") ON DELETE RESTRICT;


--
-- TOC entry 3349 (class 2606 OID 24885)
-- Name: orderr orderr_product_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."orderr"
    ADD CONSTRAINT "orderr_product_fkey" FOREIGN KEY ("product") REFERENCES "public"."product"("id") ON DELETE RESTRICT;


--
-- TOC entry 3352 (class 2606 OID 25008)
-- Name: record record_assistant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."record"
    ADD CONSTRAINT "record_assistant_fkey" FOREIGN KEY ("assistant") REFERENCES "public"."worker"("id") ON DELETE RESTRICT;


--
-- TOC entry 3353 (class 2606 OID 25013)
-- Name: record record_customer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."record"
    ADD CONSTRAINT "record_customer_fkey" FOREIGN KEY ("customer") REFERENCES "public"."account"("id") ON DELETE RESTRICT;


--
-- TOC entry 3354 (class 2606 OID 25003)
-- Name: record record_master_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."record"
    ADD CONSTRAINT "record_master_fkey" FOREIGN KEY ("master") REFERENCES "public"."worker"("id") ON DELETE RESTRICT;


--
-- TOC entry 3355 (class 2606 OID 24998)
-- Name: record record_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."record"
    ADD CONSTRAINT "record_program_fkey" FOREIGN KEY ("program") REFERENCES "public"."program"("id") ON DELETE RESTRICT;


--
-- TOC entry 3350 (class 2606 OID 25150)
-- Name: worker worker_kurator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."worker"
    ADD CONSTRAINT "worker_kurator_fkey" FOREIGN KEY ("kurator") REFERENCES "public"."worker"("id");


--
-- TOC entry 3351 (class 2606 OID 24973)
-- Name: worker worker_post_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."worker"
    ADD CONSTRAINT "worker_post_fkey" FOREIGN KEY ("post") REFERENCES "public"."post"("id") ON DELETE RESTRICT;


-- Completed on 2024-01-15 08:49:14

--
-- PostgreSQL database dump complete
--

