const frappeUIPreset = require("frappe-ui/tailwind");

/**
 * Tailwind is present only because `frappe-ui`'s components render with
 * Tailwind utility classes internally (session/link/list components used
 * for backend plumbing) - see docs/05_FRONTEND_WEB_RULES.md §3. All
 * screen/feature styling in this app uses the hand-written custom classes
 * in `src/index.css`, not Tailwind utilities.
 */
module.exports = {
  presets: [frappeUIPreset],
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
    "./node_modules/frappe-ui/src/components/**/*.{vue,js,ts,jsx,tsx}",
  ],
};
