import { observer } from "mobx-react";
import React, { useEffect, useState } from "react";
import { Route, Routes as RouterRoutes, Navigate } from "react-router-dom";
// import GroupHolder from "./page/group/group-detail/group-holder/group-holder";
// import GroupLayout from "./page/group/group-detail/group-layout";
// import GroupProject from "./page/group/group-detail/group-project/group-project";
// import GroupSetting from "./page/group/group-detail/group-settiing/group-setting";
// import NewGroupList from "./page/group/group-list/group-list";
// import ProjectHolder from "./page/project/project-detail/project-holder/project-holder";
// import ProjectLayout from "./page/project/project-detail/project-layout";
// import ProjectSetting from "./page/project/project-detail/project-setting/project-setting";
// import ProjectWorkspace from "./page/project/project-detail/project-workspace/project-workspace";
// import ProjectList from "./page/project/project-list/project-list";
// import userStore from "./store/user-store";

const Routes: React.FC = observer(() => {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        // await userStore.login();
      } finally {
        setIsLoading(false);
      }
    })();
  }, []);

  if (isLoading) {
    return null;
  }

  return (
    <RouterRoutes>
      {/* 临时占位路由，等组件开发完成后取消注释 */}
      <Route path="/projects" element={<div>Projects List (待开发)</div>} />
      
      {/* 示例路由结构，等组件开发完成后取消注释并修改 */}
      {/* 
      <Route path="/projects" element={<ProjectList />} />
      <Route path="/projects/:projectId" element={<ProjectLayout />}>
        <Route path="workspaces/:workspaceId" element={<ProjectWorkspace />} />
        <Route path="settings/:type" element={<ProjectSetting />} />
        <Route path="*" element={<ProjectHolder />} />
      </Route>

      <Route path="/groups" element={<NewGroupList />} />
      <Route path="/groups/:groupId" element={<GroupLayout />}>
        <Route path="projects" element={<GroupProject />} />
        <Route path="settings/:type" element={<GroupSetting />} />
        <Route path="*" element={<GroupHolder />} />
      </Route>
      */}

      <Route path="*" element={<Navigate to="/projects" replace />} />
    </RouterRoutes>
  );
});

export default Routes;
