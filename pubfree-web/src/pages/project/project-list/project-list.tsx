import { Card } from "antd";
import { observer } from "mobx-react";
import React, { useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { WideLayout } from "@/components/layout/wide-layout/wide-layout";

import ProjectListCard from "@/pages/components/project-list-card/project-list-card";
import CreateProjectModal from "@/pages/components/create-project-modal/create-project-modal";
import { ProjectListStore } from "@/pages/project/project-list/project-list-store";

const ProjectList: React.FC = observer(() => {
  const storeRef = useRef(new ProjectListStore());
  const navigate = useNavigate();

  useEffect(() => {
    storeRef.current.init();

    return () => {
      storeRef.current.destroy();
    };
  }, []);

  const store = storeRef.current;
  const status = store.status;

  // 添加调试信息
  console.log("ProjectList render - status:", status);
  console.log("isShowCreateProjectModal:", status?.isShowCreateProjectModal);

  return (
    <WideLayout width={1280}>
      <Card
        activeTabKey={status?.curActiveTab || "my"}
        tabList={[
          { key: "my", tab: "我的项目" },
          { key: "all", tab: "所有项目" },
        ]}
        onTabChange={async (key) => {
          await store.onCardTabChange(key, navigate);
        }}
      >
        {status?.curActiveTab === "my" && (
          <ProjectListCard
            searchWord={status.mySearchWord || undefined}
            isLoading={status.myIsLoading}
            projects={status.myProjects}
            projectsTotal={status.myProjectsTotal || 0}
            curPage={status.myCurPage}
            onSearch={async (searchVal) => {
              store.setStatus({ mySearchWord: searchVal, myCurPage: 1 });
              await store.fetchMimeProjects();
            }}
            onPageChange={async (page) => {
              store.setStatus({ myCurPage: page });
              await store.fetchMimeProjects();
            }}
            onClickCreate={() => store.onClickCreateProjectButton()}
          />
        )}

        {status?.curActiveTab === "all" && (
          <ProjectListCard
            searchWord={status.allSearchWord || undefined}
            isLoading={status.allIsLoading}
            projects={status.allProjects}
            projectsTotal={status.allProjectsTotal || 0}
            curPage={status.allCurPage}
            onSearch={async (searchVal) => {
              store.setStatus({ allSearchWord: searchVal, allCurPage: 1 });
              await store.fetchAllProjects();
            }}
            onPageChange={async (page) => {
              store.setStatus({ allCurPage: page });
              await store.fetchAllProjects();
            }}
            onClickCreate={() => store.onClickCreateProjectButton()}
          />
        )}
      </Card>

      {status?.isShowCreateProjectModal && (
        <CreateProjectModal
          onOk={async () => {
            store.setStatus({
              isShowCreateProjectModal: false,
            });
            await store.fetchProjects();
          }}
          onCancel={() => {
            store.setStatus({
              isShowCreateProjectModal: false,
            });
          }}
        />
      )}
    </WideLayout>
  );
});

export default ProjectList;
