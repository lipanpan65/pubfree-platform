import { List } from "antd";
import { observer } from "mobx-react";
import React from "react";
import { IProjectDTO } from "../../../../interface/client-api/project.interface";
// import { routerStore } from "../../../../store/router-store";
import styles from "./project-item.module.less";
import { useNavigate } from "react-router-dom";

interface IProps {
  project: IProjectDTO;
}

const ProjectItem: React.FC<IProps> = observer((props) => {
  const { project } = props;

  return (
    <List.Item
      key={project.id}
      className={styles.projectItem}
      extra={
        <div className={styles.userInfo}>
          <div>{project.ownerId}</div>
        </div>
      }
    >
      <List.Item.Meta
        title={
          <span
            className={styles.title}
            onClick={() => {
              // 跳转到项目工作区页面
              const navigate = useNavigate();
              navigate(`/projects/${project.id}/workspaces`);
              // routerStore.push(`/projects/${project.id}/workspaces`);
            }}
          >
            {`${project.name}（${project.zhName}）`}
          </span>
        }
        description={project.description || "no description"}
        className={styles.projectInfo}
      />
    </List.Item>
  );
});

export default ProjectItem;
