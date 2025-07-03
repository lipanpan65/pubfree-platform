import 'antd/dist/reset.css';
import { ConfigProvider } from "antd";
import zhCN from "antd/lib/locale/zh_CN";

import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import PageLayout from "@/components/layout/page-layout";

import Routes from "@/routes";

import "./style/style.less";

// antd v5 主题配置
const theme = {
  token: {
    colorPrimary: '#6247aa',
    colorLink: '#6247aa',
    colorTextHeading: '#6247aa',
  },
  components: {
    Layout: {
      headerBg: '#6247aa',
      headerHeight: 50,
    },
    Menu: {
      darkItemBg: '#6247aa',
      darkItemSelectedBg: '#815ac0',
    },
  },
};

const container = document.getElementById("root");
const root = createRoot(container!);

root.render(
  <BrowserRouter>
    <ConfigProvider locale={zhCN} theme={theme}>
      <PageLayout>
        <Routes />
      </PageLayout>
    </ConfigProvider>
  </BrowserRouter>
);
