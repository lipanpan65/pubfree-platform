import { Layout } from "antd";
import React from "react";
import Footer from "@/components/layout/page-layout/footer/footer";
import Header from "@/components/layout/page-layout/header/header";

const PageLayout: React.FC<{ children: React.ReactNode }> = (props) => {
  const { Content } = Layout;

  return (
    <Layout
      style={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
      }}
    >
      <Header />
      <Content
        style={{
          flex: 1,
        }}
      >
        {props.children}
      </Content>
      <Footer />
    </Layout>
  );
};
export default PageLayout;
