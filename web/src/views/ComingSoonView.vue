<script setup lang="ts">
import { computed } from "vue";
import { useRoute, useRouter } from "vue-router";
import { STRINGS } from "@/constants/stringConstants";
import { ROUTE_PATHS } from "@/constants/routeConstants";

const route = useRoute();
const router = useRouter();
const role = computed(() => String(route.params.role ?? ""));

function backToLogin(): void {
  router.push(ROUTE_PATHS.login);
}
</script>

<template>
  <div class="coming-soon-shell mesh">
    <div class="orb orb1"></div>
    <div class="orb orb2"></div>
    <div class="mesh-content coming-soon-content">
      <span class="eyebrow">{{ role.toUpperCase() }}</span>
      <h1>{{ STRINGS.comingSoonTitle }}</h1>
      <p>{{ STRINGS.comingSoonBody }}</p>
      <button class="btn btn-gradient" type="button" @click="backToLogin">
        {{ STRINGS.backToSignIn }}
      </button>
    </div>
  </div>
</template>

<style scoped>
.coming-soon-shell {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32px;
}
.coming-soon-shell .orb1 { width: 420px; height: 420px; top: -120px; left: -100px; background: var(--violet-500); opacity: 0.5; }
.coming-soon-shell .orb2 { width: 380px; height: 380px; bottom: -140px; right: -80px; background: var(--pink-500); opacity: 0.4; }
.coming-soon-content {
  max-width: 420px;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14px;
  color: var(--white);
}
.coming-soon-content h1 { font-size: 28px; font-weight: 800; margin: 0; }
.coming-soon-content p { color: var(--text-on-dark-muted); margin: 0 0 10px; font-size: 14.5px; line-height: 1.5; }
</style>
