import { Card } from "antd";
import { toJS } from "mobx";
import { observer } from "mobx-react";
import React, { useEffect, useRef } from "react";
import { WideLayout } from "@/components/layout/wide-layout/wide-layout";

import ProjectListCard from "@/pages/components/project-list-card/project-list-card";
import CreateProjectModal from "@/pages/components/create-project-modal/create-project-modal";
import { ProjectListStore } from "@/pages/project/project-list/project-list-store";

const ProjectList: React.FC = observer(() => {
  const storeRef = useRef(new ProjectListStore());

  useEffect(() => {
    storeRef.current.init();

    return () => {
      storeRef.current.destroy();
    };
  }, []);

  const store = storeRef.current;
  const status = toJS(store.status);

  return (
    <WideLayout width={1280}>
      <Card
        activeTabKey={status.curActiveTab}
        tabList={[
          { key: "my", tab: "我的项目" },
          { key: "all", tab: "所有项目" },
        ]}
        onTabChange={async (key) => {
          await store.onCardTabChange(key);
        }}
      >
        {status.curActiveTab === "my" && (
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

        {status.curActiveTab === "all" && (
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

      {storeRef.current.status.isShowCreateProjectModal && (
        <CreateProjectModal
          onOk={async () => {
            storeRef.current.setStatus({
              isShowCreateProjectModal: false,
            });
            await store.fetchProjects();
          }}
          onCancel={() => {
            storeRef.current.setStatus({
              isShowCreateProjectModal: false,
            });
          }}
        />
      )}
    </WideLayout>
  );
});

export default ProjectList;
