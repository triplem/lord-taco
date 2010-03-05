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
