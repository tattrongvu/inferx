--DROP TABLE ApiKey;
CREATE TABLE Apikey (
    apikey          VARCHAR NOT NULL,
    realm           VARCHAR NOT NULL,
    username        VARCHAR NOT NULL,
    createtime      TIMESTAMP,
    PRIMARY KEY(apikey)
);
