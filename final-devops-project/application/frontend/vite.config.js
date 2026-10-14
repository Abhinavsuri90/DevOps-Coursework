import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    // During `npm run dev`, forward API calls to a backend on localhost:8000.
    proxy: { "/api": "http://localhost:8000" },
  },
});
