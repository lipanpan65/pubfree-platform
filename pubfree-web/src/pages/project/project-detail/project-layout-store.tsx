import { observable } from "mobx";
import Api, { EApiCode } from "@/api";

import { IProjectDTO } from "@/interface/client-api/project.interface";

// import { routerStore } from "@/store/router-store";

import { BasicStore } from "@/util/basic-store";
import { useNavigate } from "react-router-dom";

class Status {
  isLoading: boolean = true;
  curActiveKey: "workspaces" | "settings" | string | null = null;

  project: IProjectDTO | null = null;
}

export class ProjectLayoutStore extends BasicStore<Status> {
  @observable.ref status = new Status();

  params: {
    projectId: number;
  } | null = null;

  async init() {
    try {
      await this.fetchProjectInfo();
    } finally {
      this.setStatus({ isLoading: false });
    }
  }

  destroy() {
    this.status = new Status();
    this.params = null;
  }

  async fetchProjectInfo() {
    if (!this.params?.projectId) {
      return;
    }
    const res = await Api.project.getProjectInfo(this.params.projectId);
    if (res.code === EApiCode.Success) {
      this.setStatus({
        project: res.data,
      });
    }
  }

  switchProjectTab(key: "workspaces" | "settings" | string) {
    const { projectId } = this.params || {};
    this.setStatus({ curActiveKey: key });

    switch (key) {
      case "workspaces":
        // 跳转到工作区页面
        // 使用 react-router-dom 的 useNavigate 来跳转
        const navigate = useNavigate();
        navigate(`/projects/${projectId}/workspaces`);
        // routerStore.replace(`/projects/${projectId}/workspaces`);
        break;
      case "settings":
        // 跳转到设置页面
        // const navigate = useNavigate();
        // navigate(`/projects/${projectId}/settings/common`);
        // routerStore.replace(`/projects/${projectId}/settings/common`);
        break;
    }
  }
}

const projectLayoutStore = new ProjectLayoutStore();
export default projectLayoutStore;
