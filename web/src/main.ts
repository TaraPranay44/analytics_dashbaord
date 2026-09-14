import "./index.css";

import { createApp } from "vue";
import { createPinia } from "pinia";
import { VueQueryPlugin, QueryClient } from "@tanstack/vue-query";
import { FrappeUI, frappeRequest, setConfig } from "frappe-ui";

import App from "./App.vue";
import router from "./router";

// Frappe-ui owns the resource fetcher (session/CSRF handling) - see
// docs/05_FRONTEND_WEB_RULES.md §3 ("don't hand-roll a parallel auth client").
setConfig("resourceFetcher", frappeRequest);

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

const app = createApp(App);
app.use(FrappeUI);
app.use(createPinia());
app.use(router);
app.use(VueQueryPlugin, { queryClient });

function mount(): void {
  app.mount("#app");
}

if (import.meta.env.DEV) {
  // In dev, Vite serves index.html directly (no Jinja pass), so boot globals
  // (csrf_token, etc.) aren't injected - fetch them once from the same
  // dev-only endpoint pattern used by other frappe-ui apps in this bench.
  frappeRequest({ url: "/api/method/analytics_portal.www.analytics_portal.get_context_for_dev" })
    .then((values: Record<string, unknown>) => {
      for (const key in values) {
        (window as unknown as Record<string, unknown>)[key] = values[key];
      }
    })
    .catch(() => {
      // Dev boot fetch failing (e.g. not logged in yet) shouldn't block the
      // app from mounting - API calls will simply fail until the user logs
      // into the Frappe site in another tab.
    })
    .finally(mount);
} else {
  mount();
}
