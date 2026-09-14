<script setup lang="ts">
import { useRouter } from "vue-router";
import { useAuthRoleStore } from "@/store/authRoleStore";
import { ROUTE_PATHS, comingSoonPath, type ComingSoonRole } from "@/constants/routeConstants";
import { STRINGS } from "@/constants/stringConstants";

const router = useRouter();
const authRole = useAuthRoleStore();

function chooseCeo(): void {
  authRole.selectRole("ceo");
  router.push(ROUTE_PATHS.dashboard);
}

function chooseComingSoon(role: ComingSoonRole): void {
  authRole.selectRole(role);
  router.push(comingSoonPath(role));
}
</script>

<template>
  <div class="login-shell">
    <aside class="login-hero mesh">
      <div class="orb orb1"></div>
      <div class="orb orb2"></div>
      <div class="orb orb3"></div>
      <div class="orb orb4"></div>
      <div class="mesh-content login-hero-content">
        <div class="login-brand">
          <div class="logo-mark"></div>
          <span class="login-brand-label">{{ STRINGS.appName.toUpperCase() }}</span>
        </div>
        <h1 class="hero-headline">{{ STRINGS.loginHeadline }}</h1>
        <p class="hero-sub">{{ STRINGS.loginSub }}</p>
        <div class="hero-badges">
          <div class="glass-badge">
            <div class="dot"></div>
            <div><strong>30,000</strong><span>employees tracked</span></div>
          </div>
          <div class="glass-badge">
            <div class="dot"></div>
            <div><strong>11M+</strong><span>activity logs / yr</span></div>
          </div>
        </div>
      </div>
    </aside>

    <main class="login-form-panel">
      <div class="login-form-inner">
        <span class="eyebrow">SIGN IN</span>
        <h1>Welcome back</h1>
        <p>Choose how you'd like to sign in today.</p>

        <div class="role-list">
          <button class="role-card active" type="button" @click="chooseCeo">
            <div class="role-icon role-icon-active">
              <svg viewBox="0 0 24 24" fill="none">
                <path d="M4 18L6 9l4 4 2-7 2 7 4-4 2 9H4Z" fill="#fff" />
                <rect x="4" y="19" width="16" height="2" rx="1" fill="#fff" />
              </svg>
            </div>
            <div class="role-text">
              <div class="role-title-row"><strong>CEO / Executive</strong></div>
              <p>Full org-wide analytics &amp; dashboards</p>
            </div>
            <span class="role-arrow">→</span>
          </button>

          <button class="role-card" type="button" @click="chooseComingSoon('manager')">
            <div class="role-icon">
              <svg viewBox="0 0 24 24" fill="none">
                <circle cx="8" cy="8" r="3.2" fill="#A7A5C2" />
                <circle cx="16" cy="8" r="3.2" fill="#A7A5C2" opacity="0.55" />
                <rect x="3" y="14" width="18" height="6" rx="3" fill="#A7A5C2" opacity="0.85" />
              </svg>
            </div>
            <div class="role-text">
              <div class="role-title-row">
                <strong>Manager</strong>
                <span class="badge-soon">Coming soon</span>
              </div>
              <p>Team analytics for your direct reports</p>
            </div>
          </button>

          <button class="role-card" type="button" @click="chooseComingSoon('employee')">
            <div class="role-icon">
              <svg viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="8" r="3.6" fill="#A7A5C2" />
                <rect x="5" y="14" width="14" height="7" rx="3.5" fill="#A7A5C2" />
              </svg>
            </div>
            <div class="role-text">
              <div class="role-title-row">
                <strong>Employee</strong>
                <span class="badge-soon">Coming soon</span>
              </div>
              <p>Mark attendance &amp; view your own activity</p>
            </div>
          </button>
        </div>

        <p class="demo-note">{{ STRINGS.demoNote }}</p>
      </div>
    </main>
  </div>
</template>

<style scoped>
.login-shell {
  display: flex;
  min-height: 100vh;
}
.login-hero {
  flex: 1 1 46%;
  max-width: 620px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  padding: 64px 56px;
  color: var(--white);
}
.login-hero-content {
  display: flex;
  flex-direction: column;
  height: 100%;
}
.login-brand {
  display: flex;
  align-items: center;
  gap: 10px;
}
.login-brand-label {
  font-size: 12.5px;
  font-weight: 700;
  letter-spacing: 0.06em;
}
.login-hero .orb1 { width: 460px; height: 460px; top: -140px; left: -140px; background: var(--violet-500); opacity: 0.55; }
.login-hero .orb2 { width: 420px; height: 420px; top: 80px; right: -100px; background: var(--pink-500); opacity: 0.42; }
.login-hero .orb3 { width: 400px; height: 400px; bottom: -160px; left: -60px; background: var(--amber-500); opacity: 0.3; }
.login-hero .orb4 { width: 320px; height: 320px; bottom: -100px; right: 20px; background: var(--teal-500); opacity: 0.24; }
.hero-headline {
  font-size: 42px;
  font-weight: 800;
  line-height: 1.14;
  margin: 40px 0 20px;
  max-width: 460px;
}
.hero-sub {
  font-size: 15px;
  line-height: 1.55;
  color: var(--text-on-dark-muted);
  max-width: 420px;
  margin: 0;
}
.hero-badges {
  display: flex;
  gap: 12px;
  margin-top: auto;
  flex-wrap: wrap;
}
.login-form-panel {
  flex: 1 1 54%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 64px 40px;
}
.login-form-inner {
  width: 100%;
  max-width: 480px;
  display: flex;
  flex-direction: column;
  gap: 28px;
}
.login-form-inner h1 { font-size: 30px; font-weight: 800; margin: 0; }
.login-form-inner > p { margin: -18px 0 0; color: var(--text-secondary); font-size: 14.5px; }
.role-list { display: flex; flex-direction: column; gap: 14px; }
.demo-note { font-size: 12px; color: var(--text-muted); text-align: center; }

@media (max-width: 860px) {
  .login-shell { flex-direction: column; }
  .login-hero { max-width: none; min-height: 320px; padding: 40px 28px; }
  .hero-headline { font-size: 30px; }
  .login-form-panel { padding: 32px 24px 48px; }
}
</style>
