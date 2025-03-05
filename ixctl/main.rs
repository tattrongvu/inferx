// Copyright (c) 2021 Quark Container Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#![allow(dead_code)]
#![allow(non_snake_case)]
#![allow(non_camel_case_types)]
#![allow(non_upper_case_globals)]

#[macro_use]
extern crate log;

#[macro_use]
extern crate clap;

pub mod command;
pub mod create;
// pub mod create_pypackage;
pub mod delete;
pub mod get;
pub mod list;
pub mod object_client;
pub mod update;

use command::{Parse, Run};
use inferxlib::common::*;

pub struct ClientConfig {
    pub url: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    let mut args = match Parse() {
        Ok(args) => args,
        Err(e) => {
            error!("the parse error is {:?}", e);
            panic!("exitting...")
        }
    };

    Run(&mut args).await?;

    return Ok(());
}
