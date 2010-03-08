-- Table: irclog

-- DROP TABLE irclog;
CREATE TABLE irclog
(
  id serial NOT NULL,
  channel character varying(30),
  "day" character(10),
  nick character varying(40),
  line text,
  spam boolean DEFAULT false,
  seen_date timestamp with time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);


-- Table: bot_store

-- DROP TABLE bot_store;

CREATE TABLE bot_store
(
  id integer NOT NULL,
  namespace text,
  store_key text,
  store_value text,
  CONSTRAINT "PK_bot_store_id" PRIMARY KEY (id),
  CONSTRAINT lookup UNIQUE (namespace, store_key)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE bot_store OWNER TO ilbot;
