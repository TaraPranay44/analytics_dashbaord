import path from "node:path";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

// Employee Analytics Portal — web frontend build config.
// Follows the same frappe-ui vite plugin conventions used by other Frappe
// frontend apps in this bench (see docs/05_FRONTEND_WEB_RULES.md).
export default defineConfig(async ({ mode }) => {
  const { default: frappeui } = await import("frappe-ui/vite");

  return {
    plugins: [
      ...frappeui({
        frontendRoute: "/analytics-portal",
        lucideIcons: true,
        jinjaBootData: true,
        buildConfig: {
          indexHtmlPath: "../analytics_portal/www/analytics-portal.html",
        },
      }),
      vue(),
    ],
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "src"),
      },
    },
    optimizeDeps: {
      include: ["frappe-ui > feather-icons", "showdown"],
    },
    define: {
      __VUE_PROD_DEVTOOLS__: mode !== "production",
    },
  };
});
