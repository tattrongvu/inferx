use serde_json::Error as SerdeJsonError;

pub type Result<T> = core::result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    CommonError(String),
    NotExist(String),
    Exist(String),
    SchedulerNoEnoughResource(String),
    SerdeJsonError(SerdeJsonError),
    StdIOErr(std::io::Error),
    ReqWestErr(reqwest::Error),
}

impl From<SerdeJsonError> for Error {
    fn from(item: SerdeJsonError) -> Self {
        return Self::SerdeJsonError(item);
    }
}

impl From<std::io::Error> for Error {
    fn from(item: std::io::Error) -> Self {
        return Self::StdIOErr(item);
    }
}

impl From<reqwest::Error> for Error {
    fn from(item: reqwest::Error) -> Self {
        return Self::ReqWestErr(item);
    }
}
