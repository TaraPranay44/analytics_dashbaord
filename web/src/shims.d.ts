declare module "frappe-ui/vite" { import type { PluginOption } from "vite"; const frappeuiPlugin: (options?: Record<string, any>) => PluginOption[]; export default frappeuiPlugin; } 
