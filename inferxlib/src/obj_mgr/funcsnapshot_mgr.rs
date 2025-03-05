use std::collections::BTreeMap;

use serde::{Deserialize, Serialize};

use crate::common::*;
use crate::data_obj::{DataObject, DataObjectMgr};
use crate::resource::Standby;

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct SnapshotInfo {
    pub hostMemSize: u64,
    pub processCheckpointSize: u64,
    pub fatbinSize: u64,
    pub gpuMemSizes: BTreeMap<i32, u64>,
    pub standby: Standby,
}

impl SnapshotInfo {
    pub fn SnapshotStandyInfo(&self) -> SnapshotStandyInfo {
        let mut gpu = 0;
        for (_, size) in &self.gpuMemSizes {
            gpu += *size;
        }
        return SnapshotStandyInfo {
            pageable: self.processCheckpointSize,
            gpu: gpu,
            pinned: self.hostMemSize,
        };
    }
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct SnapshotStandyInfo {
    pub pageable: u64,
    pub pinned: u64,
    pub gpu: u64,
}

#[derive(Serialize, Deserialize, Debug, PartialEq, Eq, Default, Clone)]
pub struct SnapshotMeta {
    pub imagename: String,
    pub buildId: Vec<u8>,
}

impl SnapshotMeta {
    pub fn Load(root: &str) -> Result<Self> {
        let path = format!("{}/{}", root, "meta.data");
        let str: String = std::fs::read_to_string(path)?;
        let u = match serde_json::from_str(&str) {
            Ok(u) => u,
            Err(e) => {
                return Err(Error::CommonError(format!(
                    "SnapshotMeta load fail for {} with error {:?}",
                    root, e
                )));
            }
        };
        return Ok(u);
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, Default)]
pub struct ContainerSnapshot {
    pub funckey: String,
    pub nodename: String,
    pub state: SnapshotState,
    pub meta: SnapshotMeta,
    pub info: SnapshotInfo,
}

#[derive(Clone, Debug, Serialize, Deserialize, Copy, PartialEq, Eq)]
pub enum SnapshotState {
    Loading,
    Ready,
}

impl Default for SnapshotState {
    fn default() -> Self {
        return Self::Loading;
    }
}

impl ContainerSnapshot {
    pub const KEY: &'static str = "snapshot";
}

pub type FuncSnapshot = DataObject<ContainerSnapshot>;
pub type FuncSnapshotMgr = DataObjectMgr<ContainerSnapshot>;
