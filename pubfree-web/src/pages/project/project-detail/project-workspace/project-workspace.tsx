import { PlusOutlined } from "@ant-design/icons";
import { Tabs } from "antd";
import { isEmpty } from "lodash-es";
import { toJS } from "mobx";
import { observer } from "mobx-react";
import React, { useEffect, useRef } from "react";
import styles from "./project-workspace.module.less";
import { ProjectWorkspaceStore } from "./project-workspzce-store";
import { ProjectLayoutStore } from "../project-layout-store";
// import { projectLayoutStore } from "@/store/project-layout-store";
// import CreateWorkspaceModal from "@/components/project/create-workspace-modal/create-workspace-modal";
// import WorkspaceSingle from "@/components/project/workspace-single/workspace-single";

import { useParams } from "react-router-dom";

interface ProjectWorkspaceProps {
  projectId: string;
  workspaceId: string;
}


export interface IProjectEnvDTO {
  id: number;

  projectId: number;

  name: string;

  envType: EProjectEnvType;

  createUserId: number;

  createUser: {
    id: number;

    name: string;
  };
}

export enum EProjectEnvType {
  Test = 0,
  Beta = 1,
  Gray = 2,
  Prod = 3,
}

const EnvAreaTabPaneTab = (props: { envArea: IProjectEnvDTO }) => {
  const { envArea } = props;
  return (
    <div>
      {envArea.envType === EProjectEnvType.Test && (
        <span className={styles.tabPaneTest}>测</span>
      )}
      {envArea.envType === EProjectEnvType.Beta && (
        <span className={styles.tabPaneBeta}>预</span>
      )}
      {envArea.envType === EProjectEnvType.Gray && (
        <span className={styles.tabPaneGray}>灰</span>
      )}
      {envArea.envType === EProjectEnvType.Prod && (
        <span className={styles.tabPanePro}>线</span>
      )}
      {envArea.name && <span className="env-name">{envArea.name}</span>}
    </div>
  );
};


const ProjectWorkspace: React.FC<
  RouteComponentProps<{
    projectId: string;
    workspaceId: string;
  }>
> = observer((props) => {
  const storeRef = useRef(new ProjectWorkspaceStore());

  useEffect(() => {
    // projectLayoutStore.setStatus({ curActiveKey: "workspaces" });

    return () => {
      storeRef.current.destroy();
    };
  }, []);

  useEffect(() => {
    const { projectId, workspaceId } = props.match.params;
    storeRef.current.configParams({
      projectId: +projectId,
      workspaceId: +workspaceId,
    });
  }, [props.match.params]);

  useEffect(() => {
    storeRef.current.fetchEnvAreas();
  }, [props.match.params?.projectId]);

  const store = storeRef.current;
  const status = toJS(storeRef.current.status);

  if (isEmpty(status.envAreas)) {
    return null;
  }

  return (
    <div className={styles.projectWorkspace}>
      <Tabs
        className="project-env-area-tabs"
        type="card"
        activeKey={String(status.curEnvAreaId)}
        tabPosition="left"
        tabBarStyle={{
          width: "170px",
          textAlign: "left",
        }}
        onTabClick={(activeKey) => {
          if (activeKey === "add") {
            store.setStatus({
              isShowCreateModal: true,
            });
          } else {
            storeRef.current.switchEnvArea(activeKey);
          }
        }}
      >
        {status.envAreas.map((envArea) => (
          <Tabs.TabPane
            key={String(envArea.id)}
            tab={<EnvAreaTabPaneTab envArea={envArea} />}
          >
            {/* <WorkspaceSingle env={envArea} /> */}
          </Tabs.TabPane>
        ))}
        <Tabs.TabPane
          key="add"
          style={{ background: "red" }}
          tab={
            <div>
              <PlusOutlined style={{ marginRight: "6px" }} />
              <span>新建工作区</span>
            </div>
          }
        />
      </Tabs>
      {/* {status.isShowCreateModal && <CreateWorkspaceModal store={store} />} */}
    </div>
  );
});

export default ProjectWorkspace;

