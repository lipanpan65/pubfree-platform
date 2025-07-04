import { message } from "antd";
import { observable } from "mobx";

import { BasicStore } from "@/util/basic-store";
import { EProjectEnvType } from "@/interface/client-api/project.interface";

// import { EApiCode } from "@/interface/client-api/api-code.interface";
import Api, { EApiCode } from "@/api";
import { useNavigate } from "react-router-dom";

interface IParams {
  projectId: number;
  workspaceId: number;
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

class Status {
  envAreas: IProjectEnvDTO[] = [];

  curEnvAreaId: number | null = null;
  isShowCreateModal: boolean = false;
}



export class ProjectWorkspaceStore extends BasicStore<Status> {
  @observable.ref status = new Status();

  params: IParams | null = null;

  destroy() {
    this.status = new Status();
    this.params = null;
  }

  configParams(params: IParams) {
    this.params = params;
    this.setStatus({
      curEnvAreaId: params.workspaceId,
    });
  }

  async fetchEnvAreas() {
    const { projectId } = this.params || {};
    if (!projectId) {
      return;
    }
    const envAreasRes = await Api.project.getProjectEnvs(projectId);
    if (envAreasRes.code === EApiCode.Success) {
      const envAreas = envAreasRes.data.sort((a, b) => a.envType - b.envType);
      this.setStatus({
        envAreas: envAreas,
      });
    }
  }

  switchEnvArea(envAreaIdStr: string) {
    const { projectId } = this.params || {};
    // routerStore.replace(`/projects/${projectId}/workspaces/${envAreaIdStr}`);
    // 使用 react-router-dom 的 useNavigate 来跳转
    const navigate = useNavigate();
    navigate(`/projects/${projectId}/workspaces/${envAreaIdStr}`);
  }

  async createWorkspace(envType: EProjectEnvType, name: string) {
    const { projectId } = this.params || {};
    if (!projectId) {
      return;
    }
    const res = await Api.project.createProjectEnv(projectId, {
      name: name,
      type: envType,
    });
    if (res.code === EApiCode.Success) {
      this.setStatus({
        isShowCreateModal: false,
      });
      message.success("新建工作区成功");
      await this.fetchEnvAreas();
    } else {
      message.error(`新建工作区失败，请稍候再试: ${res.message}`);
    }
  }
}

const projectWorkspaceStore = new ProjectWorkspaceStore();
export default projectWorkspaceStore;
