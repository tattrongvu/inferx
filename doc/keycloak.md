1. Create Realm "Inferx"
2. Create Client "infer_client" in  Realm "Inferx"
   a. Enable Client authentication
   b. Add Valid redirect URI
       https://inferx.net:8000/*
       http://<localhost>:1250/*
       http://<localhost>:81/*
       http://<localhost>:4000/*
   c. Add web origins
       https://inferx.net:8000
       http://<localhost>:1250
       http://<localhost>:81
       http://<localhost>:4000
    d. Enable "Direct Access Grants Enabled"
3. Update KEYCLOAK_CLIENT_SECRET in docker-compose_blob.yml
4. Update the KEYCLOAK_URL with local address
