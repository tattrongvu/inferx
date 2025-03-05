use hyper::StatusCode;
use inferxlib::data_obj::DataObject;
use reqwest::Client;
use std::time::Duration;

use inferxlib::common::*;
use serde_json::Value;

pub struct ObjectClient {
    pub url: String,
}

impl ObjectClient {
    pub fn New(url: &str) -> Self {
        return Self {
            url: url.to_owned(),
        };
    }

    pub fn Client(&self) -> Client {
        let client = reqwest::Client::builder()
            .timeout(Duration::from_secs(2))
            .build()
            .unwrap();
        return client;
    }

    pub async fn Get(
        &self,
        objType: &str,
        tenant: &str,
        namespace: &str,
        name: &str,
    ) -> Result<DataObject<Value>> {
        let url = format!(
            "{}/object/{objType}/{tenant}/{namespace}/{name}/",
            &self.url
        );
        let body = self.Client().get(&url).send().await.unwrap().text().await?;
        let obj = serde_json::from_str(&body)?;
        return Ok(obj);
    }

    pub async fn List(
        &self,
        objType: &str,
        tenant: &str,
        namespace: &str,
    ) -> Result<Vec<DataObject<Value>>> {
        let client = self.Client();

        let url = format!("{}/objects/{objType}/{tenant}/{namespace}/", &self.url);
        error!("url is {:?}", &url);
        let body = client.get(&url).send().await?.text().await?;
        let obj = serde_json::from_str(&body)?;
        return Ok(obj);
    }

    pub async fn Create(&self, obj: DataObject<Value>) -> Result<i64> {
        let client = self.Client();
        let url = format!("{}/object/", &self.url);
        let resp = client.put(&url).json(&obj).send().await?;
        let code = resp.status().as_u16();
        if code == StatusCode::OK {
            let res = resp.text().await?;
            match res.parse::<i64>() {
                Err(e) => {
                    return Err(Error::CommonError(format!(
                        "can't parse res with error {:?}",
                        e
                    )))
                }
                Ok(version) => return Ok(version),
            }
        }

        let content = resp.text().await?;
        return Err(Error::CommonError(format!(
            "Create fail with resp {}",
            content
        )));
    }

    pub async fn Update(&self, obj: DataObject<Value>) -> Result<i64> {
        let client = self.Client();
        let url = format!("{}/object/", &self.url);
        let resp = client.post(&url).json(&obj).send().await?;
        let code = resp.status().as_u16();
        if code == StatusCode::OK {
            let res = resp.text().await?;
            match res.parse::<i64>() {
                Err(e) => {
                    return Err(Error::CommonError(format!(
                        "can't parse res with error {:?}",
                        e
                    )))
                }
                Ok(version) => return Ok(version),
            }
        }

        let content = resp.text().await.ok();
        return Err(Error::CommonError(format!(
            "Update fail with resp code {} content {:?}",
            code, content
        )));
    }

    pub async fn Delete(
        &self,
        objType: &str,
        tenant: &str,
        namespace: &str,
        name: &str,
    ) -> Result<i64> {
        let client = self.Client();
        let url = format!(
            "{}/object/{objType}/{tenant}/{namespace}/{name}/",
            &self.url
        );

        let resp = client.delete(&url).send().await?;
        let code = resp.status().as_u16();
        let content = resp.text().await?;
        println!("Delete response is {:?} content {}", code, content);
        if code == StatusCode::OK {
            let res = content;
            match res.parse::<i64>() {
                Err(e) => {
                    return Err(Error::CommonError(format!(
                        "can't parse res with error {:?}",
                        e
                    )))
                }
                Ok(version) => return Ok(version),
            }
        }

        return Err(Error::CommonError(format!(
            "Delete fail with resp http code {:?}",
            code
        )));
    }
}
