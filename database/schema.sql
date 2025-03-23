

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
  INSERT INTO public."userProfile" (user_id, name, weight, email)
  VALUES (NEW.id, 
          NEW.raw_user_meta_data->>'name', 
          (NEW.raw_user_meta_data->>'weight')::BIGINT,
          NEW.email);
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."answer" (
    "id" bigint NOT NULL,
    "answer" "text" NOT NULL,
    "points" integer
);


ALTER TABLE "public"."answer" OWNER TO "postgres";


COMMENT ON TABLE "public"."answer" IS 'this table stores all question answer choices';



ALTER TABLE "public"."answer" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."answer_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."equipment" (
    "id" bigint NOT NULL,
    "name" character varying NOT NULL,
    "weight" integer
);


ALTER TABLE "public"."equipment" OWNER TO "postgres";


COMMENT ON TABLE "public"."equipment" IS 'stores different equipment';



ALTER TABLE "public"."equipment" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."equipment_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."exercise" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL,
    "instruction" "text" NOT NULL,
    "equipment_id" bigint,
    "duration" integer NOT NULL,
    "sets" integer NOT NULL,
    "reps" integer NOT NULL,
    "level" character varying NOT NULL,
    "rest" integer,
    "target_rpe_max" integer,
    "target_rpe_min" integer,
    "label" "text",
    "type" bigint
);


ALTER TABLE "public"."exercise" OWNER TO "postgres";


COMMENT ON TABLE "public"."exercise" IS 'stores individual exercises';



COMMENT ON COLUMN "public"."exercise"."label" IS 'this for core or assistance';



ALTER TABLE "public"."exercise" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."exercise_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."exercise_type" (
    "id" bigint NOT NULL,
    "type" "text" NOT NULL
);


ALTER TABLE "public"."exercise_type" OWNER TO "postgres";


COMMENT ON TABLE "public"."exercise_type" IS 'this stores the different types of exercises';



ALTER TABLE "public"."exercise_type" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."exercise_type_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."level" (
    "level" character varying NOT NULL,
    "min_points" bigint,
    "max_points" bigint
);


ALTER TABLE "public"."level" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."question" (
    "id" bigint NOT NULL,
    "question" "text" NOT NULL,
    "type" "text" NOT NULL,
    "number" real,
    "answer_id" bigint
);


ALTER TABLE "public"."question" OWNER TO "postgres";


COMMENT ON TABLE "public"."question" IS 'this table stores all of the questions asked for intake form, feedback form, and level assesment';



ALTER TABLE "public"."question" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."question_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."userEnvironmentEquipment" (
    "user_id" "uuid" NOT NULL,
    "equipment_id" bigint NOT NULL,
    "environment" "text" NOT NULL
);


ALTER TABLE "public"."userEnvironmentEquipment" OWNER TO "postgres";


COMMENT ON TABLE "public"."userEnvironmentEquipment" IS 'this table stores what equipment each user has at each workout location';



CREATE TABLE IF NOT EXISTS "public"."userFavorites" (
    "user_id" "uuid" NOT NULL,
    "fav_num" integer NOT NULL,
    "exercise_id" bigint NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."userFavorites" OWNER TO "postgres";


COMMENT ON TABLE "public"."userFavorites" IS 'to hold workouts that users favorite to do  again';



COMMENT ON COLUMN "public"."userFavorites"."fav_num" IS 'this keeps track of which exercise is part of which workout';



CREATE TABLE IF NOT EXISTS "public"."userProfile" (
    "weight" bigint,
    "name" character varying,
    "user_id" "uuid" NOT NULL,
    "points" bigint,
    "level" character varying,
    "email" "text" NOT NULL,
    "is_admin" boolean
);


ALTER TABLE "public"."userProfile" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."workoutHistory" (
    "date" timestamp without time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "exercise_id" bigint NOT NULL,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."workoutHistory" OWNER TO "postgres";


COMMENT ON TABLE "public"."workoutHistory" IS 'this table stores the workout history of a user and their feedback score';



ALTER TABLE ONLY "public"."answer"
    ADD CONSTRAINT "answer_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."equipment"
    ADD CONSTRAINT "equipment_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exercise"
    ADD CONSTRAINT "exercise_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exercise_type"
    ADD CONSTRAINT "exercise_type_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."level"
    ADD CONSTRAINT "level_pkey" PRIMARY KEY ("level");



ALTER TABLE ONLY "public"."question"
    ADD CONSTRAINT "question_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."userEnvironmentEquipment"
    ADD CONSTRAINT "userEnvironmentEquipment_pkey" PRIMARY KEY ("user_id", "equipment_id", "environment");



ALTER TABLE ONLY "public"."userFavorites"
    ADD CONSTRAINT "userFavorites_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."userProfile"
    ADD CONSTRAINT "userProfile_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."userProfile"
    ADD CONSTRAINT "userProfile_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."workoutHistory"
    ADD CONSTRAINT "workoutHistory_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."exercise"
    ADD CONSTRAINT "exercise_equipment_id_fkey" FOREIGN KEY ("equipment_id") REFERENCES "public"."equipment"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."exercise"
    ADD CONSTRAINT "exercise_level_fkey" FOREIGN KEY ("level") REFERENCES "public"."level"("level");



ALTER TABLE ONLY "public"."exercise"
    ADD CONSTRAINT "exercise_type_fkey" FOREIGN KEY ("type") REFERENCES "public"."exercise_type"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."question"
    ADD CONSTRAINT "question_answer_id_fkey" FOREIGN KEY ("answer_id") REFERENCES "public"."answer"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."userEnvironmentEquipment"
    ADD CONSTRAINT "userEnvironmentEquipment_equipment_id_fkey" FOREIGN KEY ("equipment_id") REFERENCES "public"."equipment"("id");



ALTER TABLE ONLY "public"."userEnvironmentEquipment"
    ADD CONSTRAINT "userEnvironmentEquipment_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."userEnvironmentEquipment"
    ADD CONSTRAINT "userEnvironmentEquipment_user_id_fkey1" FOREIGN KEY ("user_id") REFERENCES "public"."userProfile"("user_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."userFavorites"
    ADD CONSTRAINT "userFavorites_exercise_id_fkey" FOREIGN KEY ("exercise_id") REFERENCES "public"."exercise"("id");



ALTER TABLE ONLY "public"."userFavorites"
    ADD CONSTRAINT "userFavorites_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."userProfile"("user_id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."userProfile"
    ADD CONSTRAINT "userProfile_level_fkey" FOREIGN KEY ("level") REFERENCES "public"."level"("level");



ALTER TABLE ONLY "public"."userProfile"
    ADD CONSTRAINT "userProfile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."workoutHistory"
    ADD CONSTRAINT "workoutHistory_exercise_id_fkey" FOREIGN KEY ("exercise_id") REFERENCES "public"."exercise"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."workoutHistory"
    ADD CONSTRAINT "workoutHistory_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



CREATE POLICY "Allow public read" ON "public"."userProfile" FOR SELECT USING (true);



CREATE POLICY "Public profiles are viewable by everyone." ON "public"."userProfile" FOR SELECT USING (true);



CREATE POLICY "Users can insert their own profile." ON "public"."userProfile" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile." ON "public"."userProfile" FOR UPDATE USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."exercise_type" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."level" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."userEnvironmentEquipment" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."userFavorites" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."userProfile" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."workoutHistory" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";




















































































































































































GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";


















GRANT ALL ON TABLE "public"."answer" TO "anon";
GRANT ALL ON TABLE "public"."answer" TO "authenticated";
GRANT ALL ON TABLE "public"."answer" TO "service_role";



GRANT ALL ON SEQUENCE "public"."answer_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."answer_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."answer_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."equipment" TO "anon";
GRANT ALL ON TABLE "public"."equipment" TO "authenticated";
GRANT ALL ON TABLE "public"."equipment" TO "service_role";



GRANT ALL ON SEQUENCE "public"."equipment_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."equipment_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."equipment_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."exercise" TO "anon";
GRANT ALL ON TABLE "public"."exercise" TO "authenticated";
GRANT ALL ON TABLE "public"."exercise" TO "service_role";



GRANT ALL ON SEQUENCE "public"."exercise_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."exercise_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."exercise_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."exercise_type" TO "anon";
GRANT ALL ON TABLE "public"."exercise_type" TO "authenticated";
GRANT ALL ON TABLE "public"."exercise_type" TO "service_role";



GRANT ALL ON SEQUENCE "public"."exercise_type_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."exercise_type_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."exercise_type_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."level" TO "anon";
GRANT ALL ON TABLE "public"."level" TO "authenticated";
GRANT ALL ON TABLE "public"."level" TO "service_role";



GRANT ALL ON TABLE "public"."question" TO "anon";
GRANT ALL ON TABLE "public"."question" TO "authenticated";
GRANT ALL ON TABLE "public"."question" TO "service_role";



GRANT ALL ON SEQUENCE "public"."question_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."question_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."question_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."userEnvironmentEquipment" TO "anon";
GRANT ALL ON TABLE "public"."userEnvironmentEquipment" TO "authenticated";
GRANT ALL ON TABLE "public"."userEnvironmentEquipment" TO "service_role";



GRANT ALL ON TABLE "public"."userFavorites" TO "anon";
GRANT ALL ON TABLE "public"."userFavorites" TO "authenticated";
GRANT ALL ON TABLE "public"."userFavorites" TO "service_role";



GRANT ALL ON TABLE "public"."userProfile" TO "anon";
GRANT ALL ON TABLE "public"."userProfile" TO "authenticated";
GRANT ALL ON TABLE "public"."userProfile" TO "service_role";



GRANT ALL ON TABLE "public"."workoutHistory" TO "anon";
GRANT ALL ON TABLE "public"."workoutHistory" TO "authenticated";
GRANT ALL ON TABLE "public"."workoutHistory" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
