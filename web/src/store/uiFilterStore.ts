import { defineStore } from "pinia";
import { PAGE_SIZE_DEFAULT } from "@/constants/apiConstants";

/**
 * Client-only UI state for the landing employee list: current search text,
 * manager filter, sort, and page offset. Server data itself (the rows) lives
 * in TanStack Query's cache, never here - docs/05_FRONTEND_WEB_RULES.md §2.
 */
export const useUiFilterStore = defineStore("uiFilter", {
  state: () => ({
    q: "",
    manager: null as string | null,
    sort: null as string | null,
    start: 0,
    limit: PAGE_SIZE_DEFAULT,
  }),
  actions: {
    setQuery(q: string) {
      this.q = q;
      this.start = 0;
    },
    setManager(manager: string | null) {
      this.manager = manager;
      this.start = 0;
    },
    setSort(sort: string | null) {
      this.sort = sort;
      this.start = 0;
    },
    nextPage(hasMore: boolean) {
      if (hasMore) this.start += this.limit;
    },
    prevPage() {
      this.start = Math.max(0, this.start - this.limit);
    },
    reset() {
      this.q = "";
      this.manager = null;
      this.sort = null;
      this.start = 0;
    },
  },
});
