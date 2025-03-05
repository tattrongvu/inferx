DROP DATABASE auditdb;
CREATE DATABASE auditdb;

\c auditdb;

DROP TABLE Pod;
CREATE TABLE Pod (
    tenant          VARCHAR NOT NULL,
    namespace       VARCHAR NOT NULL,
    fpname          VARCHAR NOT NULL,
    fprevision      bigint,
    id              VARCHAR NOT NULL,
    nodename        VARCHAR NOT NULL,
    state           VARCHAR NOT NULL,
    updatetime      TIMESTAMP,
    PRIMARY KEY(tenant, namespace, fpname, fprevision, id)
);

DROP TABLE PodAudit;
CREATE TABLE PodAudit (
    tenant          VARCHAR NOT NULL,
    namespace       VARCHAR NOT NULL,
    fpname          VARCHAR NOT NULL,
    fprevision      bigint,
    id              VARCHAR NOT NULL,
    nodename        VARCHAR NOT NULL,
    action          VARCHAR NOT NULL,
    state           VARCHAR NOT NULL,
    updatetime      TIMESTAMP,
    PRIMARY KEY(tenant, namespace, fpname, fprevision, id, updatetime)
);

DROP TABLE ReqAudit;
CREATE TABLE ReqAudit (
    seqid           SERIAL PRIMARY KEY, 
    podkey          VARCHAR NOT NULL,
    audittime       TIMESTAMP,
    keepalive       bool,
    ttft            int,            -- Time to First Token
    latency         int
);

CREATE USER audit_user WITH PASSWORD '123456';
GRANT ALL ON ALL TABLES IN SCHEMA public to audit_user;
GRANT USAGE ON SEQUENCE reqaudit_seqid_seq TO audit_user;

-- https://stackoverflow.com/questions/18664074/getting-error-peer-authentication-failed-for-user-postgres-when-trying-to-ge

DROP DATABASE testdb;
CREATE DATABASE testdb;

\c testdb;

DROP TABLE Pod;
CREATE TABLE Pod (
    tenant          VARCHAR NOT NULL
);

insert into pod values ('asdf');

CREATE OR REPLACE FUNCTION notification_trigger() RETURNS TRIGGER AS 
$$
BEGIN
    PERFORM pg_notify('your_channel_name', 
            to_json(NEW)::TEXT
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER capture_change_trigger AFTER INSERT OR UPDATE OR DELETE ON pod
FOR EACH ROW EXECUTE FUNCTION notification_trigger();

