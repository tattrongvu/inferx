--DROP TABLE ApiKey;
CREATE TABLE Apikey (
    apikey          VARCHAR NOT NULL,
    username        VARCHAR NOT NULL,
    keyname         VARCHAR NOT NULL,
    createtime      TIMESTAMP,
    PRIMARY KEY(apikey)
);

CREATE UNIQUE INDEX apikey_idx_realm_username ON Apikey (username, keyname);

CREATE TABLE UserGroup (
    username        VARCHAR NOT NULL,
    groupname       VARCHAR NOT NULL,
    PRIMARY KEY(username, groupname)
);

CREATE INDEX usergroup_idx_groupname ON UserGroup (groupname);
