// 全局变量声明
declare global {
  var USE_V_CONSOLE: boolean;
  var SERVER_URL: string;
  var DOMAIN_SUFFIX: string;
}

console.log("--- loading global constants ---");

// 使用默认值防止变量未定义
const useVConsole = typeof USE_V_CONSOLE !== 'undefined' ? USE_V_CONSOLE : false;
const serverUrl = typeof SERVER_URL !== 'undefined' ? SERVER_URL : 'http://localhost:8080';
const domainSuffix = typeof DOMAIN_SUFFIX !== 'undefined' ? DOMAIN_SUFFIX : '';

console.log(`SERVER_URL: ${serverUrl}`);
console.log(`USE_V_CONSOLE: ${useVConsole}`);
console.log(`DOMAIN_SUFFIX: ${domainSuffix}`);

export const DefineProperty = {
  UseVConsole: useVConsole,
  ServerUrl: serverUrl,
  DomainSuffix: domainSuffix,
};
