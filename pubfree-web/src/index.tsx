import 'antd/dist/reset.css';
import { ConfigProvider } from "antd";
import zhCN from "antd/lib/locale/zh_CN";

import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import PageLayout from "@/components/layout/page-layout";

import Routes from "./routes";

import "./style/style.less";

const container = document.getElementById("root");
const root = createRoot(container!);

root.render(
  <BrowserRouter>
    <ConfigProvider locale={zhCN}>
      <PageLayout>
        <Routes />
      </PageLayout>
    </ConfigProvider>
  </BrowserRouter>
);
