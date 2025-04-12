--DROP TABLE ApiKey;
CREATE TABLE Apikey (
    apikey          VARCHAR NOT NULL,
    realm           VARCHAR NOT NULL,
    username        VARCHAR NOT NULL,
    keyname         VARCHAR NOT NULL,
    createtime      TIMESTAMP,
    PRIMARY KEY(apikey)
);

CREATE UNIQUE INDEX apikey_idx_realm_username ON Apikey (realm, username, keyname);

