import path from "node:path";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig(async () => {
  const { default: frappeui } = await import("frappe-ui/vite");

  return {
    plugins: [
      ...frappeui({
        lucideIcons: true,
        frappeProxy: false,
        jinjaBootData: false,
        buildConfig: false,
      }),
      vue(),
    ],
    optimizeDeps: {
      include: ["frappe-ui > feather-icons", "showdown","debug"],
      esbuildOptions: {
        plugins: [
          {
            name: "ignore-lucide-icons-during-scan",
            setup(build) {
              build.onResolve({ filter: /^~icons\// }, (args) => ({
                path: args.path,
                external: true,
              }));
            },
          },
        ],
      },
    },
    server: {
      proxy: {
        "^/(app|login|api|assets|files|private)": {
          target: "http://127.0.0.1:8000",
          changeOrigin: true,
        },
      },
    },
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "src"),
      },
    },
  };
});