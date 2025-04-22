--DROP TABLE ApiKey;
CREATE TABLE Apikey (
    apikey          VARCHAR NOT NULL,
    username        VARCHAR NOT NULL,
    keyname         VARCHAR NOT NULL,
    createtime      TIMESTAMP,
    PRIMARY KEY(apikey)
);

CREATE UNIQUE INDEX apikey_idx_realm_username ON Apikey (username, keyname);

CREATE TABLE UserRole (
    username        VARCHAR NOT NULL,
    rolename       VARCHAR NOT NULL,
    PRIMARY KEY(username, rolename)
);

CREATE INDEX userrole_idx_rolename ON UserRole (rolename);
