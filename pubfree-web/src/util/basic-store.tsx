import { observable, runInAction, makeObservable } from "mobx";

/**
 * 基础 store 类，用来给单页面的 store 继承
 */
export class BasicStore<T> {
  /**
   * 被监听的状态值
   */
  status: T | null = null;

  constructor() {
    makeObservable(this, {
      status: observable,
    });
  }

  /**
   * 封装 runInAction 统一更新状态值
   * @param object
   */
  setStatus(object: Partial<T>) {
    runInAction(() => {
      this.status = Object.assign({}, this.status, object);
    });
  }
}
